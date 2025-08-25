defmodule Clima.WeatherProvider do
  @moduledoc """
  Behaviour for weather providers.

  This behaviour defines the contract that all weather providers must implement,
  allowing the application to support multiple weather services (OpenWeatherMap,
  AccuWeather, WeatherAPI, etc.) with a consistent interface.
  """

  @doc """
  Search cities by name.
  Returns a list of city suggestions with coordinates.

  Expected return format:
  {:ok, [%{
    name: "City Name",
    country: "Country Code", 
    state: "State" | nil,
    lat: float(),
    lon: float(),
    display_name: "Formatted Display Name"
  }]}
  """
  @callback search_cities(query :: String.t(), limit :: integer()) ::
              {:ok, [map()]} | {:error, String.t() | atom()}

  @doc """
  Get current weather for coordinates.

  Expected return format:
  {:ok, %{
    temperature: integer(),
    feels_like: integer(),
    temp_min: integer(),
    temp_max: integer(),
    humidity: integer(),
    pressure: integer(),
    description: String.t(),
    icon: String.t(),
    city_name: String.t()
  }}
  """
  @callback get_current_weather(lat :: float(), lon :: float()) ::
              {:ok, map()} | {:error, String.t() | atom()}

  @doc """
  Get forecast data including hourly and daily forecasts.

  Expected return format:
  {:ok, %{
    hourly: [%{
      datetime: DateTime.t(),
      hour: integer(),
      temperature: integer(),
      description: String.t(),
      icon: String.t()
    }],
    daily: [%{
      date: Date.t(),
      temp_min: integer(),
      temp_max: integer(),
      description: String.t(),
      icon: String.t()
    }]
  }}
  """
  @callback get_forecast(lat :: float(), lon :: float()) ::
              {:ok, map()} | {:error, String.t() | atom()}
end
