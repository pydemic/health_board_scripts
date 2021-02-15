defmodule HBS.Dashboards.YAMLToCSV.Group do
  alias HBS.Dashboards.YAMLToCSV
  alias HBS.Dashboards.YAMLToCSV.{ParseElementHelper, ParseHelper}

  @groups_type 1

  defstruct data: nil,
            group: :elements,
            index: 0,
            row: [@groups_type],
            sid: nil

  @spec parse(YAMLToCSV.t()) :: YAMLToCSV.t()
  def parse(data) do
    # type sid name description component_module component_function component_params link_element_sid

    __MODULE__
    |> ParseHelper.setup_parser_struct(data, sid_required?: true, sid_as_cell?: true)
    |> ParseHelper.String.parse("name", required?: true)
    |> ParseElementHelper.parse_element_parent("dashboard_id", required?: true)
    |> ParseHelper.String.parse("description")
    |> ParseHelper.ModuleFunctionParams.parse("component", default: {["Element", "group"], nil})
    |> ParseHelper.String.parse("link_element_sid")
    |> ParseElementHelper.parse_element_indicators()
    |> ParseElementHelper.parse_element_sources()
    |> ParseElementHelper.parse_element_filters()
    |> ParseElementHelper.parse_element_data()
    |> parse_sections()
  end

  defp parse_sections(struct) do
    struct
    |> struct(data: ParseHelper.update_data(struct))
    |> ParseElementHelper.parse_element_relation("section", "sections", YAMLToCSV.Section, &section_data/3,
      required: true
    )
    |> Map.get(:data)
  end

  defp section_data(struct, section, _opts) do
    Map.merge(section, %{"group_id" => struct.index + 1, "parent_sid" => struct.sid})
  end
end
