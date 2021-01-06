defmodule HBS.Info.CSVDashboards do
  @dir Path.join(File.cwd!(), ".misc/sandbox")

  @input_dir Path.join(@dir, "input")
  @input_file_path Path.join(@input_dir, "dashboards.yml")

  @output_dir Path.join(@dir, "output")
  @result_dir Path.join(@output_dir, "dashboards")

  @spec run(String.t()) :: :ok
  def run(file_path \\ @input_file_path) do
    File.rm_rf!(@result_dir)
    File.mkdir_p!(@result_dir)

    file_path
    |> YamlElixir.read_all_from_file!()
    |> List.first()
    |> Enum.map(&parse_dashboard/1)

    @result_dir
    |> File.ls!()
    |> Enum.map(&sort_file(Path.join(@result_dir, &1)))

    :ok
  end

  defp parse_dashboard({dashboard_id, %{"name" => name, "description" => description, "groups" => groups}}) do
    Enum.each(groups, &parse_group(dashboard_id, &1))

    date_now = DateTime.to_iso8601(DateTime.utc_now())

    [
      dashboard_id,
      safe_string(name),
      safe_string(description),
      date_now,
      date_now
    ]
    |> Enum.join(",")
    |> Kernel.<>("\n")
    |> write_to_file("dashboards")
  end

  defp parse_group(dashboard_id, {group_id, group}) do
    %{"index" => index, "name" => name, "description" => description, "sections" => sections} = group

    Enum.each(sections, &parse_section(group_id, &1))

    [dashboard_id, index, group_id, safe_string(name), safe_string(description)]
    |> Enum.join(",")
    |> Kernel.<>("\n")
    |> write_to_file("groups")
  end

  defp parse_section(group_id, {section_id, section}) do
    %{"index" => index, "name" => name, "description" => description, "cards" => cards} = section

    Enum.each(cards, &parse_card(section_id, &1))

    [group_id, index, section_id, safe_string(name), safe_string(description)]
    |> Enum.join(",")
    |> Kernel.<>("\n")
    |> write_to_file("sections")
  end

  defp parse_card(section_id, {section_card_id, section_card}) do
    %{"index" => index, "card_id" => card_id} = section_card

    Enum.each(section_card["filters"] || %{}, &parse_filter(section_card_id, &1))

    [
      section_id,
      index,
      card_id,
      section_card_id,
      safe_string(section_card["name"] || ""),
      section_card["link"]
    ]
    |> Enum.join(",")
    |> Kernel.<>("\n")
    |> write_to_file("sections_cards")
  end

  defp parse_filter(section_card_id, {filter_name, filter_value}) do
    [section_card_id, filter_name, parse_filter_value(filter_value)]
    |> Enum.join(",")
    |> Kernel.<>("\n")
    |> write_to_file("sections_cards_filters")
  end

  defp parse_filter_value(value) do
    case value do
      list when is_list(list) ->
        list
        |> Enum.map(&parse_filter_value_string/1)
        |> Enum.join(",")
        |> safe_string()

      string ->
        parse_filter_value_string(string)
    end
  end

  defp parse_filter_value_string(string) do
    string
    |> String.replace("_", "")
    |> String.to_integer()
  rescue
    _error -> string
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
