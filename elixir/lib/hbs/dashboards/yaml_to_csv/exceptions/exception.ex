defmodule HBS.Dashboards.YAMLToCSV.Exception do
  @messages %{
    ls_failed: "Failed to list files from the input path",
    kind_not_found: "Kind key is required"
  }

  @type t :: %__MODULE__{
          reason: atom,
          data: map,
          metadata: any
        }

  defexception [:reason, :data, :metadata]

  @impl Exception
  @spec message(t()) :: String.t()
  def message(%{reason: reason, data: data, metadata: metadata}) do
    """
    data: #{inspect(data, limit: :infinity, pretty: true)}
    metadata: #{inspect(metadata, limit: :infinity, pretty: true)}
    #{@messages[reason]}
    #{reason}
    """
  end

  @spec new(atom, map | nil, keyword) :: t()
  def new(reason, data \\ nil, metadata), do: %__MODULE__{reason: reason, data: data, metadata: metadata}
end
