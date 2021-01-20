defmodule HBS.Dashboards.CSV.ParseElementHelper do
  import HBS.Dashboards.CSV.Helper, only: [raise_error: 3]
  import HBS.Dashboards.CSV.ParseHelper, only: [where: 3]
  alias HBS.Dashboards.CSV

  @spec parse_element_data(struct, keyword) :: struct
  def parse_element_data(struct, opts \\ []) do
    parse_element_relation(
      struct,
      "data",
      "data",
      CSV.ElementData,
      &element_data/3,
      Keyword.put(opts, :map_as_list, true)
    )
  end

  defp element_data(%{data: data, index: index}, {field, payload}, _opts) do
    cond do
      is_binary(payload) -> %{"element_id" => index, "field" => field, "data" => payload}
      is_map(payload) -> Map.merge(%{"element_id" => index, "field" => field}, payload)
      true -> raise_error(:data_invalid, data, data: payload)
    end
  end

  @spec parse_element_filters(struct, keyword) :: struct
  def parse_element_filters(struct, opts \\ []) do
    parse_element_relation(struct, "filter", "filters", CSV.ElementFilter, &element_filter_data/3, opts)
  end

  defp element_filter_data(%{data: data, index: index}, filter, _opts) do
    cond do
      is_binary(filter) -> %{"element_id" => index, "filter_alias" => filter}
      is_map(filter) -> Map.put(filter, "element_id", index)
      true -> raise_error(:filter_invalid, data, filter: filter)
    end
  end

  @spec parse_element_indicators(struct, keyword) :: struct
  def parse_element_indicators(struct, opts \\ []) do
    parse_element_relation(struct, "indicator", "indicators", CSV.ElementIndicator, &element_indicator_data/3, opts)
  end

  defp element_indicator_data(%{index: index}, indicator_alias, _opts) do
    %{"element_id" => index, "indicator_alias" => indicator_alias}
  end

  @spec parse_element_parent(struct, String.t(), keyword) :: struct
  def parse_element_parent(struct, key, opts \\ []) do
    parse_element_relation(struct, key, CSV.ElementChild, &element_parent_data/3, opts)
  end

  defp element_parent_data(%{index: index}, parent_id, _opts) do
    %{"parent_id" => parent_id, "child_id" => index}
  end

  @spec parse_element_relation(struct, String.t(), String.t() | nil, module, function, keyword) :: struct
  def parse_element_relation(struct, key, plural_key \\ nil, module, parse_function, opts)

  def parse_element_relation(struct, key, nil, module, parse_function, opts) do
    %{data: %{input_data: input_data} = data} = struct

    case Map.fetch(input_data, key) do
      {:ok, item} ->
        where(struct, key, &parse_element_relation_data(&1, item, module, parse_function, opts))

      :error ->
        if Keyword.get(opts, :required?, false) == true do
          raise_error(:item_not_found, data, key: key, keys: Map.keys(input_data))
        else
          struct
        end
    end
  end

  def parse_element_relation(struct, key, plural_key, module, parse_function, opts) do
    %{data: %{input_data: input_data} = data} = struct

    case Map.fetch(input_data, plural_key) do
      {:ok, items} when is_list(items) ->
        where(struct, plural_key, fn struct ->
          Enum.reduce(items, struct, &parse_element_relation_data(&2, &1, module, parse_function, opts))
        end)

      {:ok, item} ->
        if Keyword.get(opts, :map_as_list, false) == true and is_map(item) do
          where(struct, plural_key, fn struct ->
            Enum.reduce(item, struct, &parse_element_relation_data(&2, &1, module, parse_function, opts))
          end)
        else
          raise_error(:item_not_a_list, data, key: plural_key, item: item)
        end

      :error ->
        parse_element_relation(struct, key, module, parse_function, opts)
    end
  end

  defp parse_element_relation_data(struct, indicator_alias, module, parse_function, opts) do
    %{data: %{input_data: input_data} = data} = struct

    data =
      data
      |> struct(input_data: parse_function.(struct, indicator_alias, opts))
      |> module.parse()

    struct(struct, data: struct(data, input_data: input_data))
  end

  @spec parse_element_sources(struct, keyword) :: struct
  def parse_element_sources(struct, opts \\ []) do
    parse_element_relation(struct, "source", "sources", CSV.ElementSource, &element_source_data/3, opts)
  end

  defp element_source_data(%{index: index}, source_alias, _opts) do
    %{"element_id" => index, "source_alias" => source_alias}
  end
end
