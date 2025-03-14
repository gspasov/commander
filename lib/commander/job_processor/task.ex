defmodule Commander.JobProcessor.Task do
  @moduledoc """
  Represents a command that should be executed.
  Holds a name and a potentially a list of dependent cmd commands that should be executed beforehand.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:name, :command, :dependencies]}

  @type t :: %__MODULE__{
          name: String.t(),
          command: String.t(),
          dependencies: [String.t()]
        }

  @required_attributes [:name, :command]
  @allowed_attributes [:dependencies] ++ @required_attributes

  embedded_schema do
    field(:name, :string)
    field(:command, :string)
    field(:dependencies, {:array, :string}, default: [])
  end

  def changeset(%__MODULE__{} = schema \\ %__MODULE__{}, params) do
    schema
    |> cast(params, @allowed_attributes)
    |> validate_required(@required_attributes)
  end
end
