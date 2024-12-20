defmodule RaffleyWeb.AdminRaffleLive.Index do
  use RaffleyWeb, :live_view
  alias Raffley.{Admin, Raffles.Raffle}

  def mount(_params, _session, socket) do
    socket = socket |> assign(page_title: "Listing Raffles")
      |> stream(:raffles, Admin.list_raffles())

    {:ok, socket}
  end

  def handle_event("delete", _params, socket) do
    #IO.inspect(Repo.get(Raffle, id))
    #{:ok, _} = Admin.delete_raffle(id)
    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="admin-index">
      <.header>
        {@page_title}
        <:actions>
          <.link navigate={~p"/admin/raffles/new"} class="button">New Raffle</.link>
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
          <.link navigate={~p"/admin/raffles/#{raffle}/edit"}>Edit</.link>
          <%!-- <.link id={"del-#{raffle.id}"} phx-click="delete" phx-value_id={raffle} data={[confirm: "Are you sure to delete the raffle"]} >Delete</.link> --%>
        </:action>
      </.table>
    </div>
    """
  end

  # attr :raffle, Raffle, required: true
  # def raffle(assigns) do
  #   ~H"""
  #   <tr>
  #     <td>
  #       <.link  navigate={~p"/admin/raffles/#{@raffle.id}"} class="font-semibold">
  #         {@raffle.prize}
  #       </.link>
  #     </td>
  #     <td>
  #       <.badge status={@raffle.status} class="font-bold" id={"status-#{@raffle.id}"} />
  #     </td>
  #     <td>
  #       {@raffle.ticket_price}
  #     </td>
  #     <td>
  #       <.link navigate={~p"/admin/raffles/#{@raffle.id}/edit"}  >Edit</.link>
  #       <.link phx-click="delete" phx-value_id={@raffle.id} data={[confirm: "Are you sure to delete the raffle"]} >Delete</.link>
  #     </td>
  #   </tr>
  #   """
  # end
end
