defmodule RaffleyWeb.AdminRaffleLive.Form do
  use RaffleyWeb, :live_view
  alias Raffley.{Admin, Raffles.Raffle}

  def mount(params, _session, socket) do
    socket = apply_action(socket, socket.assigns.live_action, params)

    {:ok, socket}
  end

  defp apply_action(socket, :new, _params) do
    raffle = %Raffle{}

    socket
    |> assign(page_title: "New Raffle")
    |> assign(form: to_form(Admin.change_raffle(raffle)))
    |> assign(raffle: raffle)
  end

  defp apply_action(socket, :edit, params) do
    raffle = Admin.get_raffle!(params["id"])

    socket
    |> assign(page_title: "Edit Raffle")
    |> assign(form: to_form(Admin.change_raffle(raffle)))
    |> assign(raffle: raffle)
  end

  def handle_event("save", %{"raffle" => params}, socket) do
    save_raffle(socket, socket.assigns.live_action, params)
  end

  def handle_event("validate", %{"raffle" => params}, socket) do
    changeset = Admin.change_raffle(socket.assigns.raffle, params)
    socket = socket |> assign(form: to_form(changeset, action: :validate))

    {:noreply, socket}
  end

  defp save_raffle(socket, :new, params) do
    case Admin.create_raffle(params) do
      {:ok, _raffle} ->
        socket =
          socket
          |> put_flash(:info, "Raffle created successfully")
          |> push_navigate(to: "/admin/raffles")

        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        socket =
          socket
          |> put_flash(:error, "Error creating raffle")
          |> assign(form: to_form(changeset, as: "raffle"))

        {:noreply, socket}
    end
  end

  defp save_raffle(socket, :edit, params) do
    case Admin.update_raffle(socket.assigns.raffle, params) do
      {:ok, _raffle} ->
        socket =
          socket
          |> put_flash(:info, gettext("Raffle updated successfully"))
          |> push_navigate(to: "/admin/raffles")

        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        socket =
          socket
          |> put_flash(:error, "Error updating raffle")
          |> assign(form: to_form(changeset, as: "raffle"))

        {:noreply, socket}
    end
  end

  def render(assigns) do
    ~H"""
    <.header>
      {@page_title}
    </.header>
    <.simple_form for={@form} id="raffle-form" phx-submit="save" phx-change="validate">
      <.input field={@form[:prize]} label="Prize" phx-debounce="blur" />
      <.input
        field={@form[:description]}
        type="textarea"
        label={gettext("Description")}
        phx-debounce="blur"
      />
      <.input field={@form[:ticket_price]} type="number" label={gettext("Ticket Price")} />
      <.input
        type="select"
        field={@form[:status]}
        label={gettext("Status")}
        prompt={gettext("Chooose status")}
        options={Raffle.statuses()}
      />

      <.input field={@form[:image_path]} label={gettext("Image path")} />

      <:actions>
        <.button phx-disable-with="Saving...">
          <%= if assigns.live_action == :new do %>
            {gettext("Create Raffle")}
          <% else %>
            {gettext("Update Raffle")}
          <% end %>
        </.button>
      </:actions>
    </.simple_form>

    <.back navigate={~p"/admin/raffles"}>Back</.back>
    """
  end
end
