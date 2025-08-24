defmodule Observability.Metrics do
  def count(name, count) when is_integer(count) do
    execute(name, 1, %{})
  end

  def count(name, tags) when is_map(tags) do
    execute(name, 1, tags)
  end

  def count(name, count \\ 1, tags \\ %{}) when is_map(tags) do
    execute(name, count, tags)
  end

  def execute(name, count, tags) do
    metrics_name = prep_name(name)

    :telemetry.execute(
      metrics_name,
      %{total: count},
      tags
    )
  end

  defp prep_name(name) when is_list(name), do: name

  defp prep_name(name) when is_binary(name) do
    Enum.map(String.split(name, "."), &String.to_atom/1)
  end
end
