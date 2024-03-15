defmodule App do
  def entry("/favicon.ico", _query, _header) do
  end

  def entry(path, query, _header) do
    headers = [{"Content-Type", "text/plain"}]
    IO.inspect(query)
    {path, headers}
  end
end
