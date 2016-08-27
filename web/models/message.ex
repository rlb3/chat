defmodule Chat.Message do
  use Chat.Web, :model

  schema "messages" do
    field :username, :string
    field :chanel, :string
    field :body, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:username, :chanel, :body])
    |> validate_required([:username, :chanel, :body])
  end
end
