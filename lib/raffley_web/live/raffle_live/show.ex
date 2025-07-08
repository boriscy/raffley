defmodule RaffleyWeb.RaffleLive.Show do
  use RaffleyWeb, :live_view
  import RaffleyWeb.CustomComponents
  alias Raffley.Raffles
  alias Raffley.Repo
  alias Raffley.Tickets
  alias Raffley.Tickets.Ticket

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
    socket =
      case Raffles.get_raffle!(id) do
        nil ->
          put_flash(socket, :error, "Raffle not found")
          |> push_navigate(to: "/raffles")

        raffle ->
          user = socket.assigns.current_scope.user

          assign(socket, raffle: Repo.preload(raffle, :charity), page_title: raffle.prize)
          |> assign(:tickets, Tickets.list_tickets(user, raffle))
          |> assign_async(:featured_raffles, fn ->
            # TODO: Remove when nessary, this is for testing purposes
            Process.sleep(2000)
            {:ok, %{featured_raffles: Raffles.featured(raffle)}}
            # {:error, "Failed to load featured raffles"}
          end)
      end

    {:noreply, socket}
  end

  #
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="raffle-show">
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
          </section>
        </div>
        <div class="activity">
          <div class="left">
            <div :if={@raffle.status == :open}>
              <%= if @current_scope do %>
                <.form for={@form} id="ticket-form" phx-submit="save">
                  <.input field={@form[:comment]} placeholder="comment" autofocus />
                  <.button>Get A Ticket</.button>
                </.form>
              <% end %>
            </div>

            <div :if={@tickets} class="mt-4">
              <h4 class="font-semibold text-lg mb-2">Your Tickets</h4>
              <ul class="space-y-2">
                <li :for={ticket <- @tickets} class="border-b grid grid-cols-2 items-center">
                  <div>
                    {ticket.comment}
                  </div>
                  <div class="text-sm text-gray-500">
                    {Calendar.strftime(ticket.inserted_at, "%b %d %Y %H:%M:%S")}
                  </div>
                </li>
              </ul>
            </div>
          </div>
          <div class="right">
            <h4>Featured Raffles</h4>

            <.featured_raffles raffles={@featured_raffles} />
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end

  attr :raffles, :map, required: true

  def featured_raffles(assigns) do
    ~H"""
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
            <%!-- <Index.raffle_card raffle={raffle} /> --%>
            <img src={raffle.image_path} alt="Image" />
            {raffle.prize}
          </.link>
        </li>
      </ul>
    </.async_result>
    """
  end

  def handle_event("validate", %{"ticket" => ticket_params}, socket) do
    %{raffle: raffle, current_scope: scope} = socket.assigns
    ticket = %Ticket{user_id: scope.user.id, raffle_id: raffle.id}

    changeset = Tickets.change_ticket(ticket, ticket_params)

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"ticket" => ticket_params}, socket) do
    %{raffle: raffle, current_scope: scope} = socket.assigns

    case Tickets.create_ticket(scope.user, raffle, ticket_params) do
      {:ok, ticket} ->
        changeset = Tickets.change_ticket(%Ticket{})

        socket =
          assign(socket, form: to_form(changeset))
          |> put_flash(:info, "Your ticket #{ticket.id} has been created")

        {:noreply, socket}

      {:error, changeset} ->
        IO.inspect(changeset, label: "changeset error:")
        {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
    end
  end
end
