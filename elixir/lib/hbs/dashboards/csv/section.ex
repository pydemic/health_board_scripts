defmodule HBS.Dashboards.CSV.Section do
  alias HBS.Dashboards.CSV
  alias HBS.Dashboards.CSV.{ParseElementHelper, ParseHelper}

  @sections_context 2

  defstruct data: nil,
            group: :elements,
            index: 0,
            row: [@sections_context],
            row_alias: nil

  @spec parse(CSV.t()) :: CSV.t()
  def parse(data) do
    __MODULE__
    |> ParseHelper.setup_parsing_struct(data)
    |> ParseHelper.parse_string("name", required?: true)
    |> ParseElementHelper.parse_element_parent("group_id", required?: true)
    |> ParseHelper.parse_string("description")
    |> ParseHelper.parse_module_function("component", default: {["Element", "section"], nil})
    |> ParseHelper.parse_relation_alias("link", :elements)
    |> ParseElementHelper.parse_element_indicators()
    |> ParseElementHelper.parse_element_sources()
    |> ParseElementHelper.parse_element_filters()
    |> ParseElementHelper.parse_element_data()
    |> parse_cards()
  end

  defp parse_cards(struct) do
    struct
    |> struct(data: ParseHelper.update_data(struct))
    |> ParseElementHelper.parse_element_relation("card", "cards", CSV.Card, &card_data/3, required: true)
    |> Map.get(:data)
  end

  defp card_data(struct, card, _opts) do
    Map.put(card, "section_id", struct.index)
  end
end
