defmodule Base64.Performance do
  import ExProf.Macro

  def decode_perf do
    {:ok, body} = File.read "lib/base64/cat.jpg.b64"
    profile do
      Base64.decode(body)
    end
  end
end
