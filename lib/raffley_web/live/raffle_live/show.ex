defmodule RaffleyWeb.RaffleLive.Show do
  use RaffleyWeb, :live_view
  import RaffleyWeb.CustomComponents
  alias Raffley.Raffles
  alias Raffley.Repo
  alias Raffley.Tickets
  alias Raffley.Tickets.Ticket
  alias RaffleyWeb.Presence

  # Can mount the user in any live_view
  # on_mount {RaffleyWeb.UserAuth, :mount_current_scope}

  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        form: to_form(Tickets.change_ticket(%Ticket{}, %{}))
      )

    {:ok, socket}
  end

  def handle_params(%{"id" => id}, _uri, socket) do
    user =
      with %{user: user} <- socket.assigns.current_scope do
        user
      else
        _ -> nil
      end

    if connected?(socket) do
      Raffles.subscribe(id)

      payload = %{
        email: user.email,
        name: user.name,
        online_at: System.system_time(:second)
      }

      if user do
        {:ok, _} = Presence.track(self(), topic(id), user.id, payload)
      end
    end

    presences =
      Presence.list(topic(id))
      |> Enum.map(fn {id, %{metas: metas}} ->
        %{id: id, metas: metas}
      end)

    # Raffles.get! preloads [:charity, winning_ticket: :user]
    socket =
      case Raffles.get_raffle!(id) do
        nil ->
          put_flash(socket, :error, "Raffle not found")
          |> push_navigate(to: "/raffles")

        raffle ->
          tickets = Raffles.list_tickets(raffle)

          assign(socket, raffle: Repo.preload(raffle, :charity), page_title: raffle.prize)
          |> stream(:tickets, tickets)
          |> assign(:ticket_count, Enum.count(tickets))
          |> stream(:presences, presences)
          |> assign(:ticket_sum, Enum.sum_by(tickets, & &1.price))
          |> assign_async(:featured_raffles, fn ->
            # TODO: Remove when nessary, this is for testing purposes
            Process.sleep(500)
            {:ok, %{featured_raffles: Raffles.featured(raffle)}}
            # {:error, "Failed to load featured raffles"}
          end)
      end

    {:noreply, socket}
  end

  def topic(id), do: "raffle_watchers:#{id}"

  attr :id, :string, required: true
  attr :ticket, Ticket, required: true

  def ticket(assigns) do
    ~H"""
    <div class="ticket" id={@id}>
      <section>
        <div class="price-paid">
          ${@ticket.price}
        </div>
        <span class="username">
          {@ticket.user.name}
        </span>
        <blockquote>
          {@ticket.comment}
        </blockquote>
      </section>
    </div>
    """
  end

  #
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="raffle-show">
        <.banner :if={@raffle.winning_ticket}>
          <.icon name="hero-sparkles-solid" /> Congratulations {@raffle.winning_ticket.user.name}
          <:details>
            <div>
              Your ticket {@raffle.winning_ticket_id} is the winner
            </div>
            <div class="text-sm text-gray-300">
              {@raffle.winning_ticket.comment}
            </div>
          </:details>
        </.banner>

        <div class="raffle">
          <img src={@raffle.image_path} alt="Image" />
          <section>
            <.badge status={@raffle.status} />
            <header>
              <div>
                <h2>{@raffle.prize}</h2>
                <h3>{@raffle.charity.name}</h3>
              </div>
              <div class="price">
                {@raffle.ticket_price} / ticket
              </div>
            </header>
            <div class="description">
              {@raffle.description}
            </div>

            <div class="totals">
              {@ticket_count} Tickets Sold - ${@ticket_sum} Raised
            </div>
          </section>
        </div>
        <div class="activity">
          <div class="left">
            <div :if={@raffle.status == :open && @current_scope}>
              <.form for={@form} id="ticket-form" phx-submit="save">
                <.input field={@form[:comment]} placeholder="Comment..." autofocus />
                <.button>Get A Ticket</.button>
              </.form>
            </div>

            <div id="tickets" phx-update="stream">
              <.ticket :for={{dom_id, ticket} <- @streams.tickets} id={dom_id} ticket={ticket} />
            </div>
          </div>
          <div class="right">
            <.featured_raffles raffles={@featured_raffles} />

            <.raffle_watchers :if={@current_scope} presences={@streams.presences} />
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end

  attr :raffles, :map, required: true

  def featured_raffles(assigns) do
    ~H"""
    <h4>Featured Raffles</h4>
    <.async_result :let={raffles} assign={@raffles}>
      <:loading>
        <div class="loading">
          <div class="spinner"></div>
        </div>
      </:loading>

      <:failed :let={{:error, reason}}>
        <div class="failed">
          Error: {reason}
        </div>
      </:failed>

      <ul class="raffles">
        <li :for={raffle <- raffles}>
          <.link navigate={~p"/raffles/#{raffle.id}"}>
            <img src={raffle.image_path} alt="Image" />
            {raffle.prize}
          </.link>
        </li>
      </ul>
    </.async_result>
    """
  end

  def raffle_watchers(assigns) do
    ~H"""
    <section>
      <ul class="presences" id="raffle-watchers" phx-update="stream">
        <li :for={{dom_id, %{id: id, metas: [user | _b]}} <- @presences} id={dom_id}>
          <.icon name="hero-user-circle-solid" size="size-5" />
          <button onclick={"alert('#{user.name} ID is: #{id}')"}>
            {user.name}
          </button>
        </li>
      </ul>
    </section>
    """
  end

  def handle_event("validate", %{"ticket" => ticket_params}, socket) do
    %{raffle: raffle, current_scope: scope} = socket.assigns
    ticket = %Ticket{user_id: scope.user.id, raffle_id: raffle.id}

    changeset = Tickets.change_ticket(ticket, ticket_params)

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"ticket" => ticket_params}, socket) do
    IO.inspect(socket.assigns.current_scope, label: "Handle save")
    %{raffle: raffle, current_scope: scope} = socket.assigns

    case Tickets.create_ticket(scope.user, raffle, ticket_params) do
      {:ok, ticket} ->
        changeset = Tickets.change_ticket(%Ticket{comment: ""})

        socket =
          assign(socket, form: to_form(changeset))
          |> put_flash(:info, "Your ticket #{ticket.id} has been created")
          |> stream_insert(:tickets, ticket, at: 0)
          |> update(:ticket_count, &(&1 + 1))
          |> update(:ticket_sum, &(&1 + ticket.price))

        {:noreply, socket}

      {:error, changeset} ->
        {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
    end
  end

  def handle_info({:ticket_created, ticket}, socket) do
    socket =
      socket
      |> put_flash(:info, "A new ticket has been created")
      |> stream_insert(:tickets, ticket, at: 0)
      |> update(:ticket_count, &(&1 + 1))
      |> update(:ticket_sum, &(&1 + ticket.price))

    {:noreply, socket}
  end

  def handle_info({:raffle_updated, raffle}, socket) do
    socket =
      socket
      |> put_flash(:info, "A winner has been drawn")
      |> assign(:raffle, Repo.preload(raffle, winning_ticket: :user))

    {:noreply, socket}
  end
end
