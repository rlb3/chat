defmodule Chat.Message do
  use Chat.Web, :model

  schema "messages" do
    field :username, :string
    field :channel, :string
    field :body, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:username, :channel, :body])
    |> validate_required([:username, :channel, :body])
  end

  def recent do
    from(m in __MODULE__,
      limit: 5,
      order_by: [desc: :inserted_at])
  end
end
