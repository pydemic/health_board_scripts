defmodule HBS.Dashboards.YAMLToCSV.ElementData do
  alias HBS.Dashboards.YAMLToCSV
  alias HBS.Dashboards.YAMLToCSV.ParseHelper

  defstruct data: nil,
            group: :elements_data,
            index: 0,
            row: [],
            sid: nil

  @spec parse(YAMLToCSV.t()) :: YAMLToCSV.t()
  def parse(data) do
    # element_id field data_module data_function data_params

    __MODULE__
    |> ParseHelper.setup_parser_struct(data)
    |> ParseHelper.Integer.parse("element_id", required?: true)
    |> ParseHelper.String.parse("field", required?: true)
    |> ParseHelper.ModuleFunctionParams.parse("data", required?: true)
    |> ParseHelper.update_data()
  end
end
