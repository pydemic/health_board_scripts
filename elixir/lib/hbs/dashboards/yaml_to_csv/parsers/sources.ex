defmodule HBS.Dashboards.YAMLToCSV.Sources do
  import HBS.Dashboards.YAMLToCSV.Helper, only: [where: 3]
  alias HBS.Dashboards.YAMLToCSV

  @spec parse(YAMLToCSV.t()) :: YAMLToCSV.t()
  def parse(%{input_data: input_data} = data) do
    case Map.get(input_data, "sources") do
      sources when is_list(sources) -> parse_sources(sources, data)
      nil -> raise YAMLToCSV.Exception.new(:sources_not_found, data, keys: Map.keys(input_data))
      sources -> raise YAMLToCSV.Exception.new(:sources_not_a_list, data, keys: sources)
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
    |> where(index, &YAMLToCSV.Source.parse/1)
  end
end
