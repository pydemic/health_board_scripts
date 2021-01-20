defmodule HBS.Dashboards.CSV.Source do
  alias HBS.Dashboards.CSV
  alias HBS.Dashboards.CSV.ParseHelper

  defstruct data: nil,
            group: :sources,
            index: 0,
            row: [],
            row_alias: nil

  @spec parse(CSV.t()) :: CSV.t()
  def parse(data) do
    __MODULE__
    |> ParseHelper.setup_parsing_struct(data)
    |> ParseHelper.parse_string("name", required?: true)
    |> ParseHelper.parse_string("description")
    |> ParseHelper.parse_uri("link")
    |> ParseHelper.parse_string("update_rate")
    |> ParseHelper.parse_date("extraction_date")
    |> ParseHelper.parse_date("last_update_date")
    |> ParseHelper.update_data()
  end
end
