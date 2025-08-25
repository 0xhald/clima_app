defmodule Clima.FavoritesTest do
  use Clima.DataCase

  alias Clima.Favorites

  describe "favorite_cities" do
    alias Clima.FavoriteCity

    import Clima.FavoritesFixtures

    @invalid_attrs %{name: nil, country: nil, lat: nil, lon: nil}

    test "list_favorite_cities/0 returns all favorite_cities" do
      favorite_city = favorite_city_fixture()
      assert Favorites.list_favorite_cities() == [favorite_city]
    end

    test "get_favorite_city!/1 returns the favorite_city with given id" do
      favorite_city = favorite_city_fixture()
      assert Favorites.get_favorite_city!(favorite_city.id) == favorite_city
    end

    test "create_favorite_city/1 with valid data creates a favorite_city" do
      valid_attrs = %{
        name: "Mexico City",
        country: "MX",
        state: "CDMX",
        lat: 19.4326,
        lon: -99.1332
      }

      assert {:ok, %FavoriteCity{} = favorite_city} = Favorites.create_favorite_city(valid_attrs)
      assert favorite_city.name == "Mexico City"
      assert favorite_city.country == "MX"
      assert favorite_city.state == "CDMX"
      assert favorite_city.lat == 19.4326
      assert favorite_city.lon == -99.1332
    end

    test "create_favorite_city/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Favorites.create_favorite_city(@invalid_attrs)
    end

    test "create_favorite_city/1 with duplicate coordinates returns error changeset" do
      favorite_city_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Favorites.create_favorite_city(%{
                 name: "Another City",
                 country: "US",
                 lat: 40.7128,
                 lon: -74.0060
               })
    end

    test "delete_favorite_city/1 deletes the favorite_city" do
      favorite_city = favorite_city_fixture()
      assert {:ok, %FavoriteCity{}} = Favorites.delete_favorite_city(favorite_city)
      assert_raise Ecto.NoResultsError, fn -> Favorites.get_favorite_city!(favorite_city.id) end
    end

    test "city_favorited?/2 returns true when city exists" do
      favorite_city = favorite_city_fixture()
      assert Favorites.city_favorited?(favorite_city.lat, favorite_city.lon)
    end

    test "city_favorited?/2 returns false when city does not exist" do
      refute Favorites.city_favorited?(0.0, 0.0)
    end
  end
end
