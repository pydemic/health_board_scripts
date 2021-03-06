defmodule HBS.GeoJSON.Cities do
  require Logger

  @dir Path.join(File.cwd!(), ".misc/sandbox")
  @input_dir Path.join(@dir, "input")
  @output_dir Path.join(@dir, "output/geojson")
  @geojson Path.join(@input_dir, "cities.geojson")

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
    {%{"regiao_saude.id" => location_id}, feature} = Map.pop!(feature, "properties")
    Map.put(feature, "properties", %{"id" => location_id})
  end

  defp write(features) do
    @output_dir
    |> Path.join("cities.geojson")
    |> File.write!(Jason.encode!(%{"type" => "FeatureCollection", "features" => features}))
  end
end
