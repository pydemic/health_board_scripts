defmodule HBS.Dashboards.YAMLToCSV do
  import __MODULE__.Helper, only: [where: 3]

  @dir File.cwd!()

  @type t :: %__MODULE__{
          input_path: String.t(),
          output_path: String.t(),
          where: list,
          input_data: map,
          output_data: map,
          output_sizes: map,
          requirements: map,
          indexes: map
        }

  defstruct input_path: Path.join(@dir, ".misc/sandbox/input"),
            output_path: Path.join(@dir, ".misc/sandbox/output/dashboards"),
            where: [],
            input_data: %{},
            output_data: %{},
            output_sizes: %{},
            requirements: %{},
            indexes: %{}

  @spec run(keyword) :: :ok
  def run(default_data \\ []) do
    %__MODULE__{}
    |> struct(default_data)
    |> parse_input()
    |> validate_requirements()
    |> write_files()
  end

  defp parse_input(%{input_path: path} = data) do
    if File.dir?(path) do
      path
      |> paths_from_dir(data)
      |> Enum.reduce(data, &parse_input/2)
    else
      where(data, & &1.input_path, fn data ->
        path
        |> YamlElixir.read_all_from_file!()
        |> Enum.with_index()
        |> Enum.reduce(data, &parse_input_data/2)
      end)
    end
  end

  defp parse_input(path, data) do
    data
    |> struct(input_path: path)
    |> parse_input()
  end

  defp paths_from_dir(path, data) do
    case File.ls(path) do
      {:ok, paths} ->
        paths
        |> Enum.sort()
        |> Enum.map(&Path.join(path, &1))

      {:error, posix} ->
        raise __MODULE__.Exception.new(:ls_failed, struct(data, input_path: path), ls_error: posix)
    end
  end

  defp parse_input_data({input_data, index}, data) do
    data
    |> struct(input_data: input_data)
    |> where(index, &parse_input_kind/1)
  end

  defp parse_input_kind(%{input_data: input_data} = data) do
    case Map.pop(input_data, "kind") do
      {nil, _input_data} ->
        raise __MODULE__.Exception.new(:kind_not_found, data, keys: Map.keys(input_data))

      {kind, input_data} ->
        data = struct(data, input_data: input_data)

        case kind do
          "dashboard" -> __MODULE__.Dashboard.parse(data)
          "filters" -> __MODULE__.Filters.parse(data)
          "indicators" -> __MODULE__.Indicators.parse(data)
          "sources" -> __MODULE__.Sources.parse(data)
          kind -> raise __MODULE__.Exception.new(:invalid_kind, data, kind: kind)
        end
    end
  end

  defp validate_requirements(%{requirements: requirements} = data) do
    Enum.reduce(requirements, data, &validate_requirement/2)
  end

  defp validate_requirement({get_keys, put_keys_list}, %{indexes: indexes} = data) do
    case get_in(indexes, get_keys) do
      nil -> raise __MODULE__.Exception.new(:invalid_requirement_get_keys, data, get_keys: get_keys)
      index -> update_output_data_from_requirement(data, put_keys_list, index)
    end
  end

  defp update_output_data_from_requirement(%{output_data: output_data} = data, put_keys_list, index) do
    struct(data,
      output_data:
        Enum.reduce(put_keys_list, output_data, fn put_keys, output_data ->
          try do
            put_in_data(output_data, put_keys, index)
          rescue
            error ->
              reraise __MODULE__.Exception.new(
                        :invalid_requirement_put_keys,
                        data,
                        put_keys: put_keys,
                        error: error
                      ),
                      __STACKTRACE__
          end
        end)
    )
  end

  defp put_in_data(data, keys, index) do
    if Enum.any?(keys) do
      [key | keys] = keys

      cond do
        is_map(data) ->
          child_data = Map.get(data, key)
          Map.put(data, key, put_in_data(child_data, keys, index))

        is_list(data) ->
          child_data = Enum.at(data, key)
          List.replace_at(data, key, put_in_data(child_data, keys, index))
      end
    else
      index + 1
    end
  end

  defp write_files(%{output_data: output_data, output_path: output_path}) do
    File.rm_rf!(output_path)
    File.mkdir_p!(output_path)

    Enum.each(output_data, fn {filename, rows} ->
      output_path
      |> Path.join("#{filename}.csv")
      |> File.write(encode_rows(rows))
      |> case do
        :ok ->
          :ok

        {:error, posix} ->
          raise __MODULE__.Exception.new(:write_failed, write_error: posix, filename: filename, rows: rows)
      end
    end)
  end

  defp encode_rows(rows) do
    rows
    |> Enum.map(&encode_row/1)
    |> Enum.join("\n")
  end

  defp encode_row(row) do
    row
    |> Enum.map(&encode_cell/1)
    |> Enum.join(",")
  end

  defp encode_cell(cell) do
    if is_binary(cell) do
      if String.contains?(cell, ",") do
        ~s("#{cell}")
      else
        cell
      end
    else
      to_string(cell)
    end
  end
end
