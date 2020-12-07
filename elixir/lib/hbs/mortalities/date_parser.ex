defmodule HBS.Mortalities.DateParser do
  require Logger

  @dir Path.join(File.cwd!(), ".misc/sandbox")
  @input_dir Path.join(@dir, "input")
  @output_dir Path.join(@dir, "output")
  @output_path Path.join(@output_dir, "mortalities_dates.csv")

  @columns [
    {"DTOBITO", :date, :required},
    {"CAUSABAS", :string, :required},
    {"CODMUNOCOR", :integer, :required},
    {"CODMUNRES", :integer, :required}
  ]

  @spec run :: :ok
  def run do
    File.rm_rf!(@output_path)
    File.mkdir_p!(@output_dir)

    @input_dir
    |> File.ls!()
    |> Enum.sort()
    |> inform_files()
    |> Stream.with_index(1)
    |> Task.async_stream(&parse_data_and_append_to_csv/1, timeout: :infinity)
    |> Stream.run()

    sort_file(@output_path)

    :ok
  end

  defp inform_files(file_names) do
    Logger.info("#{Enum.count(file_names)} files identified")
    file_names
  end

  defp parse_data_and_append_to_csv({file_name, file_index}) do
    if rem(file_index, 50) == 0 do
      Logger.info("[#{file_index}] Parsing #{file_name}")
    end

    @input_dir
    |> Path.join(file_name)
    |> File.stream!()
    |> NimbleCSV.RFC4180.parse_stream(skip_headers: false)
    |> parse_and_append_to_csv(file_name)
  end

  defp parse_and_append_to_csv(stream, file_name) do
    [first_line] = Enum.to_list(Stream.take(stream, 1))
    indexes = Enum.map(@columns, &parse_index(first_line, &1))

    stream
    |> Stream.drop(1)
    |> Stream.with_index(1)
    |> Stream.map(&parse_line_and_append_to_csv(file_name, &1, indexes))
    |> Stream.run()
  end

  defp parse_index(line, {column_name, type, required_or_optional}) do
    case {Enum.find_index(line, &(&1 == column_name)), required_or_optional} do
      {nil, :required} -> raise "Column #{column_name} not found"
      {index, _required_or_optional} -> {index, type, required_or_optional}
    end
  end

  defp parse_line_and_append_to_csv(file_name, {line, line_index}, indexes) do
    indexes
    |> Enum.map(&parse_item(line, &1))
    |> append_to_csv()
  rescue
    error ->
      Logger.error("[#{file_name}:#{line_index}] #{Exception.message(error)}")
      :ok
  end

  defp parse_item(line, {index, type, required_or_optional}) do
    if is_nil(index) do
      nil
    else
      case {Enum.at(line, index), type, required_or_optional} do
        {"", _type, :required} ->
          raise "Data at #{index} is empty"

        {"N/A", _type, :required} ->
          raise "Data at column #{index} not defined"

        {value, type, :required} ->
          parse_value(value, type) || raise "Data at #{index} (#{value}) is invalid"

        {value, type, _required_or_optional} ->
          parse_value(value, type)
      end
    end
  end

  defp parse_value(value, type) do
    case type do
      :integer -> String.to_integer(value)
      :string -> sanitize_string(value)
      :date -> parse_date(value)
    end
  rescue
    _error -> nil
  end

  defp parse_date(value) do
    if String.length(value) == 8 do
      day = String.to_integer(String.slice(value, 0, 2))
      month = String.to_integer(String.slice(value, 2, 2))
      year = String.to_integer(String.slice(value, 4, 4))

      if year > 1999 and year < 2021 do
        case Date.new(year, month, day) do
          {:ok, date} -> date
          _error -> nil
        end
      else
        nil
      end
    else
      nil
    end
  end

  defp sanitize_string(value) do
    if String.replace(value, "*", "") != "" do
      value = String.replace(value, ".", "")
      value = String.replace(value, "NA", "")

      if String.contains?(value, ",") do
        ~s("#{value}")
      else
        value
      end

      if value == "" do
        nil
      else
        value
      end
    else
      nil
    end
  end

  defp append_to_csv(line) do
    File.write!(@output_path, Enum.join(line, ",") <> "\n", [:append])
  end

  defp sort_file(file_name) do
    Logger.info("Sorting #{Path.basename(file_name)}")

    file_path = Path.join(@output_dir, file_name)

    {_result, 0} = System.cmd("sort", ~w[-o #{file_path} #{file_path}])
  end
end
