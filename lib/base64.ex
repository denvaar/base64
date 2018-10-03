defmodule Base64 do
  @moduledoc """
  Encode and decode binary data with base64.
  """

  @base64_table "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
  @pad "="
  @source_chunk_size 3

  @doc """
  Encode binary data as ASCII text

  ## Examples

      iex> Base64.encode("M")
      "TQ=="

      iex> Base64.encode("Ma")
      "TWE="

      iex> Base64.encode("Man")
      "TWFu"

  """
  def encode(file_path) do
    {data, n_padding} = file_path
      |> read_file()
      |> read_data()
      |> ensure_size()

    data
    |> chunk_by(6)
    |> convert_to_ascii(n_padding)
  end

  defp convert_to_ascii(sixtets, n_padding) do
    result = sixtets
      |> Enum.map(&Base64.table_lookup/1)
      |> Enum.join("")

    result <> String.duplicate(@pad, n_padding)
  end

  defp table_lookup(<<sixtet_value::6>>), do: String.at(@base64_table, sixtet_value)

  defp chunk_by(data, n_chunk) do
    for << c::size(n_chunk) <- data >>, do: <<c::size(n_chunk)>>
  end

  defp ensure_size(data) do
    n_padding = rem(bit_size(data), @source_chunk_size)
    x = 6 - n_padding

    if n_padding == 0 do
      {data, n_padding}
    else
      {<< data::bits, <<0::size(x)>> >>, n_padding}
    end
  end

  defp read_file(path) do
    File.open(path)
  end

  defp read_data({:ok, file_handle}) do
    file_handle
    |> IO.binread(:all)
  end

  defp read_data({:error, _}) do
    ""
  end
end
