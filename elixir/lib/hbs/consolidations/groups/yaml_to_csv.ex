defmodule HBS.Consolidations.Groups.YAMLToCSV do
  @dir File.cwd!()

  alias HBS.Consolidations.Groups.YAMLToCSV

  @type t :: %YAMLToCSV{
          input_path: String.t(),
          output_path: String.t()
        }

  defstruct input_path: Path.join(@dir, ".misc/sandbox/input/consolidations_groups.yml"),
            output_path: Path.join(@dir, ".misc/sandbox/output/consolidations/consolidations_groups.csv")

  @spec run(keyword) :: :ok
  def run(default_data \\ []) do
    %{input_path: input_path, output_path: output_path} = struct(YAMLToCSV, default_data)

    input_path
    |> parse_input()
    |> write_csv(output_path)
  end

  defp parse_input(path) do
    case YamlElixir.read_all_from_file(path) do
      {:ok, [%{"kind" => "consolidations_groups", "groups" => groups}]} when is_list(groups) ->
        groups
        |> Enum.with_index()
        |> Enum.reduce([], &parse_group/2)
        |> Enum.sort(&(&1.id <= &2.id))
        |> Enum.map(fn %{id: id, name: name} -> "#{id},#{name}" end)
        |> Enum.join("\n")

      _result ->
        raise %YAMLToCSV.Exception{reason: :invalid_input, metadata: [path: path]}
    end
  end

  defp parse_group({group, group_index}, groups) do
    if is_map(group) do
      case Map.to_list(group) do
        [{context_name, schemas}] when is_binary(context_name) and is_list(schemas) ->
          schemas
          |> Enum.with_index()
          |> Enum.reduce(groups, &parse_schema(&1, &2, context_name, group_index))

        _group ->
          raise %YAMLToCSV.Exception{reason: :invalid_group, metadata: [index: group_index]}
      end
    else
      raise %YAMLToCSV.Exception{reason: :invalid_group, metadata: [index: group_index]}
    end
  end

  defp parse_schema({schema, schema_index}, groups, context_name, group_index) do
    if is_map(schema) do
      case Map.to_list(schema) do
        [{schema_name, data_list}] when is_binary(schema_name) and is_list(data_list) ->
          data_list
          |> Enum.with_index()
          |> Enum.reduce(groups, &parse_data(&1, &2, context_name, schema_name, group_index, schema_index))

        _group ->
          raise %YAMLToCSV.Exception{reason: :invalid_schema, metadata: [context: context_name, index: schema_index]}
      end
    else
      raise %YAMLToCSV.Exception{reason: :invalid_schema, metadata: [context: context_name, index: schema_index]}
    end
  end

  defp parse_data({data_name, data_index}, groups, context_name, schema_name, group_index, schema_index) do
    if is_binary(data_name) do
      name = "#{context_name}_#{schema_name}_#{data_name}"

      if Enum.any?(groups, &(&1.name == name)) do
        raise %YAMLToCSV.Exception{reason: :non_unique_name, metadata: [name: name]}
      else
        id = 100_000 + data_index + schema_index * 100 + group_index * 10_000

        [%{id: id, name: name} | groups]
      end
    else
      raise %YAMLToCSV.Exception{reason: :invalid_data_name, metadata: [data_name: data_name]}
    end
  end

  defp write_csv(data, path) do
    path
    |> Path.dirname()
    |> File.mkdir_p()
    |> case do
      :ok ->
        case File.write(path, data) do
          :ok -> :ok
          {:error, posix} -> raise %YAMLToCSV.Exception{reason: :failed_to_write, metadata: [posix: posix, path: path]}
        end

      {:error, posix} ->
        raise %YAMLToCSV.Exception{reason: :failed_to_create_path, metadata: [posix: posix, path: path]}
    end
  end
end
