defmodule HBS.Dashboards.YAMLToCSV.ElementFilter do
  alias HBS.Dashboards.YAMLToCSV
  alias HBS.Dashboards.YAMLToCSV.ParseHelper

  defstruct data: nil,
            group: :elements_filters,
            index: 0,
            row: [],
            sid: nil

  @spec parse(YAMLToCSV.t()) :: YAMLToCSV.t()
  def parse(data) do
    # element_id filter_id name description default disabled options_module options_function options_params

    __MODULE__
    |> ParseHelper.setup_parser_struct(data)
    |> ParseHelper.Integer.parse("element_id", required?: true)
    |> ParseHelper.RelationSID.parse("filter_sid", :filters, required?: true)
    |> ParseHelper.String.parse("name")
    |> ParseHelper.String.parse("description")
    |> ParseHelper.String.parse("default")
    |> ParseHelper.Boolean.parse("disabled")
    |> ParseHelper.ModuleFunctionParams.parse("options")
    |> ParseHelper.update_data()
  end
end
