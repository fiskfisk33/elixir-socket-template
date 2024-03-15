defmodule ESOCKET.Socket do
  @port 8085

  def main([port|_rest]) do
    {port,_} = Integer.parse(port)
    case :gen_tcp.listen(port,[:binary]) do
      {:ok, listenSocket} ->
        listen(listenSocket)
        :gen_tcp.close(listenSocket)

      error -> IO.inspect(error)
    end
  end
  
  defp listen(listenSocket) do
    case :gen_tcp.accept(listenSocket) do
      {:ok, socket} -> 
        client = spawn_link(fn -> client(socket) end)
        :gen_tcp.controlling_process(socket,client)
      error         -> IO.inspect(error)
    end
    listen(listenSocket)
  end

  defp client(socket) do
    header = recv(socket)
    msg =
    case parse_header(header) do
      :error -> sendcode(400) 
      {:ok, request, headers} ->
        #Here we call the rest of the program
        case App.entry(request, headers) do
          {""<>msg, headers} ->
            sendcode(200) <>
            List.foldl(headers,"",fn (a,acc) ->
              {h,a} = a
              "#{h}: #{a}\r\n#{acc}"
            end) <>
            "\r\n" <>
            msg
          _ -> sendcode(404)
            
        end
        
    end
    IO.inspect(msg)
    :gen_tcp.send(socket,msg)
    :gen_tcp.shutdown(socket, :write)
  end

  defp recv(socket) do
    recv(socket, "")
  end
  defp recv(socket, data) do
    cond do
      String.contains?(data, "\r\n\r\n") ->
        data
      true -> 
        data = data <> receive do
          {:tcp, ^socket, value} ->
            value
        end
        recv(socket,data)
    end 
  end 

  defp parse_header(header) do
    [request|headers] =
    String.trim(header, "\r\n") |>
    String.split("\r\n")
    case String.split(request) do
      ["GET", request, "HTTP/1.1"] -> 
        headers = Enum.map(headers, fn(a) -> 
          [k,v] = Regex.split(~r{: },a, parts: 2)
          {k,v}
          end)
        headers = Map.new(headers)
        {:ok, request, headers}
      _ -> :error
    end
  end
  
  defp sendcode(400) do 
    "HTTP/1.1 400 Bad Request\r\n\r\n"
  end
  defp sendcode(404) do
    "HTTP/1.1 404 Not Found\r\n\r\n"
  end
  defp sendcode(200) do
    "HTTP/1.1 200 OK\r\n"
  end

end
