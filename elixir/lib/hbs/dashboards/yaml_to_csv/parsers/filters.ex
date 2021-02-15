defmodule HBS.Dashboards.YAMLToCSV.Filters do
  import HBS.Dashboards.YAMLToCSV.Helper, only: [where: 3]
  alias HBS.Dashboards.YAMLToCSV

  @spec parse(YAMLToCSV.t()) :: YAMLToCSV.t()
  def parse(%{input_data: input_data} = data) do
    case Map.get(input_data, "filters") do
      filters when is_list(filters) -> parse_filters(filters, data)
      nil -> raise YAMLToCSV.Exception.new(:filters_not_found, data, keys: Map.keys(input_data))
      filters -> raise YAMLToCSV.Exception.new(:filters_not_a_list, data, keys: filters)
    end
  end

  defp parse_filters(filters, data) do
    where(data, "filters", fn data ->
      filters
      |> Enum.with_index()
      |> Enum.reduce(data, &parse_filter/2)
    end)
  end

  defp parse_filter({filter, index}, data) do
    data
    |> struct(input_data: filter)
    |> where(index, &YAMLToCSV.Filter.parse/1)
  end
end
