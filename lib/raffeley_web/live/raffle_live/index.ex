defmodule RaffeleyWeb.RaffleLive.Index do
  use RaffeleyWeb, :live_view

  alias Raffeley.Raffles

  def mount(_params, _session, socket) do
    socket = assign(socket, raffles: Raffles.list_raffles(), page_title: "Raffles")

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="raffle-index">
      <.banner :let={vibe} :if={false}>
        <.icon name="hero-sparkles-solid" /> Mistery Raffle comming soon! <%= vibe %>
        <:details :let={vibe}>
          Win amazing prizes and support your favorite creators <%= vibe %>
        </:details>
        <:details>
          Any guesses?
        </:details>
      </.banner>
      <section>
        <div class="raffles">
          <.raffle_card :for={raffle <- @raffles} raffle={raffle} />
        </div>
      </section>
    </div>
    """
  end

  def raffle_card(assigns) do
    ~H"""
    <div class="card">
      <img src={@raffle.image_path} alt="Image" />
      <h2><%= @raffle.prize %></h2>
      <div class="details">
        <div class="price">$<%= @raffle.ticket_price %> / ticket</div>
        <.badge status={@raffle.status} class="font-bold" id={"status-#{@raffle.id}"} />
      </div>
    </div>
    """
  end
end
