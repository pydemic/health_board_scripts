defmodule HBS.GeoJSON.Cities do
  require Logger

  @dir Path.join(File.cwd!(), ".misc/sandbox")
  @input_dir Path.join(@dir, "input")
  @brazil_dir Path.join(@input_dir, "76")

  @spec run :: :ok
  def run do
    @brazil_dir
    |> File.ls!()
    |> Enum.map(&Path.join(@brazil_dir, &1))
    |> Enum.filter(&File.dir?/1)
    |> Enum.sort()
    |> Enum.flat_map(&cities_from_region/1)
    |> write_geojson(@brazil_dir)

    :ok
  end

  defp cities_from_region(path) do
    path
    |> File.ls!()
    |> Enum.map(&Path.join(path, &1))
    |> Enum.filter(&File.dir?/1)
    |> Enum.sort()
    |> Enum.flat_map(&cities_from_state/1)
    |> write_geojson(path)
  end

  defp cities_from_state(path) do
    path
    |> File.ls!()
    |> Enum.map(&Path.join(path, &1))
    |> Enum.filter(&File.dir?/1)
    |> Enum.sort()
    |> Enum.flat_map(&cities_from_health_region/1)
    |> write_geojson(path)
  end

  defp cities_from_health_region(path) do
    path
    |> Path.join("cities.geojson")
    |> File.read!()
    |> Jason.decode!()
    |> Map.fetch!("features")
  end

  defp write_geojson(features, path) do
    path
    |> Path.join("cities.geojson")
    |> File.write!(Jason.encode!(%{"type" => "FeatureCollection", "features" => features}))

    features
  end
end
