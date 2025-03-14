defmodule Commander.Validator do
  @moduledoc """
  General module for validating input parameters towards a given changeset.
  """

  alias Ecto.Changeset

  def validate(params, changeset_fun) do
    params
    |> changeset_fun.()
    |> case do
      %Changeset{valid?: true} = changeset ->
        {:ok, Changeset.apply_changes(changeset)}

      %Changeset{valid?: false} = changeset ->
        reason =
          changeset
          |> Changeset.traverse_errors(fn {msg, _} -> msg end)
          |> clean_empty_errors()

        {:error, reason}
    end
  end

  defp clean_empty_errors(errors) when is_map(errors) do
    errors
    |> Enum.map(fn {key, value} -> {key, clean_empty_errors(value)} end)
    |> Enum.reject(fn {_key, value} -> empty_value?(value) end)
    |> Enum.into(%{})
  end

  defp clean_empty_errors(errors) when is_list(errors) do
    errors
    |> Enum.map(&clean_empty_errors/1)
    |> Enum.reject(&empty_value?/1)
  end

  defp clean_empty_errors(value), do: value

  defp empty_value?(%{} = value), do: map_size(value) == 0
  defp empty_value?([]), do: true
  defp empty_value?(_), do: false
end
