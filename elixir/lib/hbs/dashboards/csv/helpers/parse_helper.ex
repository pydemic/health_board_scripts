defmodule HBS.Dashboards.CSV.ParseHelper do
  import HBS.Dashboards.CSV.Helper, only: [raise_error: 3]
  alias HBS.Dashboards.CSV

  @spec parse(struct, String.t(), (CSV.t(), any, keyword -> any), keyword) :: struct
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
          raise_error(:item_not_found, data, key: key, keys: Map.keys(input_data))
        else
          case Keyword.get(opts, :default) do
            nil -> Enum.map(1..cells, fn _index -> nil end)
            default -> default
          end
        end
    end
  end

  @spec parse_boolean(struct, String.t(), keyword) :: struct
  def parse_boolean(struct, key, opts \\ []), do: parse(struct, key, &do_parse_boolean/3, opts)

  defp do_parse_boolean(data, item, _opts) do
    if is_boolean(item) do
      item
    else
      raise_error(:item_not_boolean, data, item: item)
    end
  end

  @spec parse_date(struct, String.t(), keyword) :: struct
  def parse_date(struct, key, opts \\ []), do: parse(struct, key, &do_parse_date/3, opts)

  defp do_parse_date(data, item, _opts) do
    case Date.from_iso8601(item) do
      {:ok, date} -> date
      {:error, reason} -> raise_error(:item_not_a_date, data, item: item, error: reason)
    end
  end

  @spec parse_integer(struct, String.t(), keyword) :: struct
  def parse_integer(struct, key, opts \\ []), do: parse(struct, key, &do_parse_integer/3, opts)

  defp do_parse_integer(data, item, _opts) do
    if is_integer(item) do
      item
    else
      raise_error(:item_not_a_integer, data, item: item)
    end
  end

  @spec parse_module_function(struct, String.t(), keyword) :: struct
  def parse_module_function(struct, key, opts \\ []) do
    {module_function_default, params_default} = Keyword.get(opts, :default, {nil, nil})

    struct
    |> parse(key, &do_parse_module_function/3, Keyword.merge(opts, cells: 2, default: module_function_default))
    |> parse_string("#{key}_params", Keyword.merge(opts, default: params_default, required?: false))
  end

  defp do_parse_module_function(data, item, _opts) do
    module_and_function = String.split(item, ".")
    {function, module} = List.pop_at(module_and_function, -1)

    if String.match?(String.first(function), ~r/[a-z]/) do
      [Enum.join(module, "."), function]
    else
      raise_error(:item_not_a_module_and_function, data, item: item)
    end
  rescue
    error -> raise_error(:item_not_a_module_and_function, data, item: item, error: error)
  end

  @spec parse_relation_alias(struct, String.t(), atom, keyword) :: struct
  def parse_relation_alias(struct, key, to_group, opts \\ []) do
    struct
    |> parse_string(key, opts)
    |> do_parse_relation_alias(to_group, opts)
  end

  defp do_parse_relation_alias(struct, to_group, _opts) do
    %{index: index, group: group, data: %{requirements: requirements} = data} = struct

    case List.last(Enum.with_index(struct.row)) do
      {nil, _index} ->
        struct

      {to_alias, row_index} ->
        get_keys = [to_group, to_alias]
        put_keys = [group, index, row_index]

        struct(struct,
          data: struct(data, requirements: Map.update(requirements, get_keys, [put_keys], &[put_keys | &1]))
        )
    end
  end

  @spec parse_row_alias(struct) :: struct
  def parse_row_alias(%{data: data} = struct) do
    case Map.fetch(data.input_data, "alias") do
      {:ok, row_alias} ->
        %{group: group, index: index} = struct
        indexes = Map.update(data.indexes, group, %{row_alias => index}, &Map.put(&1, row_alias, index))
        struct(struct, data: Map.put(data, :indexes, indexes), row_alias: row_alias)

      :error ->
        struct
    end
  end

  @spec parse_string(struct, String.t(), keyword) :: struct
  def parse_string(struct, key, opts \\ []), do: parse(struct, key, &do_parse_string/3, opts)

  defp do_parse_string(data, item, _opts) do
    if is_binary(item) do
      item
    else
      raise_error(:item_not_a_string, data, item: item)
    end
  end

  @spec parse_uri(struct, String.t(), keyword) :: struct
  def parse_uri(struct, key, opts \\ []), do: parse(struct, key, &do_parse_uri/3, opts)

  defp do_parse_uri(data, item, _opts) do
    URI.decode(item)
    item
  rescue
    error -> raise_error(:item_not_an_uri, data, item: item, exception: error)
  end

  @spec setup_parsing_struct(module, CSV.t()) :: struct
  def setup_parsing_struct(module, %{output_sizes: output_sizes} = data) do
    %{group: group} = struct = struct(module)
    index = Map.get(output_sizes, group, 0)
    data = struct(data, output_sizes: Map.put(output_sizes, group, index + 1))

    struct
    |> struct(data: data, index: index)
    |> parse_row_alias()
  end

  @spec update_data(struct) :: CSV.t()
  def update_data(%{data: data, group: group, row: row}) do
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
