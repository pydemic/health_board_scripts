defmodule HBS.Dashboards.CSV.Card do
  alias HBS.Dashboards.CSV
  alias HBS.Dashboards.CSV.{ParseElementHelper, ParseHelper}

  @cards_context 3

  defstruct data: nil,
            group: :elements,
            index: 0,
            row: [@cards_context],
            row_alias: nil

  @spec parse(CSV.t()) :: CSV.t()
  def parse(data) do
    __MODULE__
    |> ParseHelper.setup_parsing_struct(data)
    |> ParseHelper.parse_string("name", required?: true)
    |> ParseElementHelper.parse_element_parent("section_id", required?: true)
    |> ParseHelper.parse_string("description")
    |> ParseHelper.parse_module_function("component", default: {["Element", "card"], nil})
    |> ParseHelper.parse_relation_alias("link", :elements)
    |> ParseElementHelper.parse_element_indicators()
    |> ParseElementHelper.parse_element_sources()
    |> ParseElementHelper.parse_element_filters()
    |> ParseElementHelper.parse_element_data()
    |> ParseHelper.update_data()
  end
end
