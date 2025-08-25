# Clima Weather Application

A Phoenix/Elixir web application for searching worldwide cities and tracking weather information using the OpenWeatherMap API.

## Features

- **City Search**: Search for cities worldwide with real-time suggestions
- **Favorites Management**: Add/remove cities from your favorites list
- **Current Weather**: View temperature, min/max, humidity, and weather conditions
- **24-Hour Forecast**: Hourly weather predictions for the next 24 hours
- **5-Day Forecast**: Daily weather forecasts with min/max temperatures

## Requirements

- Elixir 1.15+
- Phoenix Framework 1.8+
- PostgreSQL
- OpenWeatherMap API key (required)

## Setup

### 1. Get OpenWeatherMap API Key
1. Visit [OpenWeatherMap API](https://openweathermap.org/api)
2. Sign up for a free account
3. Generate an API key

### 2. Set Environment Variables
The application requires the following environment variable:

```bash
export OPENWEATHER_API_KEY=your_api_key_here
```

### 3. Install and Setup
```bash
# Install dependencies and setup database
mix setup

# Start the Phoenix server
OPENWEATHER_API_KEY=your_api_key_here mix phx.server

# Or with exported environment variable
export OPENWEATHER_API_KEY=your_api_key_here
mix phx.server
```

### 4. Access the Application
Visit [`localhost:4000`](http://localhost:4000) from your browser.

## Testing

```bash
# Run all tests
mix test

# Run specific test file
mix test test/clima/weather_service_test.exs
```

## Development

The application will not start without the required environment variable. You'll see a clear error message if it's missing.

## Learn more

* Official website: https://www.phoenixframework.org/
* Guides: https://hexdocs.pm/phoenix/overview.html
* Docs: https://hexdocs.pm/phoenix
* Forum: https://elixirforum.com/c/phoenix-forum
* Source: https://github.com/phoenixframework/phoenix
