defmodule HBS.Dashboards.CSV.Sources do
  import HBS.Dashboards.CSV.Helper, only: [raise_error: 3, where: 3]
  alias HBS.Dashboards.CSV

  @spec parse(CSV.t()) :: CSV.t()
  def parse(%{input_data: input_data} = data) do
    case Map.get(input_data, "sources") do
      sources when is_list(sources) -> parse_sources(sources, data)
      nil -> raise_error(:sources_not_found, data, keys: Map.keys(input_data))
      sources -> raise_error(:sources_not_a_list, data, keys: sources)
    end
  end

  defp parse_sources(sources, data) do
    where(data, "sources", fn data ->
      sources
      |> Enum.with_index()
      |> Enum.reduce(data, &parse_source/2)
    end)
  end

  defp parse_source({source, index}, data) do
    data
    |> struct(input_data: source)
    |> where(index, &CSV.Source.parse/1)
  end
end
