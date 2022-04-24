defmodule SetTest do
  use ExUnit.Case, async: true
  doctest Koios.Set

  setup do
    {:ok, found_item_set} = Koios.Set.start_link([])
    %{found_item_set: found_item_set}
  end

  test "has? returns false for unknown item", %{found_item_set: found_item_set} do
    assert !Koios.Set.has?(found_item_set, "http://www.example.com")
  end

  test "has? returns true for known item", %{found_item_set: found_item_set} do
    Koios.Set.put(found_item_set, "http://www.example.com")
    assert Koios.Set.has?(found_item_set, "http://www.example.com")
  end

  test "size returns 0 for empty set", %{found_item_set: found_item_set} do
    assert Koios.Set.size(found_item_set) == 0
  end

  test "size returns 1 for set with one item", %{found_item_set: found_item_set} do
    Koios.Set.put(found_item_set, "http://www.example.com")
    assert Koios.Set.size(found_item_set) == 1
  end

  test "size returns 2 for set with two items", %{found_item_set: found_item_set} do
    Koios.Set.put(found_item_set, "http://www.example.com")
    Koios.Set.put(found_item_set, "http://www.example2.com")
    assert Koios.Set.size(found_item_set) == 2
  end

  test "adding the same item multiple times does not increase the size", %{found_item_set: found_item_set} do
    Koios.Set.put(found_item_set, "http://www.example.com")
    Koios.Set.put(found_item_set, "http://www.example.com")
    assert Koios.Set.size(found_item_set) == 1
  end
end
