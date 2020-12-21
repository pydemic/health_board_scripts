defmodule HBS.GenericScript.ParserYMLToCSV do
  @input_filename "./INPUT/cards.yml"
  @output_filename "./OUTPUT/cards.csv"

  def card do
    @input_filename
    |> YamlElixir.read_all_from_file!()
    |> List.first()
    |> Enum.map(&parse_object_to_line/1)
    |> Enum.join("\n")
    |> write_file()

    sort_file()

    :ok
  end

  defp parse_object_to_line(
         {card_id,
          %{"indicator_id" => indicator_id, "name" => name, "description" => description}}
       ) do
    Enum.join([indicator_id, card_id, safe_string(name), safe_string(description)], ",")
  end

  defp safe_string(string) do
    if String.contains?(string, ",") do
      ~s("#{string}")
    else
      string
    end
  end

  defp write_file(output) do
    File.write!(@output_filename, output)
  end

  defp sort_file do
    System.cmd("sort", ["-o", @output_filename, @output_filename])
  end
end
