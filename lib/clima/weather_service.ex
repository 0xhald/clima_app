defmodule Clima.WeatherService do
  @moduledoc """
  Main weather service facade that delegates to configured weather providers.

  This module provides a consistent interface for weather operations while
  supporting multiple weather providers (OpenWeatherMap, AccuWeather, etc.).
  The actual provider is configured in the application config.
  """

  @doc """
  Search cities by name using the configured weather provider.
  Returns a list of city suggestions with coordinates.
  """
  def search_cities(query, limit \\ 5) do
    provider().search_cities(query, limit)
  end

  @doc """
  Get current weather for coordinates using the configured weather provider.
  """
  def get_current_weather(lat, lon) do
    provider().get_current_weather(lat, lon)
  end

  @doc """
  Get hourly forecast for next 24 hours and daily forecast for 5 days
  using the configured weather provider.
  """
  def get_forecast(lat, lon) do
    provider().get_forecast(lat, lon)
  end

  defp provider do
    Application.get_env(:clima, :weather_provider, Clima.WeatherProviders.OpenweatherProvider)
  end
end
