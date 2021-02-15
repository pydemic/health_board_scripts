defmodule HBS.Dashboards.YAMLToCSV.ParseHelper.URI do
  alias HBS.Dashboards.YAMLToCSV
  alias HBS.Dashboards.YAMLToCSV.ParseHelper

  @spec parse(struct, String.t(), keyword) :: struct
  def parse(struct, key, opts \\ []), do: ParseHelper.parse(struct, key, &do_parse/3, opts)

  defp do_parse(data, item, _opts) do
    URI.decode(item)
    item
  rescue
    error -> reraise YAMLToCSV.Exception.new(:item_not_an_uri, data, item: item, exception: error), __STACKTRACE__
  end
end
