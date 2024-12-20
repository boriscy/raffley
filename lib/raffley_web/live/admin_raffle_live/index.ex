defmodule RaffleyWeb.AdminRaffleLive.Index do
  use RaffleyWeb, :live_view
  alias Raffley.{Admin}

  def mount(_params, _session, socket) do
    socket = socket |> assign(page_title: "Listing Raffles")
      |> stream(:raffles, Admin.list_raffles())

    {:ok, socket}
  end

  def handle_event("delete", %{"id" => id}, socket) do
    case Admin.delete_raffle(id) do
      {:ok, _} ->
        socket = socket
        |> put_flash(:info, gettext("Raffle deleted successfully"))
        |> push_navigate(to: "/admin/raffles")

        {:noreply, socket}
      {:error, _} ->
        socket = socket
          |> put_flash(:error, gettext("Error deleting raffle"))
        {:noreply, socket}
    end
  end

  def render(assigns) do
    ~H"""
    <div class="admin-index">
      <.header>
        {@page_title}
        <:actions>
          <.link navigate={~p"/admin/raffles/new"} class="button">{gettext("New Raffle")}</.link>
        </:actions>
      </.header>

      <.table id="raffles-list" rows={@streams.raffles}>
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
          <div class="flex gap-4">
            <.link navigate={~p"/admin/raffles/#{raffle}/edit"}>Edit</.link>
            <.link phx-click="delete" phx-value-id={raffle.id} data-confirm="Are you sure to delete the raffle">Delete</.link>
          </div>
        </:action>
      </.table>
    </div>
    """
  end

end
