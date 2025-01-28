defmodule RaffleyWeb.SvelteLive.Index do
  use RaffleyWeb, :live_view

  def mount(_params, _session, socket) do
    # if connected?(socket) do
    #   Process.send_after(self(), :tick, 2000)
    # end
    socket = assign(socket, raffles: Raffley.Raffles.list_raffles(), page_title: "Estimator")
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="estimator">
      <h1>Raffle Estimator</h1>
      <.svelte
        name="Example"
        props={
          %{
            raffles:
              Enum.map(
                @raffles,
                &Map.take(&1, [:id, :status, :prize, :description, :ticket_price, :image_path])
              )
          }
        }
        socket={@socket}
      />
    </div>
    """
  end
end
