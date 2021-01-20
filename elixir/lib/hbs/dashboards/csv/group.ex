defmodule HBS.Dashboards.CSV.Group do
  alias HBS.Dashboards.CSV
  alias HBS.Dashboards.CSV.{ParseElementHelper, ParseHelper}

  @groups_context 1

  defstruct data: nil,
            group: :elements,
            index: 0,
            row: [@groups_context],
            row_alias: nil

  @spec parse(CSV.t()) :: CSV.t()
  def parse(data) do
    __MODULE__
    |> ParseHelper.setup_parsing_struct(data)
    |> ParseHelper.parse_string("name", required?: true)
    |> ParseElementHelper.parse_element_parent("dashboard_id", required?: true)
    |> ParseHelper.parse_string("description")
    |> ParseHelper.parse_module_function("component", default: {["Element", "group"], nil})
    |> ParseHelper.parse_relation_alias("link", :elements)
    |> ParseElementHelper.parse_element_indicators()
    |> ParseElementHelper.parse_element_sources()
    |> ParseElementHelper.parse_element_filters()
    |> ParseElementHelper.parse_element_data()
    |> parse_sections()
  end

  defp parse_sections(struct) do
    struct
    |> struct(data: ParseHelper.update_data(struct))
    |> ParseElementHelper.parse_element_relation("section", "sections", CSV.Section, &section_data/3, required: true)
    |> Map.get(:data)
  end

  defp section_data(struct, section, _opts) do
    Map.put(section, "group_id", struct.index)
  end
end
