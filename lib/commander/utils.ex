defmodule Commander.Utils do
  @moduledoc """
  Holds helper function for control flow
  """

  @spec tag_error(success_input | error_input, tag) ::
          success_input | {tag, error_input}
        when success_input: :ok | {:ok, term()},
             error_input: :error | {:error, term()},
             tag: term()
  def tag_error(input, tag)

  def tag_error(:ok, _tag), do: :ok
  def tag_error(:error, tag), do: {tag, :error}

  def tag_error({:ok, _} = data, _tag), do: data
  def tag_error({:error, _} = error, tag), do: {tag, error}
end
