defmodule HBS.Dashboards.CSV.Indicator do
  alias HBS.Dashboards.CSV
  alias HBS.Dashboards.CSV.ParseHelper

  defstruct data: nil,
            group: :indicators,
            index: 0,
            row: [],
            row_alias: nil

  @spec parse(CSV.t()) :: CSV.t()
  def parse(data) do
    __MODULE__
    |> ParseHelper.setup_parsing_struct(data)
    |> ParseHelper.parse_string("description", required?: true)
    |> ParseHelper.parse_string("formula", required?: true)
    |> ParseHelper.parse_string("measurement_unit")
    |> ParseHelper.parse_uri("link")
    |> ParseHelper.update_data()
  end
end
