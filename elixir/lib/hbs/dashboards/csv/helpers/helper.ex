defmodule HBS.Dashboards.CSV.Helper do
  alias HBS.Dashboards.CSV

  @spec raise_error(atom, keyword) :: none
  def raise_error(reason, metadata) do
    raise """
    #{reason}
    #{inspect(metadata, limit: :infinity, pretty: true)}
    """
  end

  @spec raise_error(atom, CSV.t(), any) :: none
  def raise_error(reason, data, metadata) do
    raise """
    #{reason}
    #{inspect(metadata, limit: :infinity, pretty: true)}
    #{inspect(data, limit: :infinity, pretty: true)}
    """
  end

  @spec where(CSV.t(), any, (CSV.t() -> CSV.t())) :: CSV.t()
  def where(data, where_function, function) when is_function(where_function) do
    where(data, where_function.(data), function)
  end

  def where(%{where: where} = data, where_value, function) do
    data
    |> struct(where: [where_value | where])
    |> function.()
    |> struct(where: where)
  end
end
