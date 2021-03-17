defmodule HBS.GeoJSON.Countries do
  require Logger

  @dir Path.join(File.cwd!(), ".misc/sandbox")
  @input_dir Path.join(@dir, "input")
  @output_dir Path.join(@dir, "output/geojson")
  @geojson Path.join(@input_dir, "countries.geojson")

  @spec run :: :ok
  def run do
    File.mkdir_p!(@output_dir)

    @geojson
    |> File.read!()
    |> Jason.decode!()
    |> Map.fetch!("features")
    |> Enum.map(&parse_feature/1)
    |> write()
  end

  defp parse_feature(feature) do
    feature
    |> Map.put("properties", %{"id" => 76})
  end

  defp write(features) do
    @output_dir
    |> Path.join("countries.geojson")
    |> File.write!(Jason.encode!(%{"type" => "FeatureCollection", "features" => features}))
  end
end
