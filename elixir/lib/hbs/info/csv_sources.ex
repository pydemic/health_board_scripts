defmodule HBS.Info.CSVSources do
  @dir Path.join(File.cwd!(), ".misc/sandbox")

  @input_dir Path.join(@dir, "input")
  @input_file_path Path.join(@input_dir, "sources.yml")

  @output_dir Path.join(@dir, "output")
  @output_file_path Path.join(@output_dir, "sources.csv")

  @spec run(String.t()) :: :ok
  def run(file_path \\ @input_file_path) do
    file_path
    |> YamlElixir.read_all_from_file!()
    |> List.first()
    |> Enum.map(&parse_object_to_line/1)
    |> Enum.join("\n")
    |> write_file()

    sort_file()

    :ok
  end

  defp parse_object_to_line({source_id, source}) do
    %{
      "name" => name,
      "description" => description,
      "link" => link,
      "update_rate" => update_rate,
      "last_update_date" => last_update_date,
      "extraction_date" => extraction_date
    } = source

    Enum.join(
      [
        source_id,
        safe_string(name),
        safe_string(description),
        ~s("#{link}"),
        safe_string(update_rate),
        safe_string(last_update_date),
        safe_string(extraction_date)
      ],
      ","
    )
  end

  defp safe_string(string) do
    if String.contains?(string, ",") do
      ~s("#{string}")
    else
      string
    end
  end

  defp write_file(output) do
    File.write!(@output_file_path, output)
  end

  defp sort_file do
    System.cmd("sort", ["-o", @output_file_path, @output_file_path])
  end
end
