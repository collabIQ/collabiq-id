defmodule CollabiqIdTest do
  use ExUnit.Case
  doctest CollabiqId

  defstruct [:id, :name]

  test "validate integer id" do
    assert CollabiqId.validate_id(3) == {:ok, 3}
  end

  test "validate string id" do
    assert CollabiqId.validate_id("3") == {:ok, 3}
  end

  test "validate id with improper value" do
    assert CollabiqId.validate_id(:bad) == {:error, %{key: "id", code: "invalid"}}
  end

  test "validate valid base64 id" do
    assert CollabiqId.validate_base64_id("MQ") == {:ok, 1}
  end

  test "validate invalid base64 id" do
    assert CollabiqId.validate_base64_id("M") == {:error, %{key: "id", code: "invalid"}}
  end

  test "encode single id" do
    assert CollabiqId.base64_out("1") == "MQ"
  end

  test "ignore nil id out" do
    map = %{id: nil, name: "test user"}
    assert CollabiqId.base64_out(map) == %{id: nil, name: "test user"}
  end

  test "encode empty list" do
    assert CollabiqId.base64_out([]) == []
  end

  test "encode list of single ids" do
    assert CollabiqId.base64_out(["1", "2"]) == ["MQ", "Mg"]
  end

  test "encode id in map" do
    map = %{id: "1", name: "test user"}
    assert CollabiqId.base64_out(map) == %{id: "MQ", name: "test user"}
  end

  test "encode ids in list of maps" do
    list = [%{id: "1", name: "test user"}, %{id: "2", name: "test user"}]

    assert CollabiqId.base64_out(list) == [
             %{id: "MQ", name: "test user"},
             %{id: "Mg", name: "test user"}
           ]
  end

  test "encode id in struct" do
    struct = %CollabiqIdTest{id: "1", name: "test user"}
    assert CollabiqId.base64_out(struct) == %{id: "MQ", name: "test user"}
  end

  test "encode ids in a list of structs" do
    list = [
      %CollabiqIdTest{id: "1", name: "test user"},
      %CollabiqIdTest{id: "2", name: "test user"}
    ]

    assert CollabiqId.base64_out(list) == [
             %{id: "MQ", name: "test user"},
             %{id: "Mg", name: "test user"}
           ]
  end

  test "decode empty list" do
    assert CollabiqId.base64_in([]) == []
  end

  test "decode list of structs" do
    list = [%CollabiqIdTest{id: "MQ", name: "test user"}, %CollabiqIdTest{id: "Mg", name: "test user"}]
    assert CollabiqId.base64_in(list) == [%{id: 1, name: "test user"}, %{id: 2, name: "test user"}]
  end

  test "decode list of maps" do
    list = [%{id: "MQ", name: "test user"}, %{id: "Mg", name: "test user"}]
    assert CollabiqId.base64_in(list) == [%{id: 1, name: "test user"}, %{id: 2, name: "test user"}]
  end

  test "decode base64 id" do
    assert CollabiqId.base64_in("MQ") == {:ok, 1}
  end
end
