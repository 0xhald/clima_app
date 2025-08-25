defmodule Clima.WeatherProviders.OpenweatherProvider do
  @moduledoc """
  OpenWeatherMap weather provider implementation.

  Implements the Clima.WeatherProvider behaviour to provide weather data
  from the OpenWeatherMap API.
  """

  @behaviour Clima.WeatherProvider

  @base_url "https://api.openweathermap.org"
  @geocoding_url "#{@base_url}/geo/1.0"
  @weather_url "#{@base_url}/data/2.5"

  @impl Clima.WeatherProvider
  def search_cities(query, limit \\ 5) do
    url = "#{@geocoding_url}/direct"

    params = %{
      q: query,
      limit: limit,
      appid: api_key()
    }

    case Req.get(url, params: params) do
      {:ok, %{status: 200, body: cities}} ->
        formatted_cities = Enum.map(cities, &format_city_result/1)
        {:ok, formatted_cities}

      {:ok, %{status: status}} ->
        {:error, "API returned status #{status}"}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @impl Clima.WeatherProvider
  def get_current_weather(lat, lon) do
    url = "#{@weather_url}/weather"

    params = %{
      lat: lat,
      lon: lon,
      appid: api_key(),
      units: "metric"
    }

    case Req.get(url, params: params) do
      {:ok, %{status: 200, body: weather_data}} ->
        {:ok, format_current_weather(weather_data)}

      {:ok, %{status: status}} ->
        {:error, "API returned status #{status}"}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @impl Clima.WeatherProvider
  def get_forecast(lat, lon) do
    url = "#{@weather_url}/forecast"

    params = %{
      lat: lat,
      lon: lon,
      appid: api_key(),
      units: "metric"
    }

    case Req.get(url, params: params) do
      {:ok, %{status: 200, body: forecast_data}} ->
        {:ok, format_forecast_data(forecast_data)}

      {:ok, %{status: status}} ->
        {:error, "API returned status #{status}"}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp format_city_result(city) do
    %{
      name: city["name"],
      country: city["country"],
      state: city["state"],
      lat: city["lat"],
      lon: city["lon"],
      display_name: format_display_name(city)
    }
  end

  defp format_display_name(city) do
    case city["state"] do
      nil -> "#{city["name"]}, #{city["country"]}"
      state -> "#{city["name"]}, #{state}, #{city["country"]}"
    end
  end

  defp format_current_weather(data) do
    main = data["main"]
    weather = List.first(data["weather"])

    %{
      temperature: round(main["temp"]),
      feels_like: round(main["feels_like"]),
      temp_min: round(main["temp_min"]),
      temp_max: round(main["temp_max"]),
      humidity: main["humidity"],
      pressure: main["pressure"],
      description: weather["description"],
      icon: weather["icon"],
      city_name: data["name"]
    }
  end

  defp format_forecast_data(data) do
    forecasts = data["list"]

    # Get next 24 hours (8 entries, 3-hour intervals)
    hourly =
      Enum.take(forecasts, 8)
      |> Enum.map(&format_hourly_forecast/1)

    # Group by day for daily forecasts
    daily =
      forecasts
      |> Enum.group_by(fn forecast ->
        DateTime.from_unix!(forecast["dt"])
        |> DateTime.to_date()
      end)
      |> Enum.map(fn {date, day_forecasts} ->
        format_daily_forecast(date, day_forecasts)
      end)
      |> Enum.take(5)

    %{
      hourly: hourly,
      daily: daily
    }
  end

  defp format_hourly_forecast(forecast) do
    main = forecast["main"]
    weather = List.first(forecast["weather"])
    datetime = DateTime.from_unix!(forecast["dt"])

    %{
      datetime: datetime,
      hour: datetime.hour,
      temperature: round(main["temp"]),
      description: weather["description"],
      icon: weather["icon"]
    }
  end

  defp format_daily_forecast(date, forecasts) do
    temps = Enum.map(forecasts, fn f -> f["main"]["temp"] end)
    weather = List.first(forecasts)["weather"] |> List.first()

    %{
      date: date,
      temp_min: round(Enum.min(temps)),
      temp_max: round(Enum.max(temps)),
      description: weather["description"],
      icon: weather["icon"]
    }
  end

  defp api_key do
    System.get_env("OPENWEATHER_API_KEY")
  end
end
