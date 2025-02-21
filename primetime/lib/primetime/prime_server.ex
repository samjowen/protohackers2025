defmodule Primetime.PrimeServer do
  @moduledoc false
  use GenServer

  import Primetime.JsonStream

  require Logger

  @message_delimiter <<10>>
  # Protohackers spec says we should send back a malformed json
  # if we get one from a client 🤷‍♀️
  @malformed_response_json ~s({"method":"isPrime","number"::123})
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
        {message, new_buffer} = extract_first(packet, delimiter: @message_delimiter)

        if is_json_valid?(message) do
          {:noreply, %{state | buffer: new_buffer}, {:continue, :handle_recieve}}
        else
          # Stop the GenServer after handling the malformed JSON
          handle_malformed_json(state.socket)
          {:stop, :normal, state}
        end

      _ ->
        {:stop, :normal, state}
    end
  end

  defp handle_malformed_json(socket) do
    Logger.info("Handling malfomed json...")
    # Send back our malformed json
    :ok = :gen_tcp.send(socket, @malformed_response_json)
    :ok = :gen_tcp.close(socket)
    :ok
  end
end
