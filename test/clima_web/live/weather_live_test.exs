defmodule ClimaWeb.WeatherLiveTest do
  use ClimaWeb.ConnCase

  import Phoenix.LiveViewTest
  import Clima.FavoritesFixtures

  test "disconnected and connected render", %{conn: conn} do
    {:ok, _weather_live, html} = live(conn, ~p"/")

    assert html =~ "Clima Weather"
    assert html =~ "Search cities worldwide and track your favorites"
  end

  test "displays favorite cities for authenticated users", %{conn: conn} do
    user = Clima.AccountsFixtures.user_fixture()

    # Create a favorite for the user
    {:ok, _favorites} =
      Clima.Favorites.create_favorite_city(
        %{
          name: "Test City",
          country: "TC",
          lat: 40.0,
          lon: -74.0
        },
        user
      )

    # Log in the user
    conn = conn |> log_in_user(user)

    {:ok, _weather_live, html} = live(conn, ~p"/")

    assert html =~ "Test City"
    assert html =~ "TC"
  end

  test "shows empty state for anonymous users", %{conn: conn} do
    # Anonymous users start with no favorites
    {:ok, _weather_live, html} = live(conn, ~p"/")

    assert html =~ "No favorite cities yet"
    assert html =~ "Create an account"
  end
end
