defmodule Commander.JobProcessor.Job do
  @moduledoc """
  A Job represents a list of tasks and how they should be executed.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Commander.JobProcessor.Task

  @derive {Jason.Encoder, only: [:tasks]}

  @type t :: %__MODULE__{
          parallel: boolean(),
          tasks: [Task.t()]
        }

  embedded_schema do
    field(:parallel, :boolean, default: false)
    embeds_many(:tasks, Task)
  end

  def changeset(params) do
    %__MODULE__{}
    |> cast(params, [:parallel])
    |> cast_embed(:tasks, required: true, with: &Task.changeset/2)
  end
end
