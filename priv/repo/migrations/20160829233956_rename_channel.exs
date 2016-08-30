defmodule Chat.Repo.Migrations.RenameChannel do
  use Ecto.Migration

  def change do
    rename table(:messages), :chanel, to: :channel
  end
end
