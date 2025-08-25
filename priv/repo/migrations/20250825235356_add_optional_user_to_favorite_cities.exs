defmodule Clima.Repo.Migrations.AddOptionalUserToFavoriteCities do
  use Ecto.Migration

  def change do
    alter table(:favorite_cities) do
      add :user_id, references(:users, on_delete: :delete_all), null: true
    end

    create index(:favorite_cities, [:user_id])

    # Remove the global unique constraint and add user-specific constraint
    drop unique_index(:favorite_cities, [:lat, :lon])

    create unique_index(:favorite_cities, [:user_id, :lat, :lon],
             where: "user_id IS NOT NULL",
             name: :favorite_cities_user_lat_lon_index
           )
  end
end
