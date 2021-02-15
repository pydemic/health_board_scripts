defmodule HBS.Dashboards.YAMLToCSV.Indicators do
  import HBS.Dashboards.YAMLToCSV.Helper, only: [where: 3]
  alias HBS.Dashboards.YAMLToCSV

  @spec parse(YAMLToCSV.t()) :: YAMLToCSV.t()
  def parse(%{input_data: input_data} = data) do
    case Map.get(input_data, "indicators") do
      indicators when is_list(indicators) -> parse_indicators(indicators, data)
      nil -> raise YAMLToCSV.Exception.new(:indicators_not_found, data, keys: Map.keys(input_data))
      indicators -> raise YAMLToCSV.Exception.new(:indicators_not_a_list, data, keys: indicators)
    end
  end

  defp parse_indicators(indicators, data) do
    where(data, "indicators", fn data ->
      indicators
      |> Enum.with_index()
      |> Enum.reduce(data, &parse_indicator/2)
    end)
  end

  defp parse_indicator({indicator, index}, data) do
    data
    |> struct(input_data: indicator)
    |> where(index, &YAMLToCSV.Indicator.parse/1)
  end
end
