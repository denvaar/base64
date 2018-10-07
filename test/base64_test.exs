defmodule Base64Test do
  use ExUnit.Case
  doctest Base64

  test "encodes binary data" do
    assert Base64.encode("hello") == "aGVsbG8="
    assert Base64.encode("any carnal pleasure.") == "YW55IGNhcm5hbCBwbGVhc3VyZS4="
    assert Base64.encode("any carnal pleasure") == "YW55IGNhcm5hbCBwbGVhc3VyZQ=="
    assert Base64.encode("any carnal pleasur") == "YW55IGNhcm5hbCBwbGVhc3Vy"
  end

  test "decodes binary data" do
    assert Base64.decode("aGVsbG8=") == "hello"
    assert Base64.decode("YW55IGNhcm5hbCBwbGVhc3VyZS4=") == "any carnal pleasure."
    assert Base64.decode("YW55IGNhcm5hbCBwbGVhc3VyZQ==") == "any carnal pleasure"
    assert Base64.decode("YW55IGNhcm5hbCBwbGVhc3Vy") == "any carnal pleasur"
  end
end
