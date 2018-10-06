defmodule Base64Test do
  use ExUnit.Case
  doctest Base64

  test "encodes binary data" do
    assert Base64.encode("hello") == "aGVsbG8="
  end

  test "encodes and decodes back" do
    original = "Denver Paul Smith"
    encoded = "RGVudmVyIFBhdWwgU21pdGg="
    assert Base64.encode(original) == encoded
    assert Base64.decode(encoded) == original
  end
end
