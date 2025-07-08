defmodule RaffleyWeb.RaffleLive.Show do
  use RaffleyWeb, :live_view
  import RaffleyWeb.CustomComponents
  alias Raffley.Raffles
  alias Raffley.Repo

  # Can mount the user in any live_view
  # on_mount {RaffleyWeb.UserAuth, :mount_current_scope}

  def mount(_params, _session, socket) do
    socket = assign(socket, form: to_form(%{}))
    {:ok, socket}
  end

  def handle_params(%{"id" => id}, _uri, socket) do
    socket =
      case Raffles.get_raffle!(id) do
        nil ->
          put_flash(socket, :error, "Raffle not found")
          |> push_navigate(to: "/raffles")

        raffle ->
          assign(socket, raffle: Repo.preload(raffle, :charity), page_title: raffle.prize)
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
          <%= if @current_scope do %>
            <.form for={@form} id="ticket-form">
              <.input field={@form[:comment]} placeholder="comment" autofocus />
              <.button>Get A Ticket</.button>
            </.form>
          <% end %>
        </div>
        <div class="right">
          <h4>Featured Raffles</h4>

          <.featured_raffles raffles={@featured_raffles} />
        </div>
      </div>
    </div>
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
end
