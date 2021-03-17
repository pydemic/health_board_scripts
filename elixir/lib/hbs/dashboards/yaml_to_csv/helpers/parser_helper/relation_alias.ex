defmodule HBS.Dashboards.YAMLToCSV.ParseHelper.RelationSID do
  alias HBS.Dashboards.YAMLToCSV.ParseHelper

  @spec parse(struct, String.t(), atom, keyword) :: struct
  def parse(struct, key, to_group, opts \\ []) do
    struct
    |> ParseHelper.String.parse(key, opts)
    |> parse_relation_sid(to_group, opts)
  end

  defp parse_relation_sid(struct, to_group, _opts) do
    %{index: index, group: group, data: %{requirements: requirements} = data} = struct

    case List.last(Enum.with_index(struct.row)) do
      {nil, _index} ->
        struct

      {sid, row_index} ->
        get_keys = [to_group, sid]
        put_keys = [group, index, row_index + 1]

        struct(struct,
          data: struct(data, requirements: Map.update(requirements, get_keys, [put_keys], &[put_keys | &1]))
        )

      _result ->
        struct
    end
  end
end
