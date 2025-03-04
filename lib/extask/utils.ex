defmodule Extask.Utils do
  def tag(:ok, _tag), do: :ok
  def tag(:error, tag), do: {tag, :error}

  def tag({:ok, _} = data, _tag), do: data
  def tag({:error, _} = error, tag), do: {tag, error}
end
