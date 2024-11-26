defmodule RaffleyWeb.EstimatorLive do
  use RaffleyWeb, :live_view

  def mount(_params, _session, socket) do
    # if connected?(socket) do
    #   Process.send_after(self(), :tick, 2000)
    # end

    socket = assign(socket, tickets: 0, price: 3, page_title: "Estimator")
    {:ok, socket}
  end

  def render(assigns) do
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

      <form phx-submit="set-price">
        <label>Tickets</label>
        <input type="number" name="tickets" value={@tickets} />
        <label>Price</label>
        <input type="number" name="price" value={@price} />

        <button type="submit">Update</button>
      </form>
    </div>
    """
  end

  def handle_info(:tick, socket) do
    if socket.assigns.tickets < 90 do
      IO.puts(socket.assigns.tickets)
      Process.send_after(self(), :tick, 2000)
    end

    {:noreply, update(socket, :tickets, &(&1 + 10))}
  end

  def handle_event("set-price", %{"price" => price, "tickets" => tickets}, socket) do
    {price, tickets} = {String.to_integer(price), String.to_integer(tickets)}
    socket = assign(socket, price: price, tickets: tickets)

    {:noreply, socket}
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
