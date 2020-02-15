defmodule CollabiqId do
  @default_in_keys [
    :id,
    :proxy_id,
    :site_id
  ]

  defp in_keys() do
    Application.get_env(:collabiq_id, :in_keys) || @default_in_keys
  end

  def base64_in([] = list), do: list

  def base64_in([_ | _] = list) do
    list
    |> Enum.map(&base64_in/1)
  end

  def base64_in(%_{} = struct) do
    struct
    |> Map.from_struct()
    |> base64_in()
  end

  def base64_in(%{} = map) do
    errors = base64_in_errors(map)

    case errors do
      [] ->
        base64_in_convert(map)

      _ ->
        {:error, errors}
    end
  end

  def base64_in(id) when is_binary(id) do
    with {:ok, id} <- Base.url_decode64(id, padding: false),
         {:ok, id} <- validate_id(id) do
      {:ok, id}
    else
      _ ->
        {:error, %{key: "id", code: "invalid"}}
    end
  end

  defp base64_in_errors(map) do
    Enum.flat_map(map, fn {key, value} ->
      with true <- key in in_keys(),
           {:error, error} <- validate_base64_id(value, key) do
        error
      else
        _ ->
          []
      end
    end)
  end

  defp base64_in_convert(map) do
    map =
      Enum.map(map, fn
        {key, value} ->
          if key in in_keys() do
            {:ok, id} = validate_base64_id(value, key)
            {key, id}
          else
            {key, value}
          end
      end)
      |> Enum.into(%{})

    {:ok, map}
  end

  @default_out_keys [
    :id,
    :proxy_id,
    :site_id
  ]

  defp out_keys() do
    Application.get_env(:collabiq_id, :out_keys) || @default_out_keys
  end

  def base64_out([] = list), do: list

  def base64_out([_ | _] = list) do
    list
    |> Enum.map(&base64_out/1)
  end

  def base64_out(%_{} = struct) do
    struct
    |> Map.from_struct()
    |> base64_out()
  end

  def base64_out(%{} = map) do
    map
    |> Enum.reduce(%{}, fn
      {key, value}, acc when not is_nil(value) ->
        if key in out_keys() do
          value = to_string(value)
          Map.put(acc, key, Base.url_encode64(value, padding: false))
        else
          Map.put(acc, key, value)
        end

      {key, value}, acc ->
        Map.put(acc, key, value)
    end)
  end

  def base64_out(id) when is_binary(id) do
    Base.url_encode64(id, padding: false)
  end

  def validate_base64_id(id, key \\ "id")
  def validate_base64_id(id, key) when is_nil(id), do: {:error, %{key: key, code: "invalid"}}

  def validate_base64_id(id, key) do
    with {:ok, id} <- Base.url_decode64(id, padding: false),
         {:ok, id} <- validate_id(id) do
      {:ok, id}
    else
      _ ->
        key = to_string(key)
        {:error, %{key: key, code: "invalid"}}
    end
  end

  def validate_id(id, key \\ "id")

  def validate_id(id, _key) when is_integer(id), do: {:ok, id}

  def validate_id(id, key) when is_binary(id) do
    try do
      String.to_integer(id)
    rescue
      _ ->
        {:error, %{key: key, code: "invalid"}}
    else
      id ->
        {:ok, id}
    end
  end

  def validate_id(_id, key), do: {:error, %{key: key, code: "invalid"}}
end
