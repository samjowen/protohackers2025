defmodule Primetime.IntegrationTest do
  use ExUnit.Case

  require Logger

  test "it can connect on port 80" do
    {:ok, _socket} = :gen_tcp.connect(~c"localhost", 80, mode: :binary, active: false)
  end

  @tag timeout: 100
  test "receive a malformed request, send back a single malformed response, and disconnect the client" do
    {:ok, socket} = :gen_tcp.connect(~c"localhost", 80, mode: :binary, active: false)
    # Malformed json terminated by newline
    :gen_tcp.send(socket, ~s({"method":"isPrime","number"::123}#{<<10>>}))

    case :gen_tcp.recv(socket, 0) do
      {:ok, packet} ->
        # Asserting that the pakcket we get back is indeed malformed
        ^packet = ~s({"method":"isPrime","number"::123})

      _ ->
        nil
    end

    # Socket should already be closed and return {:error, reason}
    assert {:error, :closed} == :gen_tcp.recv(socket, 0)
  end

  @tag timeout: 100
  test "it sends back correct response for valid request" do
    valid_json = ~s({"method":"isPrime","number":123}#{<<10>>})
    {:ok, socket} = :gen_tcp.connect(~c"localhost", 80, mode: :binary, active: false)
    :gen_tcp.send(socket, valid_json)

    case :gen_tcp.recv(socket, 0) do
      {:ok, packet} ->
        # Asserting that the pakcket we get back is correct
        assert packet == ~s({"method":"isPrime","prime":false})

      _ ->
        nil
    end
  end
end
