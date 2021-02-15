defmodule HBS.Dashboards.YAMLToCSV.ParseHelper.ModuleFunctionParams do
  alias HBS.Dashboards.YAMLToCSV
  alias HBS.Dashboards.YAMLToCSV.ParseHelper

  @spec parse(struct, String.t(), keyword) :: struct
  def parse(%{data: %{input_data: input_data}} = struct, key, opts \\ []) do
    {module_function_default, params_default} = Keyword.get(opts, :default, {[nil, nil], nil})
    default = module_function_default ++ [params_default]

    if is_map(input_data[key]) do
      ParseHelper.parse(struct, key, &parse_module_function_map/3, Keyword.merge(opts, cells: 3, default: default))
    else
      p_key = "#{key}_params"

      if Map.has_key?(input_data, p_key) do
        struct
        |> ParseHelper.parse(
          key,
          &parse_module_function_string/3,
          Keyword.merge(opts, cells: 2, default: module_function_default)
        )
        |> ParseHelper.parse(
          p_key,
          &parse_module_function_params/3,
          Keyword.merge(opts, default: params_default, required?: false)
        )
      else
        ParseHelper.parse(struct, key, &parse_module_function_string/3, Keyword.merge(opts, cells: 3, default: default))
      end
    end
  end

  defp parse_module_function_map(data, item, _opts) do
    case item do
      %{"module" => module, "function" => function, "params" => params} ->
        [module, function, parse_module_function_params(params)]

      %{"module" => module, "function" => function} ->
        [module, function, nil]
    end
  rescue
    error -> reraise YAMLToCSV.Exception.new(:invalid_module_function, data, item: item, error: error), __STACKTRACE__
  end

  defp parse_module_function_string(data, item, opts) do
    if Keyword.get(opts, :cells, 3) == 3 do
      case String.split(item, "?") do
        [mf, params] -> parse_module_and_function(mf) ++ [parse_module_function_params(params)]
        [mf] -> parse_module_and_function(mf) ++ [nil]
      end
    else
      parse_module_and_function(item)
    end
  rescue
    error -> reraise YAMLToCSV.Exception.new(:invalid_module_function, data, item: item, error: error), __STACKTRACE__
  end

  defp parse_module_and_function(item) do
    module_and_function = String.split(item, ".")
    {function, module} = List.pop_at(module_and_function, -1)
    [Enum.join(module, "."), function]
  end

  defp parse_module_function_params(params) do
    if is_binary(params) do
      params
    else
      URI.encode_query(params)
    end
  end

  defp parse_module_function_params(data, item, _opts) do
    parse_module_function_params(item)
  rescue
    error ->
      reraise YAMLToCSV.Exception.new(:invalid_module_function_params, data, item: item, error: error), __STACKTRACE__
  end
end
