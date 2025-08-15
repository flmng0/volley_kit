defmodule Volley.Workers.CleanupWorker do
  use Oban.Worker, queue: :cleanup

  import Ecto.Query, only: [from: 2]

  @impl true
  def perform(%Oban.Job{} = job) do
    %{
      before: [n, interval]
    } = job.args

    query =
      from m in Volley.Scoring.Match,
        where: m.updated_at > ago(^n, ^interval) and is_nil(m.owner_id)

    Volley.Repo.delete_all(query)

    :ok
  end
end
