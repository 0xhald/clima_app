defmodule Clima.Favorites do
  @moduledoc """
  Context for managing favorite cities with dual-mode support.

  Supports both authenticated users (database storage) and anonymous users (session storage).
  """

  import Ecto.Query, warn: false
  alias Clima.Repo
  alias Clima.FavoriteCity
  alias Clima.Accounts.User

  # Public API - works for both authenticated and anonymous users

  @doc """
  Returns the list of favorite cities for authenticated users or session data for anonymous users.
  """
  def list_favorite_cities(user_or_session) do
    case user_or_session do
      %User{} = user -> list_user_favorites(user)
      session when is_map(session) -> get_session_favorites(session)
    end
  end

  @doc """
  Creates a favorite city for authenticated users or adds to session for anonymous users.
  Returns {:ok, updated_favorites_list} for consistency.
  """
  def create_favorite_city(attrs, user_or_session) do
    case user_or_session do
      %User{} = user ->
        case create_user_favorite(attrs, user) do
          {:ok, _created} -> {:ok, list_user_favorites(user)}
          {:error, reason} -> {:error, reason}
        end

      session when is_map(session) ->
        add_to_session_favorites(session, attrs)
    end
  end

  @doc """
  Deletes a favorite city for authenticated users or removes from session for anonymous users.
  Returns {:ok, updated_favorites_list} for consistency.
  """
  def delete_favorite_city(city_or_id, user_or_session) do
    case user_or_session do
      %User{} = user ->
        case delete_user_favorite(city_or_id, user) do
          {:ok, _deleted} -> {:ok, list_user_favorites(user)}
          {:error, reason} -> {:error, reason}
        end

      session when is_map(session) ->
        remove_from_session_favorites(session, city_or_id)
    end
  end

  @doc """
  Check if city is already favorited by coordinates.
  """
  def city_favorited?(lat, lon, user_or_session) do
    case user_or_session do
      %User{} = user -> user_city_favorited?(lat, lon, user)
      session when is_map(session) -> session_city_favorited?(lat, lon, session)
    end
  end

  # Authenticated user functions (database operations)

  defp list_user_favorites(%User{id: user_id}) do
    Repo.all(from f in FavoriteCity, where: f.user_id == ^user_id, order_by: f.name)
  end

  defp create_user_favorite(attrs, %User{id: user_id}) do
    attrs_with_user = Map.put(attrs, :user_id, user_id)

    %FavoriteCity{}
    |> FavoriteCity.changeset(attrs_with_user)
    |> Repo.insert()
  end

  defp delete_user_favorite(%FavoriteCity{} = favorite_city, _user) do
    Repo.delete(favorite_city)
  end

  defp delete_user_favorite(city_id, %User{id: user_id})
       when is_binary(city_id) or is_integer(city_id) do
    case Repo.get_by(FavoriteCity, id: city_id, user_id: user_id) do
      nil -> {:error, :not_found}
      city -> Repo.delete(city)
    end
  end

  defp user_city_favorited?(lat, lon, %User{id: user_id}) do
    query =
      from f in FavoriteCity,
        where: f.lat == ^lat and f.lon == ^lon and f.user_id == ^user_id

    Repo.exists?(query)
  end

  # Anonymous user functions (session operations)

  defp get_session_favorites(session) do
    session
    |> Map.get("favorite_cities", [])
    |> Enum.map(&convert_session_to_struct/1)
  end

  defp add_to_session_favorites(session, attrs) do
    current_favorites = get_session_favorites(session)

    # Check if city already exists (by coordinates)
    lat = attrs[:lat] || attrs["lat"]
    lon = attrs[:lon] || attrs["lon"]

    if session_city_favorited?(lat, lon, session) do
      {:error, :already_exists}
    else
      session_city = convert_attrs_to_session(attrs)
      updated_favorites = [session_city | current_favorites]
      {:ok, updated_favorites}
    end
  end

  defp remove_from_session_favorites(session, city_identifier) do
    current_favorites = get_session_favorites(session)

    updated_favorites =
      case city_identifier do
        %FavoriteCity{lat: lat, lon: lon} ->
          Enum.reject(current_favorites, fn city ->
            city.lat == lat && city.lon == lon
          end)

        id when is_binary(id) ->
          case parse_session_id(id) do
            {lat, lon} ->
              Enum.reject(current_favorites, fn city ->
                city.lat == lat && city.lon == lon
              end)

            nil ->
              current_favorites
          end

        _ ->
          current_favorites
      end

    {:ok, updated_favorites}
  end

  defp session_city_favorited?(lat, lon, session) do
    session
    |> get_session_favorites()
    |> Enum.any?(fn city -> city.lat == lat && city.lon == lon end)
  end

  # Helper functions for session data conversion

  defp convert_session_to_struct(session_data) when is_map(session_data) do
    %FavoriteCity{
      id: generate_session_id(session_data["lat"], session_data["lon"]),
      name: session_data["name"],
      country: session_data["country"],
      state: session_data["state"],
      lat: session_data["lat"],
      lon: session_data["lon"],
      openweather_id: session_data["openweather_id"],
      user_id: nil
    }
  end

  defp convert_attrs_to_session(attrs) do
    %{
      "name" => attrs[:name] || attrs["name"],
      "country" => attrs[:country] || attrs["country"],
      "state" => attrs[:state] || attrs["state"],
      "lat" => attrs[:lat] || attrs["lat"],
      "lon" => attrs[:lon] || attrs["lon"],
      "openweather_id" => attrs[:openweather_id] || attrs["openweather_id"]
    }
  end

  defp generate_session_id(lat, lon) do
    "session_#{Float.round(lat, 4)}_#{Float.round(lon, 4)}"
  end

  defp parse_session_id("session_" <> coords) do
    case String.split(coords, "_") do
      [lat_str, lon_str] ->
        case {Float.parse(lat_str), Float.parse(lon_str)} do
          {{lat, ""}, {lon, ""}} -> {lat, lon}
          _ -> nil
        end

      _ ->
        nil
    end
  end

  defp parse_session_id(_), do: nil

  # Legacy functions for backward compatibility (authenticated users only)

  @doc """
  Returns the list of all favorite cities (legacy function for tests).
  """
  def list_favorite_cities do
    Repo.all(from f in FavoriteCity, order_by: f.name)
  end

  @doc """
  Gets a single favorite city by ID (authenticated users only).
  """
  def get_favorite_city!(id), do: Repo.get!(FavoriteCity, id)

  @doc """
  Creates a favorite city (legacy function - requires user_id in attrs).
  """
  def create_favorite_city(attrs) do
    %FavoriteCity{}
    |> FavoriteCity.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Deletes a favorite city (legacy function).
  """
  def delete_favorite_city(%FavoriteCity{} = favorite_city) do
    Repo.delete(favorite_city)
  end

  @doc """
  Check if city is already favorited by coordinates (legacy - checks all users).
  """
  def city_favorited?(lat, lon) do
    query = from f in FavoriteCity, where: f.lat == ^lat and f.lon == ^lon
    Repo.exists?(query)
  end
end
