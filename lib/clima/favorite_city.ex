defmodule Clima.FavoriteCity do
  use Ecto.Schema
  import Ecto.Changeset

  schema "favorite_cities" do
    field :name, :string
    field :country, :string
    field :state, :string
    field :lat, :float
    field :lon, :float
    field :openweather_id, :integer

    belongs_to :user, Clima.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(favorite_city, attrs) do
    favorite_city
    |> cast(attrs, [:name, :country, :state, :lat, :lon, :openweather_id, :user_id])
    |> validate_required([:name, :country, :lat, :lon])
    |> unique_constraint([:user_id, :lat, :lon],
      name: :favorite_cities_user_lat_lon_index,
      message: "You have already favorited this city"
    )
  end
end
