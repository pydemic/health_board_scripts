defmodule HBS.Dashboards.YAMLToCSV.Indicator do
  alias HBS.Dashboards.YAMLToCSV
  alias HBS.Dashboards.YAMLToCSV.ParseHelper

  defstruct data: nil,
            group: :indicators,
            index: 0,
            row: [],
            sid: nil

  @spec parse(YAMLToCSV.t()) :: YAMLToCSV.t()
  def parse(data) do
    # sid name description formula measurement_unit link

    __MODULE__
    |> ParseHelper.setup_parser_struct(data, sid_required?: true, sid_as_cell?: true)
    |> ParseHelper.String.parse("name", required?: true)
    |> ParseHelper.String.parse("description", required?: true)
    |> ParseHelper.String.parse("formula", required?: true)
    |> ParseHelper.String.parse("measurement_unit")
    |> ParseHelper.URI.parse("link")
    |> ParseHelper.update_data()
  end
end
