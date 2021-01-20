defmodule HBS.Dashboards.CSV.Dashboard do
  alias HBS.Dashboards.CSV
  alias HBS.Dashboards.CSV.{ParseElementHelper, ParseHelper}

  @dashboards_context 0

  defstruct data: nil,
            group: :elements,
            index: 0,
            row: [@dashboards_context],
            row_alias: nil

  @spec parse(CSV.t()) :: CSV.t()
  def parse(data) do
    __MODULE__
    |> ParseHelper.setup_parsing_struct(data)
    |> ParseHelper.parse_string("name", required?: true)
    |> ParseHelper.parse_string("description")
    |> ParseHelper.parse_module_function("component", default: {["Element", "dashboard"], nil})
    |> ParseHelper.parse_relation_alias("link", :elements)
    |> ParseElementHelper.parse_element_data()
    |> ParseElementHelper.parse_element_filters()
    |> ParseElementHelper.parse_element_indicators()
    |> ParseElementHelper.parse_element_sources()
    |> parse_groups()
  end

  defp parse_groups(struct) do
    struct
    |> struct(data: ParseHelper.update_data(struct))
    |> ParseElementHelper.parse_element_relation("group", "groups", CSV.Group, &group_data/3, required: true)
    |> Map.get(:data)
  end

  defp group_data(struct, group, _opts) do
    Map.put(group, "dashboard_id", struct.index)
  end
end
