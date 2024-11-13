defmodule RaffeleyWeb.EstimatorLive do
  use RaffeleyWeb, :live_view

  def mount(_params, _session, socket) do
    socket = assign(socket, tickets: 0, price: 3)
    IO.inspect(self(), label: "MOUNT")
    {:ok, socket}
  end

  def render(assigns) do
    IO.inspect(self(), label: "RENDER")

    ~H"""
    <div class="estimator">
      <h1>Raffle Estimator</h1>

      <section>
        <button phx-click="update-ticket" phx-value-ticket="+">+</button>
        <button phx-click="update-ticket" phx-value-ticket="-">-</button>
        <div>
          <%= @tickets %>
          <%!-- <.input type="number" min="0" max="100" value={"#{@tickets}"} name="tickets" /> --%>
        </div>
        @
        <div>
          $<%= @price %>
          <%!-- <.input type="number" min="0" max="1000" value={"#{@price}"} name="price" /> --%>
        </div>
        <div>
          Total: $<%= @tickets * @price %>
        </div>
      </section>
    </div>
    """
  end

  def handle_event("update-ticket", params, socket) do
    tickets = socket.assigns.tickets
    IO.inspect(self(), label: "EVENT 💥")

    tickets =
      case params do
        %{"ticket" => "+"} ->
          tickets + 1

        %{"ticket" => "-"} ->
          if tickets > 0, do: tickets - 1, else: tickets

        _ ->
          tickets
      end

    {:noreply, assign(socket, tickets: tickets)}
  end
end
