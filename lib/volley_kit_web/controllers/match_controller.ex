defmodule VolleyKitWeb.MatchController do
  use VolleyKitWeb, :controller

  alias VolleyKit.Manager

  def new(conn, _params) do
    user_id = VolleyKitWeb.SessionUser.get_user(conn)
    %{ "team-a-name" => team_a_name, "team-b-name" => team_b_name } = conn.body_params

    case Manager.create_match(%{
      owner: user_id,
      team_a: %{ name: team_a_name },
      team_b: %{ name: team_b_name },
    }) do
      {:ok, match} ->
        redirect(conn, to: ~p"/match/#{match.id}")

      {:error, %Ecto.Changeset{} = _changeset} ->
        conn
        |> put_flash(:error, "Unable to create match. Unknown error occurred.")
        |> redirect(to: ~p"/")
    end
  end

  def join(conn, _params) do
    IO.inspect(conn.body_params)

    redirect(conn, to: ~p"/")
  end
end
