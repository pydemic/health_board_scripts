defmodule HBS.Demographic.YearlyPopulationsToConsolidations do
  @dir Path.join(File.cwd!(), ".misc/sandbox")

  @default_input_path Path.join(@dir, "input/yearly_populations.csv")
  @default_output_path Path.join(@dir, "output/populations")

  @ylc "yearly_locations_consolidations"
  @lc "locations_consolidations"

  @total_group 100_000
  @total_group_name "demographics_populations_total"

  @per_gender_group 100_001
  @per_gender_group_name "demographics_populations_per_gender"

  @per_age_group 100_002
  @per_age_group_name "demographics_populations_per_age"

  @spec run(String.t(), String.t()) :: :ok
  def run(input_path \\ @default_input_path, output_path \\ @default_output_path) do
    input_path
    |> File.stream!()
    |> NimbleCSV.RFC4180.parse_stream(skip_headers: false)
    |> Enum.reduce({{[], [], []}, {[], [], []}}, &parse/2)
    |> write(output_path)

    :ok
  end

  defp parse(line, {yearly_locations_consolidations, locations_consolidations}) do
    [
      location_id,
      year,
      male,
      female,
      age_0_4,
      age_5_9,
      age_10_14,
      age_15_19,
      age_20_24,
      age_25_29,
      age_30_34,
      age_35_39,
      age_40_44,
      age_45_49,
      age_50_54,
      age_55_59,
      age_60_64,
      age_65_69,
      age_70_74,
      age_75_79,
      age_80_or_more
    ] = line

    total = String.to_integer(male) + String.to_integer(female)
    per_gender = wrap_cell([male, female])

    per_age =
      wrap_cell([
        age_0_4,
        age_5_9,
        age_10_14,
        age_15_19,
        age_20_24,
        age_25_29,
        age_30_34,
        age_35_39,
        age_40_44,
        age_45_49,
        age_50_54,
        age_55_59,
        age_60_64,
        age_65_69,
        age_70_74,
        age_75_79,
        age_80_or_more
      ])

    if year == "2020" do
      {
        append([location_id, year], total, per_gender, per_age, yearly_locations_consolidations),
        append([location_id], total, per_gender, per_age, locations_consolidations)
      }
    else
      {
        yearly_locations_consolidations,
        locations_consolidations
      }
    end
  end

  defp wrap_cell(list), do: ~s("#{Enum.join(list, ",")}")

  defp append(key, total, per_gender, per_age, {total_c, per_gender_c, per_age_c}) do
    {
      [Enum.join([@total_group | key ++ [total, nil]], ",") | total_c],
      [Enum.join([@per_gender_group | key ++ [nil, per_gender]], ",") | per_gender_c],
      [Enum.join([@per_age_group | key ++ [nil, per_age]], ",") | per_age_c]
    }
  end

  defp write({{total_ylc, per_gender_ylc, per_age_ylc}, {total_lc, per_gender_lc, per_age_lc}}, output_path) do
    write_consolidation(total_ylc, output_path, @ylc, @total_group, @total_group_name)
    write_consolidation(per_gender_ylc, output_path, @ylc, @per_gender_group, @per_gender_group_name)
    write_consolidation(per_age_ylc, output_path, @ylc, @per_age_group, @per_age_group_name)

    write_consolidation(total_lc, output_path, @lc, @total_group, @total_group_name)
    write_consolidation(per_gender_lc, output_path, @lc, @per_gender_group, @per_gender_group_name)
    write_consolidation(per_age_lc, output_path, @lc, @per_age_group, @per_age_group_name)
  end

  defp write_consolidation(consolidations, output_path, consolidation_type, group_id, group_name) do
    path = Path.join([output_path, consolidation_type, "#{group_id}_#{group_name}"])
    content = consolidations |> Enum.sort() |> Enum.join("\n")

    File.rm_rf!(path)
    File.mkdir_p!(path)

    File.write!(Path.join(path, "0000.csv"), content)
  end
end
