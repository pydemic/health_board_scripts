defmodule HBS.Dashboards.CSV.Indicators do
  import HBS.Dashboards.CSV.Helper, only: [raise_error: 3, where: 3]
  alias HBS.Dashboards.CSV

  @spec parse(CSV.t()) :: CSV.t()
  def parse(%{input_data: input_data} = data) do
    case Map.get(input_data, "indicators") do
      indicators when is_list(indicators) -> parse_indicators(indicators, data)
      nil -> raise_error(:indicators_not_found, data, keys: Map.keys(input_data))
      indicators -> raise_error(:indicators_not_a_list, data, keys: indicators)
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
    |> where(index, &CSV.Indicator.parse/1)
  end
end
