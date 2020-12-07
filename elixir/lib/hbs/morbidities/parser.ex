defmodule HBS.Morbidities.Parser do
  require Logger

  @dir Path.join(File.cwd!(), ".misc/sandbox")
  @input_dir Path.join(@dir, "input")
  @output_dir Path.join(@dir, "output")
  @output_path Path.join(@output_dir, "morbidities.csv")

  @columns [
    {["DT_OCOR", "DT_SIN_PRI", "DT_DIAG", "DT_NOTIFIC", "NU_ANO"], :date, :required},
    {"ID_AGRAVO", :string, :optional},
    {"ID_MUNICIP", :integer, :required},
    {"ID_MN_RESI", :integer, :required},
    {"NU_IDADE_N", :integer, :optional},
    {"CS_SEXO", :string, :optional},
    {"CS_RACA", :integer, :optional},
    {"CLASSI_FIN", :integer, :optional},
    {"EVOLUCAO", :integer, :optional}
  ]

  @bases_contexts %{
    "ANIM" => 300_100,
    "BOTU" => 100_000,
    "CHAG" => 200_200,
    "CHIK" => 110_200,
    "COLE" => 100_100,
    "COQU" => 200_000,
    "DENG" => 110_000,
    "DIFT" => 200_100,
    "ESQU" => 410_300,
    "FAMA" => 101_200,
    "FMAC" => 101_400,
    "HANS" => 410_400,
    "HANT" => 101_500,
    "IEXO" => 410_700,
    "LEIV" => 410_900,
    "LEPT" => 300_300,
    "LTAN" => 410_800,
    "MALA" => 101_700,
    "MENI" => 200_400,
    "PEST" => 101_900,
    "RAIV" => 102_000,
    "TETA" => 300_400,
    "TETN" => 300_500,
    "TUBE" => 411_500,
    "VIOL" => 300_800,
    "ZIKA" => 110_100
  }

  @spec run :: :ok
  def run do
    File.rm_rf!(@output_dir)
    File.mkdir_p!(@output_dir)

    @input_dir
    |> File.ls!()
    |> Enum.sort()
    |> inform_files()
    |> Stream.with_index(1)
    |> Task.async_stream(&parse_data_and_append_to_csv/1, timeout: :infinity)
    |> Stream.run()

    @output_dir
    |> File.ls!()
    |> Enum.each(&sort_file/1)
  end

  defp inform_files(file_names) do
    Logger.info("#{Enum.count(file_names)} files identified")
    file_names
  end

  defp parse_data_and_append_to_csv({file_name, file_index}) do
    if rem(file_index, 500) == 0 do
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

  defp parse_index(line, {column_names, type, required_or_optional}) when is_list(column_names) do
    column_names
    |> Enum.map(&parse_index(line, {&1, type, :optional}))
    |> Enum.map(&elem(&1, 0))
    |> Enum.reject(&is_nil/1)
    |> case do
      [] ->
        if(required_or_optional == :required,
          do: raise("Columns not found"),
          else: {nil, type, required_or_optional}
        )

      indexes ->
        {indexes, type, required_or_optional}
    end
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
    |> add_base_context(String.slice(file_name, 0, 4))
    |> maybe_add_week()
    |> append_to_csv()
  rescue
    error ->
      Logger.error("[#{file_name}:#{line_index}] #{Exception.message(error)}")
      :ok
  end

  defp parse_item(line, {indexes, type, required_or_optional})
       when is_list(indexes) do
    indexes
    |> Enum.map(&parse_item(line, {&1, type, :optional}))
    |> Enum.reject(&is_nil/1)
    |> case do
      [] -> if(required_or_optional == :required, do: raise("Data not found"), else: nil)
      [value | _values] -> value
    end
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
      :date -> parse_date!(value)
    end
  rescue
    _error -> nil
  end

  defp parse_date!(value) do
    case Date.from_iso8601(value) do
      {:ok, %{year: year} = date} ->
        if year >= 2000 and year <= 2020 do
          {week_year, week} = :calendar.iso_week_number(Date.to_erl(date))
          {year, week_year, week}
        else
          nil
        end

      _error ->
        year = String.to_integer(value)

        if year >= 2000 and year <= 2020 do
          year
        else
          nil
        end
    end
  end

  defp add_base_context([date | line], file_name), do: [date, Map.fetch!(@bases_contexts, file_name)] ++ line

  defp maybe_add_week([{year, week_year, week} | line]), do: [year, week_year, week] ++ line
  defp maybe_add_week([year | line]), do: [year, nil, nil] ++ line

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
