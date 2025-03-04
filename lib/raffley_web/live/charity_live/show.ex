defmodule RaffleyWeb.CharityLive.Show do
  use RaffleyWeb, :live_view

  alias Raffley.Charities

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      Charity {@charity.id}
      <:subtitle>This is a charity record from your database.</:subtitle>
      <:actions>
        <.button phx-click={JS.dispatch("click", to: {:inner, "a"})}>
          <.link navigate={~p"/charities/#{@charity}/edit?return_to=show"}>
            Edit charity
          </.link>
        </.button>
      </:actions>
    </.header>

    <.list>
      <:item title="Name">{@charity.name}</:item>
      <:item title="Slug">{@charity.slug}</:item>
    </.list>

    <.back navigate={~p"/charities"}>Back to charities</.back>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Show Charity")
     |> assign(:charity, Charities.get_charity!(id))}
  end
end
