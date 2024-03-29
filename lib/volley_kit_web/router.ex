defmodule VolleyKitWeb.Router do
  use VolleyKitWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {VolleyKitWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers

    plug VolleyKitWeb.SessionUser
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", VolleyKitWeb do
    pipe_through :browser

    live "/", HomeLive
  end

  scope "/", VolleyKitWeb do
    pipe_through :browser

    # Temporary. TODO: Figure out a nice way to make this into a live form.
    get "/join", PageController, :join

    live "/current", MatchLive, :current
    live "/:code", MatchLive, :code
  end

  # Other scopes may use custom stacks.
  # scope "/api", VolleyKitWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:volley_kit, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: VolleyKitWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
