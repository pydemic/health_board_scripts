defmodule HBS.Dashboards.YAMLToCSV.Filter do
  alias HBS.Dashboards.YAMLToCSV
  alias HBS.Dashboards.YAMLToCSV.ParseHelper

  defstruct data: nil,
            group: :filters,
            index: 0,
            row: [],
            sid: nil

  @spec parse(YAMLToCSV.t()) :: YAMLToCSV.t()
  def parse(data) do
    # sid name description default disabled options_module options_function options_params

    __MODULE__
    |> ParseHelper.setup_parser_struct(data, sid_required?: true, sid_as_cell?: true)
    |> ParseHelper.String.parse("name", required?: true)
    |> ParseHelper.String.parse("description")
    |> ParseHelper.String.parse("default")
    |> ParseHelper.Boolean.parse("disabled")
    |> ParseHelper.ModuleFunctionParams.parse("options", required?: true)
    |> ParseHelper.update_data()
  end
end
