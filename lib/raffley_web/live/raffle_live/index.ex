defmodule RaffleyWeb.RaffleLive.Index do
  use RaffleyWeb, :live_view
  import RaffleyWeb.CustomComponents

  alias Raffley.Raffles

  def mount(_params, _session, socket) do
    socket =
      socket
      |> stream(:raffles, Raffles.list_raffles())
      |> assign(form: to_form(%{}))
      |> assign(page_title: "Raffles")

    # IO.inspect(socket.assigns.streams.raffles, label: "MOUNT")

    # socket =
    #   attach_hook(socket, :log_stream, :after_render, fn socket ->
    #     IO.inspect(socket.assigns.streams.raffles, label: "AFTER_RENDER")
    #     socket
    #   end)

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <%!-- <pre>
      <%= inspect(@form, pretty: true) %>
    </pre> --%>
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

      <.filter_form form={@form} />

      <section>
        <div class="raffles" id="raffles" phx-update="stream">
          <.raffle_card :for={{dom_id, raffle} <- @streams.raffles} raffle={raffle} id={dom_id} />
        </div>
      </section>
    </div>
    """
  end

  def handle_event("filter", params, socket) do
    socket =
      socket
      |> assign(form: to_form(params))
      |> stream(:raffles, Raffles.filter_raffles(params), reset: true)

    {:noreply, socket}
  end

  attr :raffle, Raffles.Raffle, required: true
  attr :id, :string, required: true

  def raffle_card(assigns) do
    ~H"""
    <.link navigate={~p"/raffles/#{@raffle}"} id={@id}>
      <div class="card">
        <img src={@raffle.image_path} alt="Image" />
        <h2><%= @raffle.prize %></h2>
        <div class="details">
          <div class="price">$<%= @raffle.ticket_price %> / ticket</div>
          <.badge status={@raffle.status} class="font-bold" id={"status-#{@raffle.id}"} />
        </div>
      </div>
    </.link>
    """
  end

  attr :form, :map, required: true

  def filter_form(assigns) do
    ~H"""
    <.form for={@form} phx-change="filter" id="filter-form">
      <.input field={@form[:q]} autocomplete="off" placeholder="Search..." />
      <.input
        type="select"
        field={@form[:status]}
        prompt="Status"
        options={Raffles.Raffle.statuses()}
      />
      <.input
        type="select"
        field={@form[:order_by]}
        prompt="Order by"
        options={[
          "Name asc": :asc_prize,
          "Name desc": :desc_prize,
          "Ticket price asc": :asc_ticket_price,
          "Ticket price desc": :desc_ticket_price
        ]}
      />
    </.form>
    """
  end
end
