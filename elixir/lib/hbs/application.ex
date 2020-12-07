defmodule HBS.Application do
  use Application

  @spec start(any(), any()) :: {:ok, pid} | {:error, any()}
  def start(_type, _args) do
    children = []
    opts = [strategy: :one_for_one, name: HBS.Supervisor]

    Supervisor.start_link(children, opts)
  end
end
