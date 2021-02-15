defmodule HBS.Dashboards.YAMLToCSV.ParseHelper.Integer do
  alias HBS.Dashboards.YAMLToCSV
  alias HBS.Dashboards.YAMLToCSV.ParseHelper

  @spec parse(struct, String.t(), keyword) :: struct
  def parse(struct, key, opts \\ []), do: ParseHelper.parse(struct, key, &do_parse/3, opts)

  defp do_parse(data, item, _opts) do
    if is_integer(item) do
      item
    else
      raise YAMLToCSV.Exception.new(:item_not_a_integer, data, item: item)
    end
  end
end
