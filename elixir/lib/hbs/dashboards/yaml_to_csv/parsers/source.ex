defmodule HBS.Dashboards.YAMLToCSV.Source do
  alias HBS.Dashboards.YAMLToCSV
  alias HBS.Dashboards.YAMLToCSV.ParseHelper

  defstruct data: nil,
            group: :sources,
            index: 0,
            row: [],
            sid: nil

  @spec parse(YAMLToCSV.t()) :: YAMLToCSV.t()
  def parse(data) do
    # sid name description link update_rate extraction_date last_update_date

    __MODULE__
    |> ParseHelper.setup_parser_struct(data, sid_required?: true, sid_as_cell?: true)
    |> ParseHelper.String.parse("name", required?: true)
    |> ParseHelper.String.parse("description")
    |> ParseHelper.URI.parse("link")
    |> ParseHelper.String.parse("update_rate")
    |> ParseHelper.Date.parse("extraction_date")
    |> ParseHelper.Date.parse("last_update_date")
    |> ParseHelper.update_data()
  end
end
