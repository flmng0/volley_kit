defmodule Volley.Seed do
  require Logger

  defp add_admin_user() do
    Logger.info("Creating admin user.")

    admin_email = Application.fetch_env!(:volley, :admin_email)

    if Volley.Accounts.get_user_by_email(admin_email) do
      Logger.info("User with email #{admin_email} already exists. Skipping.")
    else
      Logger.info("User with email #{admin_email} has been created, as admin.")
      Volley.Accounts.create_admin!(admin_email)
    end
  end

  def run() do
    add_admin_user()
  end
end
