#!/usr/bin/env elixir

# Test script to debug the favorites creation issue

# Simulate the exact data that comes from Phoenix LiveView
params = %{
  "name" => "London",
  "country" => "England",
  "state" => "GB",
  "lat" => "51.51",
  "lon" => "-0.13"
}

# Simulate a session
session = %{}

IO.puts("Testing favorites creation with params:")
IO.inspect(params)

# Try to create favorite
{:ok, _} = Application.ensure_all_started([:logger, :ecto])

# Load the application
Code.require_file("lib/clima.ex")
Code.require_file("lib/clima/favorites.ex")
Code.require_file("lib/clima/favorite_city.ex")

try do
  result = Clima.Favorites.create_favorite_city(params, session)
  IO.puts("Success:")
  IO.inspect(result)
rescue
  e ->
    IO.puts("Error occurred:")
    IO.inspect(e)
    IO.puts("\nStacktrace:")
    IO.inspect(__STACKTRACE__)
end
