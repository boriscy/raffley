defmodule RaffleyWeb.Router do
  use RaffleyWeb, :router

  import RaffleyWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {RaffleyWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_scope_for_user
    plug :spy
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :chromeless_layout do
    plug :put_layout, false
    # plug :put_root_layout, html: {RaffleyWeb.Layouts, :chromeless}
  end

  def spy(conn, _opts) do
    greeting = ~w(Hola Bienvenido) |> Enum.random()

    conn = assign(conn, :greeting, greeting)
    # IO.inspect(conn)

    conn
  end

  scope "/", RaffleyWeb do
    pipe_through :browser

    # get "/", PageController, :home
    get "/rules", RuleController, :index
    get "/rules/:id", RuleController, :show

    live_session :current_user_public, on_mount: [{RaffleyWeb.UserAuth, :mount_current_scope}] do
      live "/", RaffleLive.Index
      live "/estimator", EstimatorLive
      live "/raffles", RaffleLive.Index
      live "/raffles/:id", RaffleLive.Show

      live "/admin/raffles", AdminRaffleLive.Index
      live "/admin/raffles/:id/edit", AdminRaffleLive.Form, :edit
      live "/admin/raffles/new", AdminRaffleLive.Form, :new

      live "/charities", CharityLive.Index, :index
      live "/charities/new", CharityLive.Form, :new
      live "/charities/:id", CharityLive.Show, :show
      live "/charities/:id/edit", CharityLive.Form, :edit
    end
  end

  # Other scopes may use custom stacks.
  scope "/api", RaffleyWeb.Api do
    pipe_through :api

    get "/raffles", RaffleController, :index
    get "/raffles/:id", RaffleController, :show
    post "/raffles", RaffleController, :create
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:raffley, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: RaffleyWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", RaffleyWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{RaffleyWeb.UserAuth, :require_authenticated}] do
      live "/users/settings", UserLive.Settings, :edit
      live "/users/settings/confirm-email/:token", UserLive.Settings, :confirm_email
    end

    post "/users/update-password", UserSessionController, :update_password
  end

  scope "/", RaffleyWeb do
    pipe_through [:browser]

    live_session :current_user,
      on_mount: [{RaffleyWeb.UserAuth, :mount_current_scope}] do
      live "/users/register", UserLive.Registration, :new

      live "/users/log-in", UserLive.Login, :new

      live "/users/log-in/:token", UserLive.Confirmation, :new
    end

    post "/users/log-in", UserSessionController, :create
    delete "/users/log-out", UserSessionController, :delete
  end
end
