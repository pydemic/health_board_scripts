defmodule HBS.Geo.LocationsChildren do
  # alias HealthBoard.Contexts.Geo.Locations

  @dir Path.join(File.cwd!(), ".misc/sandbox")

  @output_dir Path.join(@dir, "output")
  @output_path Path.join(@output_dir, "locations_children.csv")

  @spec run :: :ok
  def run do
    File.rm_rf!(@output_path)
    File.mkdir_p!(@output_dir)

    # Locations.list_by()
    []
    |> Task.async_stream(&write_lines/1, timeout: :infinity)
    |> Stream.run()

    sort_file()

    :ok
  end

  defp write_lines(%{id: id, parent_id: parent_id, context: context}) do
    case context do
      0 ->
        :ok

      1 ->
        write_line([0, parent_id, 1, id])

      2 ->
        write_line([0, 76, 2, id])
        write_line([1, parent_id, 2, id])

      3 ->
        write_line([0, 76, 3, id])
        write_line([1, div(parent_id, 10), 3, id])
        write_line([2, parent_id, 3, id])

      4 ->
        write_line([0, 76, 4, id])
        write_line([1, div(parent_id, 10_000), 4, id])
        write_line([2, div(parent_id, 1_000), 4, id])
        write_line([3, parent_id, 4, id])
    end
  end

  defp write_line(list), do: File.write!(@output_path, Enum.join(list, ",") <> "\n", [:append])

  defp sort_file do
    {_result, 0} = System.cmd("sort", ~w[-o #{@output_path} #{@output_path}])
  end
end
