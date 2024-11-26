defmodule RaffleyWeb.RaffleLive.Show do
  use RaffleyWeb, :live_view
  import RaffleyWeb.CustomComponents
  # alias RaffleyWeb.RaffleLive.Index
  alias Raffley.Raffles

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(%{"id" => id}, _uri, socket) do
    socket =
      case Raffles.get_raffle!(id) do
        nil ->
          put_flash(socket, :error, "Raffle not found")
          |> push_navigate(to: "/raffles")

        raffle ->
          assign(socket, raffle: raffle, page_title: raffle.prize)
          |> assign(featured_raffles: Raffles.featured(raffle))
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
            <h2><%= @raffle.prize %></h2>
            <div class="price">
              <%= @raffle.ticket_price %> / ticket
            </div>
          </header>
          <div class="description">
            <%= @raffle.description %>
          </div>
        </section>
      </div>
      <div class="activity">
        <div class="left"></div>
        <div class="right">
          <h4>Featured Raffles</h4>
          <ul class="raffles">
            <.featured_raffles raffles={@featured_raffles} />
          </ul>
        </div>
      </div>
    </div>
    """
  end

  def featured_raffles(assigns) do
    ~H"""
    <li :for={raffle <- @raffles}>
      <.link navigate={~p"/raffles/#{raffle.id}"}>
        <%!-- <Index.raffle_card raffle={raffle} /> --%>
        <img src={raffle.image_path} alt="Image" />
        <%= raffle.prize %>
      </.link>
    </li>
    """
  end

  # def render(assigns) do
  #   ~H"""
  #   <div class="raffle-show">
  #     <Index.raffle_card raffle={@raffle} />
  #   </div>
  #   """
  # end
end
