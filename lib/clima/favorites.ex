defmodule Clima.Favorites do
  @moduledoc """
  Context for managing favorite cities.
  """

  import Ecto.Query, warn: false
  alias Clima.Repo
  alias Clima.FavoriteCity

  @doc """
  Returns the list of favorite cities.
  """
  def list_favorite_cities do
    Repo.all(from f in FavoriteCity, order_by: f.name)
  end

  @doc """
  Gets a single favorite city.
  """
  def get_favorite_city!(id), do: Repo.get!(FavoriteCity, id)

  @doc """
  Creates a favorite city.
  """
  def create_favorite_city(attrs \\ %{}) do
    %FavoriteCity{}
    |> FavoriteCity.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Deletes a favorite city.
  """
  def delete_favorite_city(%FavoriteCity{} = favorite_city) do
    Repo.delete(favorite_city)
  end

  @doc """
  Check if city is already favorited by coordinates.
  """
  def city_favorited?(lat, lon) do
    query = from f in FavoriteCity, where: f.lat == ^lat and f.lon == ^lon
    Repo.exists?(query)
  end
end
