defmodule Base64Test do
  use ExUnit.Case
  doctest Base64

  test "encodes binary data" do
    assert Base64.encode("hello") == "aGVsbG8="
  end
end
