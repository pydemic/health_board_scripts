defmodule HBS.Info.DataPeriodsUniqueness do
  require Logger

  @dir Path.join(File.cwd!(), ".misc/sandbox")
  @input_dir Path.join(@dir, "input")
  @output_dir Path.join(@dir, "output")
  @output_path Path.join(@output_dir, "data_periods.csv")

  @spec run :: :ok
  def run do
    File.rm_rf!(@output_path)
    File.mkdir_p!(@output_dir)

    @input_dir
    |> File.ls!()
    |> Enum.sort()
    |> inform_files()
    |> Stream.with_index(1)
    |> Task.async_stream(&open_parse_and_save/1, timeout: :infinity)
    |> Stream.run()

    @output_dir
    |> File.ls!()
    |> Enum.each(&sort_file/1)
  end

  defp inform_files(file_names) do
    Logger.info("#{Enum.count(file_names)} files identified")
    file_names
  end

  defp open_parse_and_save({file_name, file_index}) do
    Logger.info("[#{file_index}] Parsing #{file_name}")

    @input_dir
    |> Path.join(file_name)
    |> File.stream!()
    |> NimbleCSV.RFC4180.parse_stream(skip_headers: false)
    |> Enum.reduce(%{}, &parse_line/2)
    |> Enum.map(&convert_data_to_line/1)
    |> Enum.map(&append_to_csv/1)
  end

  defp parse_line([data_context, context, location_id, from, to], data) do
    dates = {Date.from_iso8601!(from), Date.from_iso8601!(to)}
    Map.update(data, {data_context, context, location_id}, dates, &dates_min_and_max(&1, dates))
  end

  defp dates_min_and_max({f1, t1}, {f2, t2}) do
    from = if Date.compare(f1, f2) != :gt, do: f1, else: f2
    to = if Date.compare(t1, t2) != :lt, do: t1, else: t2
    {from, to}
  end

  defp convert_data_to_line({{data_context, context, location_id}, {from, to}}) do
    [data_context, context, location_id, from, to]
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
