defmodule App do

  def entry("/favicon.ico", _header) do end
  def entry(request, _header) do
    headers = [{"Content-Type","text/plain"}]
    {request, headers} 
  end
end
