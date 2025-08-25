defmodule Clima.WeatherProviders.OpenweatherProviderTest do
  use ExUnit.Case, async: true
  alias Clima.WeatherProviders.OpenweatherProvider

  describe "OpenweatherProvider" do
    test "module implements WeatherProvider behaviour" do
      assert Code.ensure_loaded?(OpenweatherProvider)
      behaviours = OpenweatherProvider.module_info(:attributes)[:behaviour] || []
      assert Clima.WeatherProvider in behaviours
    end

    test "exports required functions with correct arity" do
      assert :erlang.function_exported(OpenweatherProvider, :search_cities, 2)
      assert :erlang.function_exported(OpenweatherProvider, :get_current_weather, 2)
      assert :erlang.function_exported(OpenweatherProvider, :get_forecast, 2)
    end
  end
end
