defmodule DebugFavoritesTest do
  use Clima.DataCase

  alias Clima.Favorites

  test "create favorite with string parameters like from LiveView" do
    # This simulates exactly what comes from Phoenix LiveView phx-value-* attributes  
    params = %{
      "name" => "London",
      "country" => "England",
      "state" => "GB",
      "lat" => "51.51",
      "lon" => "-0.13"
    }

    session = %{}

    IO.puts("Testing with params:")
    IO.inspect(params)

    result = Favorites.create_favorite_city(params, session)
    IO.puts("Result:")
    IO.inspect(result)

    assert match?({:ok, _}, result)
  end
end
