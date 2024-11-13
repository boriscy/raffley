defmodule RaffeleyWeb.RaffleLive.Index do
  use RaffeleyWeb, :live_view

  alias Raffeley.Raffles

  def mount(_params, _session, socket) do
    socket = assign(socket, raffles: Raffles.list_raffles())

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="raffle-index">
      <h1>Raffles</h1>

      <section>
        <div class="raffles">
          <div :for={raffle <- @raffles} class="card">
            <img src={raffle.image_path} alt="Image" />
            <h2><%= raffle.prize %></h2>
            <div class="details">
              <div class="price">$<%= raffle.ticket_price %> / ticket</div>
              <div class="badge"><%= raffle.status %></div>
            </div>
          </div>
        </div>
      </section>
    </div>
    """
  end
end
