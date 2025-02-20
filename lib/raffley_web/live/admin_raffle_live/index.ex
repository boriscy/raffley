defmodule RaffleyWeb.AdminRaffleLive.Index do
  use RaffleyWeb, :live_view
  use Gettext, backend: RaffleyWeb.Gettext
  alias Raffley.{Admin}

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(page_title: "Listing Raffles")
      |> stream(:raffles, Admin.list_raffles())

    {:ok, socket}
  end

  def handle_event("delete", %{"id" => id}, socket) do
    case Admin.delete_raffle(id) do
      {:ok, _} ->
        socket =
          socket
          |> put_flash(:info, gettext("Raffle deleted successfully"))
          |> push_navigate(to: "/admin/raffles")

        {:noreply, socket}

      {:error, _} ->
        socket =
          socket
          |> put_flash(:error, gettext("Error deleting raffle"))

        {:noreply, socket}
    end
  end

  def render(assigns) do
    ~H"""
    <div class="admin-index">
      <.button phx-click={
        JS.toggle(
          to: "#joke",
          in: {"ease-in-out duration-300", "opacity-0", "opacity-100"},
          out: {"ease-in-out duration-300", "opacity-100", "opacity-0"},
          time: 300
        )
      }>
        Toggle Joke
      </.button>

      <div id="joke" class="joke hidden">
        What's a tree's favorite drink?
      </div>
      <.header>
        {@page_title}
        <:actions>
          <.link navigate={~p"/admin/raffles/new"} class="button">{gettext("New Raffle")}</.link>
        </:actions>
      </.header>

      <.table
        id="raffles-list"
        rows={@streams.raffles}
        row_click={fn {_, raffle} -> JS.navigate(~p"/raffles/#{raffle}") end}
      >
        <:col :let={{_dom_id, raffle}} label="Prize">
          <.link navigate={~p"/raffles/#{raffle}"} class="font-semibold">
            {raffle.prize}
          </.link>
        </:col>
        <:col :let={{_dom_id, raffle}} label="Status">
          <.badge status={raffle.status} class="font-bold" />
        </:col>
        <:col :let={{_dom_id, raffle}} label="Ticket Price">
          {raffle.ticket_price}
        </:col>

        <:action :let={{_dom_id, raffle}}>
          <.link navigate={~p"/admin/raffles/#{raffle}/edit"}>Edit</.link>
        </:action>
        <:action :let={{dom_id, raffle}}>
          <.link
            phx-click={delete_and_hide(dom_id, raffle)}
            data-confirm="Are you sure to delete the raffle?"
          >
            Delete
          </.link>
        </:action>
      </.table>
    </div>
    """
  end

  # def delete_and_hide(dom_id, raffle) do
  #   JS.push("delete", value: %{id: raffle.id})
  #   |> JS.hide(to: "##{dom_id}", transition: "fade-out")
  # end
end
