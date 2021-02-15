defmodule HBS.Dashboards.YAMLToCSV.ElementIndicator do
  alias HBS.Dashboards.YAMLToCSV
  alias HBS.Dashboards.YAMLToCSV.ParseHelper

  defstruct data: nil,
            group: :elements_indicators,
            index: 0,
            row: [],
            sid: nil

  @spec parse(YAMLToCSV.t()) :: YAMLToCSV.t()
  def parse(data) do
    # element_id indicator_id

    __MODULE__
    |> ParseHelper.setup_parser_struct(data)
    |> ParseHelper.Integer.parse("element_id", required?: true)
    |> ParseHelper.RelationSID.parse("indicator_sid", :indicators, required?: true)
    |> ParseHelper.update_data()
  end
end
