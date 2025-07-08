defmodule RaffleyWeb.RaffleLive.Index do
  use RaffleyWeb, :live_view

  alias Raffley.{Raffles, Charities}

  def mount(_params, _session, socket) do
    socket = assign(socket, charity_options: Charities.charity_with_slugs())

    {:ok, socket}
  end

  def handle_params(params, _url, socket) do
    socket =
      socket
      |> stream(:raffles, Raffles.filter_raffles(params), reset: true)
      |> assign(form: to_form(params))
      |> assign(page_title: "Raffles")

    {:noreply, socket}
  end

  def handle_event("filter", params, socket) do
    params =
      params
      |> Map.take(~w(q status charity order_by))
      |> Map.reject(fn {_, v} -> v == "" end)

    socket = push_patch(socket, to: ~p"/raffles?#{params}")

    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <%!-- <pre>
      <%= inspect(@form, pretty: true) %>
    </pre> --%>
    <Layouts.app flash={@flash}>
    <div class="raffle-index">
      <.banner :let={vibe} :if={false}>
        <.icon name="hero-sparkles-solid" /> Mistery Raffle comming soon! {vibe}
        <:details :let={vibe}>
          Win amazing prizes and support your favorite creators {vibe}
        </:details>
        <:details>
          Any guesses?
        </:details>
      </.banner>

      <.filter_form form={@form} charity_options={@charity_options} />

      <section>
        <div class="raffles" id="raffles" phx-update="stream">
          <.raffle_card :for={{dom_id, raffle} <- @streams.raffles} raffle={raffle} id={dom_id} />
        </div>
      </section>
    </div>
    </Layouts.app>
    """
  end

  attr :raffle, Raffles.Raffle, required: true
  attr :id, :string, required: true

  def raffle_card(assigns) do
    ~H"""
    <.link navigate={~p"/raffles/#{@raffle}"} id={@id}>
      <div class="card">
        <div class="charity">{@raffle.charity.name}</div>

        <img src={@raffle.image_path} alt="Image" />
        <h2>{@raffle.prize}</h2>
        <div class="details">
          <div class="price">${@raffle.ticket_price} / ticket</div>
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
      <.input field={@form[:q]} autocomplete="off" placeholder="Search..." phx-debounce="500" />
      <.input
        type="select"
        field={@form[:status]}
        prompt="Status"
        options={Raffles.Raffle.statuses()}
      />
      <.input type="select" prompt="Charity" options={@charity_options} field={@form[:charity]} />
      <.input
        type="select"
        field={@form[:order_by]}
        prompt="Order by"
        options={[
          "Name asc": :asc_prize,
          "Name desc": :desc_prize,
          "Ticket price asc": :asc_ticket_price,
          "Ticket price desc": :desc_ticket_price,
          "Charity asc": :asc_charity,
          "Charity desc": :desc_charity
        ]}
      />
      <.link patch={~p"/raffles"}>Reset</.link>
    </.form>
    """
  end
end
