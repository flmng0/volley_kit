defmodule Volley.Scoresheets.Scoresheet do
  use Ecto.Schema

  alias Volley.Scoresheets.SetSummary

  @primary_key false
  embedded_schema do
    embeds_many :set_results, SetSummary
  end
end
