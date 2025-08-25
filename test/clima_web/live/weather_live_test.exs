defmodule ClimaWeb.WeatherLiveTest do
  use ClimaWeb.ConnCase

  import Phoenix.LiveViewTest
  import Clima.FavoritesFixtures

  test "disconnected and connected render", %{conn: conn} do
    {:ok, _weather_live, html} = live(conn, ~p"/")

    assert html =~ "Clima Weather"
    assert html =~ "Search cities worldwide and track your favorites"
  end

  test "displays favorite cities", %{conn: conn} do
    favorite_city_fixture(%{name: "Test City", country: "TC"})

    {:ok, _weather_live, html} = live(conn, ~p"/")

    assert html =~ "Test City"
    assert html =~ "TC"
  end

  test "displays welcome message when no city selected", %{conn: conn} do
    {:ok, _weather_live, html} = live(conn, ~p"/")

    assert html =~ "Welcome to Clima Weather"
    assert html =~ "Search for cities and add them to favorites"
  end
end
