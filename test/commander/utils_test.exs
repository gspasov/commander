defmodule Commander.UtilsTest do
  alias Commander.Utils
  use ExUnit.Case

  describe "tag_error/2" do
    test "returns success result when given success input" do
      assert Utils.tag_error(:ok, :tag) == :ok
      assert Utils.tag_error({:ok, :data}, :tag) == {:ok, :data}
    end

    test "returns tagged error result when given error input" do
      assert Utils.tag_error(:error, :tag) == {:tag, :error}
      assert Utils.tag_error({:error, :reason}, :tag) == {:tag, {:error, :reason}}
    end
  end
end
