defmodule Extask.RequestValidator.Job do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:tasks]}

  @type t :: %__MODULE__{
          parallel: boolean(),
          tasks: [Task.t()]
        }

  defmodule Task do
    use Ecto.Schema
    import Ecto.Changeset

    @derive {Jason.Encoder, only: [:name, :command, :requires]}

    @type t :: %__MODULE__{
            name: String.t(),
            command: String.t(),
            requires: [String.t()]
          }

    @required_attributes [:name, :command]
    @allowed_attributes [:requires] ++ @required_attributes

    embedded_schema do
      field :name, :string
      field :command, :string
      field :requires, {:array, :string}, default: []
    end

    def changeset(%__MODULE__{} = schema \\ %__MODULE__{}, params) do
      schema
      |> cast(params, @allowed_attributes)
      |> validate_required(@required_attributes)
    end
  end

  embedded_schema do
    field :parallel, :boolean, default: false
    embeds_many :tasks, Task
  end

  def changeset(params) do
    %__MODULE__{}
    |> cast(params, [:parallel])
    |> cast_embed(:tasks, required: true, with: &Task.changeset/2)
  end
end
