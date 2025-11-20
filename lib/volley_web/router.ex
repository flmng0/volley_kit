defmodule VolleyWeb.Router do
  use VolleyWeb, :router

  import VolleyWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {VolleyWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :put_anonymous_user_id
    plug :fetch_current_scope_for_user
    plug :fetch_current_scope_for_anonymous_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", VolleyWeb do
    pipe_through :browser

    live_session :mount_user,
      on_mount: [{VolleyWeb.UserAuth, :mount_current_scope}] do
      live "/", HomeLive
      live "/scratch/:id", ScratchMatchLive
      live "/scratch/:id/share", ScratchMatchLive, :share
      live "/scratch/:id/reset", ScratchMatchLive, :reset
    end
  end

  scope "/", VolleyWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :tournament,
      on_mount: [{VolleyWeb.UserAuth, :require_authenticated}] do
      live "/tournament/", TournamentLive, :index
      live "/tournament/new", TournamentLive, :new
      live "/tournament/:id", TournamentLive, :view
    end
  end

  import Phoenix.LiveDashboard.Router

  scope "/admin" do
    pipe_through [:browser, :require_admin_user]

    live_dashboard "/dashboard",
      metrics: VolleyWeb.Telemetry,
      on_mount: [{VolleyWeb.UserAuth, :require_admin_user}]
  end

  # Other scopes may use custom stacks.
  # scope "/api", VolleyWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:volley, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).

    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", VolleyWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{VolleyWeb.UserAuth, :require_authenticated}] do
      live "/users/settings", UserLive.Settings, :edit
      live "/users/settings/confirm-email/:token", UserLive.Settings, :confirm_email
    end

    post "/users/update-password", UserSessionController, :update_password
  end

  scope "/", VolleyWeb do
    pipe_through [:browser]

    live_session :current_user,
      on_mount: [{VolleyWeb.UserAuth, :mount_current_scope}] do
      live "/users/register", UserLive.Registration, :new
      live "/users/log-in", UserLive.Login, :new
      live "/users/log-in/:token", UserLive.Confirmation, :new
    end

    post "/users/log-in", UserSessionController, :create
    delete "/users/log-out", UserSessionController, :delete
  end
end
