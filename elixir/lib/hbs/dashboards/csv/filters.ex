defmodule HBS.Dashboards.CSV.Filters do
  import HBS.Dashboards.CSV.Helper, only: [raise_error: 3, where: 3]
  alias HBS.Dashboards.CSV

  @spec parse(CSV.t()) :: CSV.t()
  def parse(%{input_data: input_data} = data) do
    case Map.get(input_data, "filters") do
      filters when is_list(filters) -> parse_filters(filters, data)
      nil -> raise_error(:filters_not_found, data, keys: Map.keys(input_data))
      filters -> raise_error(:filters_not_a_list, data, keys: filters)
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
    |> where(index, &CSV.Filter.parse/1)
  end
end
