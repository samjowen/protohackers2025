defmodule Primetime.PrimeServer do
  @moduledoc false
  use GenServer

  import Primetime.IsPrime
  import Primetime.JsonStream

  require Logger

  @message_delimiter <<10>>
  # Protohackers spec says we should send back a malformed json
  # if we get one from a client \x{1F937}\x{200D}\x{2640}\x{FE0F}
  @malformed_response_json ~s({"method":"isPrime","number"::123}#{<<10>>})
  @is_prime_response_json ~s({"method":"isPrime","prime":true}#{<<10>>})
  @not_prime_response_json ~s({"method":"isPrime","prime":false}#{<<10>>})
  defstruct [:socket, :buffer]

  @impl true
  def init(%__MODULE__{} = initial_state) do
    send(self(), :main_routine)

    {:ok,
     %__MODULE__{
       socket: initial_state.socket,
       buffer: ""
     }, {:continue, :handle_recieve}}
  end

  @impl true
  def handle_continue(:handle_recieve, %__MODULE__{} = state) do
    case :gen_tcp.recv(state.socket, 0) do
      {:ok, packet} ->
        new_buffer = state.buffer <> packet

        if String.length(new_buffer) > 0 do
          Logger.info("Processing existing buffer: #{new_buffer}")
          processed_buffer = handle_existing_buffer(new_buffer, state.socket)
          {:noreply, %{state | buffer: processed_buffer}, {:continue, :handle_recieve}}
        else
          {:noreply, %{state | buffer: new_buffer}, {:continue, :handle_recieve}}
        end

      {:error, _reason} ->
        {:stop, :normal, state}
    end
  end

  defp handle_message(message, socket) do
    Logger.info("Handling message: #{message}")

    if is_json_valid?(message) do
      :ok = handle_valid_json(socket, message)
    else
      # Stop the GenServer after handling the malformed JSON
      handle_malformed_json(socket)
      {:stop, :normal}
    end
  end

  defp handle_malformed_json(socket) do
    Logger.info("Handling malfomed json...")
    # Send back our malformed json
    :ok = :gen_tcp.send(socket, @malformed_response_json)
    :ok = :gen_tcp.close(socket)
    :ok
  end

  defp handle_valid_json(socket, json) when is_binary(json) do
    {:ok, json} = decode_json(json)
    number_to_test = Map.get(json, "number")
    is_number_prime? = is_prime?(number_to_test)

    if is_number_prime? do
      :gen_tcp.send(socket, @is_prime_response_json)
    else
      :gen_tcp.send(socket, @not_prime_response_json)
    end

    :ok
  end

  defp handle_existing_buffer(buffer, socket) do
    {message, new_buffer} = extract_first(buffer, delimiter: @message_delimiter)
    handle_message(message, socket)
    new_buffer
  end
end
