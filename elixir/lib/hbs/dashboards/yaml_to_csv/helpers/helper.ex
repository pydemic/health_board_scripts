defmodule HBS.Dashboards.YAMLToCSV.Helper do
  alias HBS.Dashboards.YAMLToCSV

  @spec where(YAMLToCSV.t(), any, (YAMLToCSV.t() -> YAMLToCSV.t())) :: YAMLToCSV.t()
  def where(data, where_function, function) when is_function(where_function) do
    where(data, where_function.(data), function)
  end

  def where(%{where: where} = data, where_value, function) do
    data
    |> struct(where: [where_value | where])
    |> function.()
    |> struct(where: where)
  end
end
