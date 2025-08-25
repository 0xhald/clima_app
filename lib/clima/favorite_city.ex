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

    timestamps()
  end

  @doc false
  def changeset(favorite_city, attrs) do
    favorite_city
    |> cast(attrs, [:name, :country, :state, :lat, :lon, :openweather_id])
    |> validate_required([:name, :country, :lat, :lon])
    |> unique_constraint([:lat, :lon])
  end
end
