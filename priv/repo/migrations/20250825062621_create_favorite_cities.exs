defmodule Clima.Repo.Migrations.CreateFavoriteCities do
  use Ecto.Migration

  def change do
    create table(:favorite_cities) do
      add :name, :string, null: false
      add :country, :string, null: false
      add :state, :string
      add :lat, :float, null: false
      add :lon, :float, null: false
      add :openweather_id, :integer

      timestamps()
    end

    create unique_index(:favorite_cities, [:lat, :lon])
    create index(:favorite_cities, [:name])
  end
end
