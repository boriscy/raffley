defmodule RaffleyWeb.Layouts do
  @moduledoc """
  This module holds different layouts used by your application.

  See the `layouts` directory for all templates available.
  The "root" layout is a skeleton rendered as part of the
  application router. The "app" layout is set as the default
  layout on both `use RaffleyWeb, :controller` and
  `use RaffleyWeb, :live_view`.
  """
  use RaffleyWeb, :html
  use Gettext, backend: RaffleyWeb.Gettext

  @doc """
  Renders the app layout

  ## Examples

      <Layouts.app flash={@flash}>
        <h1>Content</h1>
      </Layout.app>

  """
  attr :flash, :map, required: true
  attr :current_scope, :map, default: nil
  slot :inner_block, required: true

  def app(assigns) do
    ~H"""
    <header>
      <div class="flex items-center justify-between border-b border-zinc-100 py-3 text-sm">
        <div class="flex items-center gap-4">
          <a href="/">
            <img src={~p"/images/raffley-logo.svg"} width="120" />
          </a>
        </div>
        <%!-- <.menu /> --%>
      </div>
    </header>

    <main>
      {render_slot(@inner_block)}
    </main>

    <.flash_group_live flash={@flash} />

    <footer>
    </footer>
    """
  end

  @doc """
  Shows the flash group with standard titles and content.

  ## Examples

      <.flash_group flash={@flash} />
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :id, :string, default: "flash-group", doc: "the optional id of flash container"

  def flash_group_live(assigns) do
    ~H"""
    <div id={@id} aria-live="polite">
      <.flash kind={:info} flash={@flash} />
      <.flash kind={:error} flash={@flash} />

      <.flash
        id="client-error"
        kind={:error}
        title={gettext("We can't find the internet")}
        phx-disconnected={show(".phx-client-error #client-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#client-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>

      <.flash
        id="server-error"
        kind={:error}
        title={gettext("Something went wrong!")}
        phx-disconnected={show(".phx-server-error #server-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#server-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>
    </div>
    """
  end

  def menu(assigns) do
    ~H"""
    <div class="flex items-center gap-4 font-semibold leading-6 text-zinc-900">
      <.link navigate={~p"/raffles"}>
        Raffles
      </.link>
      <.link navigate={~p"/estimator"}>
        Estimator
      </.link>
      <.link navigate={~p"/admin/raffles"}>
        Admin
      </.link>
      <.link navigate={~p"/charities"}>
        Charities
      </.link>
    </div>
    """
  end

  embed_templates "layouts/*"
end
