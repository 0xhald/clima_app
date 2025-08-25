defmodule Clima.FavoritesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Clima.Favorites` context.
  """

  @doc """
  Generate a favorite_city.
  """
  def favorite_city_fixture(attrs \\ %{}) do
    {:ok, favorite_city} =
      attrs
      |> Enum.into(%{
        name: "New York",
        country: "US",
        state: "NY",
        lat: 40.7128,
        lon: -74.0060
      })
      |> Clima.Favorites.create_favorite_city()

    favorite_city
  end
end
