defmodule HBS.Dashboards.CSV.ElementFilter do
  alias HBS.Dashboards.CSV
  alias HBS.Dashboards.CSV.ParseHelper

  defstruct data: nil,
            group: :elements_filters,
            index: 0,
            row: [],
            row_alias: nil

  @spec parse(CSV.t()) :: CSV.t()
  def parse(data) do
    __MODULE__
    |> ParseHelper.setup_parsing_struct(data)
    |> ParseHelper.parse_integer("element_id", required?: true)
    |> ParseHelper.parse_relation_alias("filter_alias", :filters, required?: true)
    |> ParseHelper.parse_module_function("options")
    |> ParseHelper.update_data()
  end
end
