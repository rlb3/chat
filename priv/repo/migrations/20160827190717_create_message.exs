defmodule Chat.Repo.Migrations.CreateMessage do
  use Ecto.Migration

  def change do
    create table(:messages, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :username, :string
      add :chanel, :string
      add :body, :text

      timestamps()
    end

  end
end
