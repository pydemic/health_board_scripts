defmodule HBS.Dashboards.CSV.ElementChild do
  alias HBS.Dashboards.CSV
  alias HBS.Dashboards.CSV.ParseHelper

  defstruct data: nil,
            group: :elements_children,
            index: 0,
            row: [],
            row_alias: nil

  @spec parse(CSV.t()) :: CSV.t()
  def parse(data) do
    __MODULE__
    |> ParseHelper.setup_parsing_struct(data)
    |> ParseHelper.parse_integer("parent_id", required?: true)
    |> ParseHelper.parse_integer("child_id", required?: true)
    |> ParseHelper.update_data()
  end
end
