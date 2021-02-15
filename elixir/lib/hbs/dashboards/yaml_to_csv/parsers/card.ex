defmodule HBS.Dashboards.YAMLToCSV.Card do
  alias HBS.Dashboards.YAMLToCSV
  alias HBS.Dashboards.YAMLToCSV.{ParseElementHelper, ParseHelper}

  @cards_type 3

  defstruct data: nil,
            group: :elements,
            index: 0,
            row: [@cards_type],
            sid: nil

  @spec parse(YAMLToCSV.t()) :: YAMLToCSV.t()
  def parse(data) do
    # type sid name description component_module component_function component_params link_element_sid

    __MODULE__
    |> ParseHelper.setup_parser_struct(data, sid_required?: true, sid_as_cell?: true)
    |> ParseHelper.String.parse("name", required?: true)
    |> ParseElementHelper.parse_element_parent("section_id", required?: true)
    |> ParseHelper.String.parse("description")
    |> ParseHelper.ModuleFunctionParams.parse("component", default: {["Element", "card"], nil})
    |> ParseHelper.String.parse("link_element_sid")
    |> ParseElementHelper.parse_element_indicators()
    |> ParseElementHelper.parse_element_sources()
    |> ParseElementHelper.parse_element_filters()
    |> ParseElementHelper.parse_element_data()
    |> ParseHelper.update_data()
  end
end
