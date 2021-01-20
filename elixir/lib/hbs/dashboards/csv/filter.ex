defmodule HBS.Dashboards.CSV.Filter do
  alias HBS.Dashboards.CSV
  alias HBS.Dashboards.CSV.ParseHelper

  defstruct data: nil,
            group: :filters,
            index: 0,
            row: [],
            row_alias: nil

  @spec parse(CSV.t()) :: CSV.t()
  def parse(data) do
    __MODULE__
    |> ParseHelper.setup_parsing_struct(data)
    |> ParseHelper.parse_string("title", required?: true)
    |> ParseHelper.parse_string("description")
    |> ParseHelper.parse_string("default")
    |> ParseHelper.parse_boolean("disabled")
    |> ParseHelper.parse_module_function("options", required?: true)
    |> ParseHelper.update_data()
  end
end
