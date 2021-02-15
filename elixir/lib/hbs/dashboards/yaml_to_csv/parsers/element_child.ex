defmodule HBS.Dashboards.YAMLToCSV.ElementChild do
  alias HBS.Dashboards.YAMLToCSV
  alias HBS.Dashboards.YAMLToCSV.ParseHelper

  defstruct data: nil,
            group: :elements_children,
            index: 0,
            row: [],
            sid: nil

  @spec parse(YAMLToCSV.t()) :: YAMLToCSV.t()
  def parse(data) do
    # parent_id child_id

    __MODULE__
    |> ParseHelper.setup_parser_struct(data)
    |> ParseHelper.Integer.parse("parent_id", required?: true)
    |> ParseHelper.Integer.parse("child_id", required?: true)
    |> ParseHelper.update_data()
  end
end
