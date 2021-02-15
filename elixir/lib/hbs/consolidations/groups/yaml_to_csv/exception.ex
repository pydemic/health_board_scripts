defmodule HBS.Consolidations.Groups.YAMLToCSV.Exception do
  @messages %{
    failed_to_create_path: "Failed to create path to the CSV directory",
    failed_to_write: "Failed to write CSV at path",
    invalid_group: "Group is not a single object with key as string and value as list",
    invalid_input: "Cannot open file, YAML is malformed, or it has an invalid structure",
    invalid_data_name: "Name is not a string",
    invalid_schema: "Schema is not a single object with key as string and value as list",
    non_unique_name: "Name already exists"
  }

  @type t :: %__MODULE__{
          reason: atom,
          metadata: any
        }

  defexception [:reason, :metadata]

  @impl Exception
  @spec message(t()) :: String.t()
  def message(%{reason: reason, metadata: metadata}) do
    """
    #{reason}
    #{@messages[reason]}
    metadata: #{inspect(metadata, limit: :infinity, pretty: true)}
    """
  end
end
