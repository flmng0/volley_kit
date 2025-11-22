# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Volley.Repo.insert!(%Volley.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

require Logger

Logger.info("Creating admin user.")
admin_email = Application.fetch_env!(:volley, :admin_email)

if Volley.Accounts.get_user_by_email(admin_email) do
  Logger.info("User with email #{admin_email} already exists. Skipping.")
else
  Logger.info("User with email #{admin_email} has been created, as admin.")
  Volley.Accounts.create_admin!(admin_email)
end
