defmodule HBS.Dashboards.YAMLToCSV.ParseHelper.Date do
  alias HBS.Dashboards.YAMLToCSV
  alias HBS.Dashboards.YAMLToCSV.ParseHelper

  @spec parse(struct, String.t(), keyword) :: struct
  def parse(struct, key, opts \\ []), do: ParseHelper.parse(struct, key, &do_parse/3, opts)

  defp do_parse(data, item, _opts) do
    case Date.from_iso8601(item) do
      {:ok, date} -> date
      {:error, reason} -> raise YAMLToCSV.Exception.new(:item_not_a_date, data, item: item, error: reason)
    end
  end
end
