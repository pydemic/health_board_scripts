defmodule HBS.Dashboards.YAMLToCSV.ParseHelper do
  alias HBS.Dashboards.YAMLToCSV

  @spec parse(struct, String.t(), (YAMLToCSV.t(), any, keyword -> any), keyword) :: struct
  def parse(struct, key, parse_function, opts) do
    struct(struct, row: struct.row ++ do_parse(struct, key, parse_function, opts))
  end

  defp do_parse(%{data: %{input_data: input_data} = data}, key, parse_function, opts) do
    cells = Keyword.get(opts, :cells, 1)

    case Map.fetch(input_data, key) do
      {:ok, item} ->
        value = parse_function.(struct(data, where: [key | data.where]), item, opts)

        if cells == 1 do
          [value]
        else
          value
        end

      :error ->
        if Keyword.get(opts, :required?, false) == true do
          raise YAMLToCSV.Exception.new(:item_not_found, data, key: key, keys: Map.keys(input_data))
        else
          case Keyword.get(opts, :default) do
            nil -> Enum.map(1..cells, fn _index -> nil end)
            default -> default
          end
        end
    end
  end

  @spec setup_parser_struct(module, YAMLToCSV.t(), keyword) :: struct
  def setup_parser_struct(module, %{output_sizes: output_sizes} = data, opts \\ []) do
    %{group: group} = struct = struct(module)
    index = Map.get(output_sizes, group, 0)
    data = struct(data, output_sizes: Map.put(output_sizes, group, index + 1))

    struct
    |> struct(data: data, index: index)
    |> parse_sid(opts)
  end

  defp parse_sid(%{data: %{input_data: input_data} = data, group: group, index: index} = struct, opts) do
    case {Map.fetch(input_data, "sid"), Keyword.get(opts, :sid_required?, false)} do
      {{:ok, sid}, _required?} ->
        sid = maybe_prepend_parent_sid(input_data["parent_sid"], sid)
        indexes = Map.update(data.indexes, group, %{sid => index}, &Map.put(&1, sid, index))

        if Keyword.get(opts, :sid_as_cell?, false) == true do
          struct(struct, data: Map.put(data, :indexes, indexes), row: struct.row ++ [sid], sid: sid)
        else
          struct(struct, data: Map.put(data, :indexes, indexes), sid: sid)
        end

      {:error, true} ->
        raise YAMLToCSV.Exception.new(:sid_not_found, data, group: group, index: index)

      {:error, _required?} ->
        if Keyword.get(opts, :sid_as_cell?, false) == true do
          struct(struct, row: struct.row ++ [nil])
        else
          struct
        end
    end
  end

  defp maybe_prepend_parent_sid(nil, sid), do: sid
  defp maybe_prepend_parent_sid(parent_sid, sid), do: "#{parent_sid}_#{sid}"

  @spec update_data(struct) :: YAMLToCSV.t()
  def update_data(%{data: data, index: index, group: group, row: row}) do
    row = [index + 1 | row]
    struct(data, output_data: Map.update(data.output_data, group, [row], &(&1 ++ [row])))
  end

  @spec where(struct, any, (struct -> struct)) :: struct
  def where(struct, where_function, function) when is_function(where_function) do
    where(struct, where_function.(struct), function)
  end

  def where(%{data: %{where: where} = data} = struct, where_value, function) do
    %{data: data} =
      struct =
      struct
      |> struct(data: Map.put(data, :where, [where_value | where]))
      |> function.()

    struct(struct, data: Map.put(data, :where, where))
  end
end
