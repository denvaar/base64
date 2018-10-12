defmodule Base64 do
  @moduledoc """
  Encode and decode binary data with base64.
  """

  @base64_table ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "+", "/"]
  @pad "="
  @source_chunk_size 3


  @doc """
  Decode a base64-encoded file back to original binary content
  """
  @spec decode_file(binary(), binary()) :: :ok | {:error, term()}
  def decode_file(input_path, output_path) do
    input_path
    |> read_file()
    |> decode()
    |> write_file(output_path)
  end

  @doc """
  Decode ASCII text back to binary data

  ## Examples

      iex> Base64.decode("TWFu")
      "Man"

      iex> Base64.decode("TWFuTQ==")
      "ManM"

      iex> Base64.decode("TQ==")
      "M"
  """
  @spec decode(binary()) :: binary()
  def decode(data) do
    graphemes = String.replace(data, ~r/[\t\n\r ]+/, "", global: true) |> String.graphemes
    n_bytes = calc_binary_size(graphemes)
    table = @base64_table
      |> Enum.with_index()
      |> Map.new()

    graphemes
    |> find_indicies(table)
    |> change_to_sixtets()
    |> extract_binary_data(n_bytes)
  end

  @spec extract_binary_data(bitstring(), arity()) :: bitstring()
  defp extract_binary_data(bits, n_bytes) do
    <<decoded_data::size(n_bytes)-binary-unit(8), _junk::bitstring>> = bits
    decoded_data
  end

  @spec change_to_sixtets(list()) :: bitstring()
  defp change_to_sixtets(indicies) do
    for x <- indicies, do: <<x::6>>, into: <<>>
  end

  @spec calc_binary_size(list()) :: arity()
  defp calc_binary_size(characters) do
    div(3 * length(characters), 4) - n_padding(characters)
  end

  @spec n_padding(list()) :: arity()
  defp n_padding(characters), do: (Enum.take(characters, -4) |> Enum.count(&(&1 == @pad)))

  @spec find_indicies(list(), list()) :: list()
  defp find_indicies(letters, table) do
    letters
    |> Enum.map(fn(char) -> Map.get(table, char) end)
    |> Enum.reject(&(!&1))
  end

  @doc """
  Encode binary file using base64
  """
  @spec encode_file(binary(), binary()) :: :ok | {:error, term()}
  def encode_file(input_path, output_path) do
    input_path
    |> read_file()
    |> encode()
    |> write_file(output_path)
  end

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
  @spec encode(binary()) :: binary()
  def encode(data) do
    {data, n_padding} = ensure_size(data)
    do_encode(data, n_padding)
  end

  @spec do_encode(binary(), non_neg_integer()) :: binary()
  defp do_encode(data, n_padding) do
    data
    |> chunk_by(6)
    |> convert_to_ascii(n_padding)
  end

  @spec convert_to_ascii([<<_::6>>], non_neg_integer()) :: binary()
  defp convert_to_ascii(sixtets, n_padding) do
    result = sixtets
      |> Enum.map(&table_lookup/1)
      |> Enum.join("")

    result <> String.duplicate(@pad, n_padding)
  end

  @spec table_lookup(<<_::6>>) :: binary() | nil
  defp table_lookup(<<sixtet_value::6>>), do: Enum.at(@base64_table, sixtet_value)

  @spec chunk_by(bitstring(), 6) :: [<<_::6>>]
  defp chunk_by(data, n_chunk) do
    for << c::size(n_chunk) <- data >>, do: <<c::size(n_chunk)>>
  end

  @spec ensure_size(bitstring()) :: {bitstring(), integer()}
  defp ensure_size(data) do
    n_padding = rem(bit_size(data), @source_chunk_size)
    x = 6 - n_padding

    if n_padding == 0 do
      {data, n_padding}
    else
      {<< data::bits, <<0::size(x)>> >>, n_padding}
    end
  end

  @spec write_file(binary(), binary()) :: :ok | {:error, atom()}
  defp write_file(data, path) do
    with {:ok, file_handle} <- File.open(path, [:write]) do
      file_handle
      |> IO.binwrite(data)
    end
  end

  @spec read_file(binary()) :: :eof | binary() | [byte()] | {:error, atom() | {:no_translation, :unicode, :latin1}}
  defp read_file(path) do
    with {:ok, file_handle} <- File.open(path) do
      file_handle
      |> IO.binread(:all)
    end
  end
end
