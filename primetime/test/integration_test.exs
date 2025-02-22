defmodule Primetime.IntegrationTest do
  use ExUnit.Case

  require Logger

  test "it can connect on port 80" do
    {:ok, _socket} = :gen_tcp.connect(~c"localhost", 8080, mode: :binary, active: false)
  end

  @tag timeout: 100
  test "receive a malformed request, send back a single malformed response, and disconnect the client" do
    {:ok, socket} = :gen_tcp.connect(~c"localhost", 8080, mode: :binary, active: false)
    # Malformed json terminated by newline
    :gen_tcp.send(socket, ~s({"method":"isPrime","number"::123}#{<<10>>}))

    case :gen_tcp.recv(socket, 0) do
      {:ok, packet} ->
        # Asserting that the pakcket we get back is indeed malformed
        ^packet = ~s({"method":"isPrime","number"::123}#{<<10>>})

      _ ->
        nil
    end

    # Socket should already be closed and return {:error, reason}
    assert {:error, :closed} == :gen_tcp.recv(socket, 0)
  end

  @tag timeout: 100
  test "it sends back correct response for valid request" do
    valid_json = ~s({"method":"isPrime","number":123}#{<<10>>})
    {:ok, socket} = :gen_tcp.connect(~c"localhost", 8080, mode: :binary, active: false)
    :gen_tcp.send(socket, valid_json)

    case :gen_tcp.recv(socket, 0) do
      {:ok, packet} ->
        # Asserting that the pakcket we get back is correct
        assert packet == ~s({"method":"isPrime","prime":false}#{<<10>>})

      _ ->
        nil
    end
  end

  @tag timeout: 200
  test "it correctly processes a buffer with a non-fully received message" do
    {:ok, socket} = :gen_tcp.connect(~c"localhost", 8080, mode: :binary, active: false)

    # First part of the message (incomplete)
    first_chunk = ~s({"method":"isPrime","number":2400896}#{<<10>>}{"number":84727494,"me)
    :gen_tcp.send(socket, first_chunk)

    case :gen_tcp.recv(socket, 0) do
      {:ok, packet} ->
        # Asserting that the pakcket we get back is correct
        assert packet == ~s({"method":"isPrime","prime":false}#{<<10>>})

      _ ->
        nil
    end

    # Simulate network delay before sending the rest of the message
    Process.sleep(50)

    # Second part of the message (completing the JSON)
    second_chunk = ~s(thod":"isPrime"}#{<<10>>})
    :gen_tcp.send(socket, second_chunk)

    case :gen_tcp.recv(socket, 0) do
      {:ok, packet} ->
        # Asserting that the pakcket we get back is correct
        assert packet == ~s({"method":"isPrime","prime":false}#{<<10>>})

      _ ->
        nil
    end
  end

  defp assert_receive_response(socket, expected_number, expected_prime) do
    case :gen_tcp.recv(socket, 0) do
      {:ok, packet} ->
        response = Jason.decode!(packet)
        assert response["number"] == expected_number
        assert response["prime"] == expected_prime

      {:error, reason} ->
        flunk("Failed to receive expected response: #{inspect(reason)}")
    end
  end
end
