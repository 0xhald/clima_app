defmodule Clima.WeatherServiceTest do
  use ExUnit.Case, async: true
  alias Clima.WeatherService

  describe "WeatherService" do
    test "module is loaded and functions are available" do
      # Verify the module exists and exports expected functions
      assert Code.ensure_loaded?(WeatherService)
      assert :erlang.function_exported(WeatherService, :search_cities, 2)
      assert :erlang.function_exported(WeatherService, :get_current_weather, 2)
      assert :erlang.function_exported(WeatherService, :get_forecast, 2)
    end

    test "uses configured weather provider" do
      # Verify that WeatherService delegates to the configured provider
      provider = Application.get_env(:clima, :weather_provider)
      assert provider == Clima.WeatherProviders.OpenweatherProvider
      assert Code.ensure_loaded?(provider)
    end

    test "provider implements required behaviour" do
      # Verify the configured provider implements the WeatherProvider behaviour
      provider = Application.get_env(:clima, :weather_provider)
      behaviours = provider.module_info(:attributes)[:behaviour] || []
      assert Clima.WeatherProvider in behaviours
    end
  end
end
