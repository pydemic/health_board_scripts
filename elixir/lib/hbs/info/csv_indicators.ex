defmodule HBS.Info.CSVIndicators do
  @dir Path.join(File.cwd!(), ".misc/sandbox")

  @input_dir Path.join(@dir, "input")
  @dashboards_file_path Path.join(@input_dir, "indicators.yml")

  @output_dir Path.join(@dir, "output")
  @result_dir Path.join(@output_dir, "indicators")

  @spec run :: :ok
  def run do
    File.rm_rf!(@result_dir)
    File.mkdir_p!(@result_dir)

    @dashboards_file_path
    |> YamlElixir.read_all_from_file!()
    |> List.first()
    |> Enum.map(&parse_indicator/1)

    @result_dir
    |> File.ls!()
    |> Enum.map(&sort_file(Path.join(@result_dir, &1)))

    :ok
  end

  defp parse_indicator({indicator_id, indicator}) do
    sources = Map.get(indicator, "sources", [])
    Enum.each(sources, &parse_source(indicator_id, &1))

    children = Map.get(indicator, "children", [])
    Enum.each(children, &parse_child(indicator_id, &1))

    %{"description" => description, "formula" => formula} = indicator
    measurement_unit = Map.get(indicator, "measurement_unit", "")
    reference = Map.get(indicator, "reference", "")

    [
      indicator_id,
      safe_string(description),
      safe_string(formula),
      safe_string(measurement_unit),
      safe_string(reference)
    ]
    |> Enum.join(",")
    |> Kernel.<>("\n")
    |> write_to_file("indicators")
  end

  defp parse_source(indicator_id, source_id) do
    [indicator_id, source_id]
    |> Enum.join(",")
    |> Kernel.<>("\n")
    |> write_to_file("indicators_sources")
  end

  defp parse_child(parent_id, child_id) do
    [parent_id, child_id]
    |> Enum.join(",")
    |> Kernel.<>("\n")
    |> write_to_file("indicators_children")
  end

  defp safe_string(string) do
    if String.contains?(string, ",") do
      ~s("#{string}")
    else
      string
    end
  end

  defp write_to_file(line, file_name) do
    @result_dir
    |> Path.join("#{file_name}.csv")
    |> File.write!(line, [:append])
  end

  defp sort_file(filename) do
    System.cmd("sort", ["-o", filename, filename])
  end
end
