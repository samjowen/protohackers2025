defmodule Primetime.IntegrationTest do
  use ExUnit.Case

  require Logger

  def start_receive(socket) do
    case :gen_tcp.recv(socket, 0) do
      {:ok, packet} ->
        IO.puts("Got packet.")
        ^packet = ~s({"method":"isPrime","number" :123})

      {:error, reason} ->
        Logger.debug(":error in recv: #{IO.inspect(reason)}")
        :gen_tcp.close(socket)
    end
  end

  test "it can connect on port 80" do
    {:ok, _socket} = :gen_tcp.connect(~c"localhost", 80, mode: :binary, active: false)
  end

  @tag timeout: 10
  test "it can recieve a json string that has the method isPrime" do
    {:ok, socket} = :gen_tcp.connect(~c"localhost", 80, mode: :binary, active: false)
    :gen_tcp.send(socket, ~s({"method":"isPrime","number" :123}))
    start_receive(socket)
  end
end
