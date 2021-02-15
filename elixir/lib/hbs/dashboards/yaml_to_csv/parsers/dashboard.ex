defmodule HBS.Dashboards.YAMLToCSV.Dashboard do
  alias HBS.Dashboards.YAMLToCSV
  alias HBS.Dashboards.YAMLToCSV.{ParseElementHelper, ParseHelper}

  @dashboards_type 0

  defstruct data: nil,
            group: :elements,
            index: 0,
            row: [@dashboards_type],
            sid: nil

  @spec parse(YAMLToCSV.t()) :: YAMLToCSV.t()
  def parse(data) do
    # type sid name description component_module component_function component_params link_element_sid

    __MODULE__
    |> ParseHelper.setup_parser_struct(data, sid_required?: true, sid_as_cell?: true)
    |> ParseHelper.String.parse("name", required?: true)
    |> ParseHelper.String.parse("description")
    |> ParseHelper.ModuleFunctionParams.parse("component", default: {["Element", "dashboard"], nil})
    |> ParseHelper.String.parse("link_element_sid")
    |> ParseElementHelper.parse_element_data()
    |> ParseElementHelper.parse_element_filters()
    |> ParseElementHelper.parse_element_indicators()
    |> ParseElementHelper.parse_element_sources()
    |> parse_groups()
  end

  defp parse_groups(struct) do
    struct
    |> struct(data: ParseHelper.update_data(struct))
    |> ParseElementHelper.parse_element_relation("group", "groups", YAMLToCSV.Group, &group_data/3, required: true)
    |> Map.get(:data)
  end

  defp group_data(struct, group, _opts) do
    Map.merge(group, %{"dashboard_id" => struct.index + 1, "parent_sid" => struct.sid})
  end
end
