defmodule Primetime.TcpListener do
  @moduledoc false
  use GenServer

  defstruct [:listen_socket]

  @port 80

  def start_link(:no_state = arg) when is_atom(arg) do
    GenServer.start_link(__MODULE__, arg)
  end

  @impl true
  def init(:no_state) do
    {:ok, listen_socket} =
      :gen_tcp.listen(
        @port,
        [:binary, active: false, reuseaddr: true]
      )

    state = %__MODULE__{listen_socket: listen_socket}
    IO.puts("Listening for TCP connections on port #{@port}...")
    {:ok, state, {:continue, :accept_routine}}
  end

  @impl true
  def handle_continue(:accept_routine, %__MODULE__{} = state) do
    case :gen_tcp.accept(state.listen_socket) do
      {:ok, socket} ->
        GenServer.start(Primetime.IsPrime, socket)
        {:noreply, state, {:continue, :accept_routine}}

      {:error, reason} ->
        IO.puts("Error accepting connection:  #{reason}")
        # Just keep going and try again
        {:noreply, state, {:continue, :accept_routine}}
    end
  end
end
