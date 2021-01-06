defmodule HBS.Info.CSV do
  alias HBS.Info.{CSVCards, CSVDashboards, CSVIndicators, CSVSources}

  @dir Path.join(File.cwd!(), ".misc/sandbox")

  @input_dir Path.join(@dir, "input")

  @payload [
    {CSVCards, "cards.yml"},
    {CSVDashboards, "dashboards.yml"},
    {CSVIndicators, "indicators.yml"},
    {CSVSources, "sources.yml"}
  ]

  @spec playbook(String.t()) :: :ok
  def playbook(dir \\ @input_dir) do
    Enum.each(@payload, fn {module, file_name} -> module.run(Path.join(dir, file_name)) end)
  end
end
