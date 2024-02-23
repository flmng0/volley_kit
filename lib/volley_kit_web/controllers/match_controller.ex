defmodule VolleyKitWeb.MatchController do
  use VolleyKitWeb, :controller

  alias VolleyKit.Manager

  def new(conn, _params) do
    user_id = VolleyKitWeb.SessionUser.get_user(conn)

    case Manager.get_owned_match(user_id) do
      nil ->
        %{"team-a-name" => team_a_name, "team-b-name" => team_b_name} = conn.body_params

        case Manager.create_match(%{
               owner: user_id,
               team_a: %{name: team_a_name},
               team_b: %{name: team_b_name}
             }) do
          {:ok, match} ->
            redirect(conn, to: ~p"/match/#{match.id}")

          {:error, %Ecto.Changeset{} = _changeset} ->
            IO.inspect(_changeset)
            conn
            |> put_flash(:error, "Unable to create match. Unknown error occurred.")
            |> redirect(to: ~p"/")
        end

      owned_match ->
        team_a_name = owned_match.team_a.name
        team_b_name = owned_match.team_b.name

        conn
        |> put_flash(
          :error,
          "You already have a match in progress! Showing #{team_a_name} vs. #{team_b_name}"
        )
        |> redirect(to: ~p"/match/#{owned_match.id}")
    end
  end

  def delete(conn, %{"id" => id}) do
    match = Manager.get_match!(id)
    user_id = VolleyKitWeb.SessionUser.get_user(conn)

    team_a_name = match.team_a.name
    team_b_name = match.team_b.name

    conn =
      if match.owner == Ecto.UUID.cast!(user_id) do
        case Manager.delete_match(match) do
          {:ok, _match} ->
            put_flash(
              conn,
              :success,
              "Successfully deleted match: #{team_a_name} vs. #{team_b_name}"
            )

          {:error, %Ecto.Changeset{} = _changeset} ->
            put_flash(conn, :error, "Unable to delete match! Unknown error occurred.")
        end
      else
        put_flash(conn, :info, "No match found to delete...")
      end

    redirect(conn, to: ~p"/")
  end

  def join(conn, _params) do
    IO.inspect(conn.body_params)

    redirect(conn, to: ~p"/")
  end
end
