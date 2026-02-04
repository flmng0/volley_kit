defmodule VolleyWeb.UserLive.Login do
  use VolleyWeb, :live_view

  alias Volley.Accounts

  defp render_intro(assigns) do
    ~H"""
    <.button phx-click="choose_magic" variant="neutral" class="w-full">
      Log in with Email and Magic Link
    </.button>
    <div class="divider">or</div>
    <.button phx-click="choose_password" variant="neutral" class="w-full">
      Log in with Email and Password
    </.button>
    """
  end

  attr :form, :map, required: true
  attr :current_scope, :map, default: nil

  defp render_magic_form(assigns) do
    ~H"""
    <.form
      :let={f}
      for={@form}
      id="login_form_magic"
      action={~p"/users/log-in"}
      phx-submit="submit_magic"
    >
      <.input
        readonly={Accounts.known_user?(@current_scope)}
        field={f[:email]}
        type="email"
        label="Email"
        autocomplete="username"
        required
        phx-mounted={JS.focus()}
      />
      <.button class="btn btn-primary w-full">
        Log in <span aria-hidden="true">→</span>
      </.button>
    </.form>

    <div class="divider">or</div>

    <.button phx-click="choose_password" variant="neutral" class="w-full">
      Use Email and Password
    </.button>
    """
  end

  attr :form, :map, required: true
  attr :trigger_submit, :boolean
  attr :current_scope, :map, default: nil

  defp render_password_form(assigns) do
    ~H"""
    <.form
      :let={f}
      for={@form}
      id="login_form_password"
      action={~p"/users/log-in"}
      phx-submit="submit_password"
      phx-trigger-action={@trigger_submit}
    >
      <.input
        readonly={Accounts.known_user?(@current_scope)}
        field={f[:email]}
        type="email"
        label="Email"
        autocomplete="username"
        required
      />
      <.input
        field={@form[:password]}
        type="password"
        label="Password"
        autocomplete="current-password"
      />
      <.input field={@form[:remember_me]} type="checkbox" label="Stay logged in on this device?" />
      <.button variant="primary" class="w-full">
        Log in <span aria-hidden="true">→</span>
      </.button>
    </.form>

    <div class="divider">or</div>

    <.button variant="neutral" class="w-full" phx-click="choose_magic">
      Use Email and Magic Link
    </.button>
    """
  end

  defp render_magic_submitted(assigns) do
    ~H"""
    <div class="alert alert-success">
      <.icon name="hero-check-circle" class="size-6 shrink-0" />
      <div>
        <p>Log in requested successfully.</p>
        <p>If your email is in our system, you will receive instructions for logging in shortly.</p>
      </div>
    </div>
    """
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="mx-auto max-w-sm space-y-4">
        <div class="text-center">
          <.header>
            <p>Log in</p>
            <:subtitle>
              <%= if Accounts.known_user?(@current_scope) do %>
                You need to reauthenticate to perform sensitive actions on your account.
              <% else %>
                Don't have an account? <.link
                  navigate={~p"/users/register"}
                  class="font-semibold text-brand hover:underline"
                  phx-no-format
                >Sign up</.link> for an account now.
              <% end %>
            </:subtitle>
          </.header>
        </div>

        <div :if={local_mail_adapter?()} class="alert alert-info">
          <.icon name="hero-information-circle" class="size-6 shrink-0" />
          <div>
            <p>You are running the local mail adapter.</p>
            <p>
              To see sent emails, visit <.link href="/dev/mailbox" class="underline">the mailbox page</.link>.
            </p>
          </div>
        </div>

        <.render_intro :if={@state == :intro} />
        <.render_magic_form :if={@state == :magic} form={@form} current_scope={@current_scope} />
        <.render_password_form
          :if={@state == :password}
          form={@form}
          current_scope={@current_scope}
          trigger_submit={@trigger_submit}
        />
        <.render_magic_submitted :if={@state == :magic_submitted} />
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    email =
      Phoenix.Flash.get(socket.assigns.flash, :email) ||
        get_in(socket.assigns, [:current_scope, Access.key(:user), Access.key(:email)])

    form = to_form(%{"email" => email}, as: "user")

    {:ok, assign(socket, form: form, trigger_submit: false, state: :intro)}
  end

  @impl true
  def handle_event("submit_password", _params, socket) do
    {:noreply, assign(socket, :trigger_submit, true)}
  end

  def handle_event("submit_magic", %{"user" => %{"email" => email}}, socket) do
    if user = Accounts.get_user_by_email(email) do
      Accounts.deliver_login_instructions(
        user,
        &url(~p"/users/log-in/#{&1}")
      )
    end

    {:noreply, assign(socket, :state, :magic_submitted)}
  end

  def handle_event("choose_magic", _params, socket) do
    {:noreply, assign(socket, :state, :magic)}
  end

  def handle_event("choose_password", _params, socket) do
    {:noreply, assign(socket, :state, :password)}
  end

  defp local_mail_adapter? do
    Application.get_env(:volley, Volley.Mailer)[:adapter] == Swoosh.Adapters.Local
  end
end
