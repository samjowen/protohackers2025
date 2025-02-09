defmodule Protohackers.EchoTcp do
  use GenServer

  @impl true
  def init(socket) do
    buffer = []
    send(self(), :read_data)
    Process.flag(:trap_exit, true)
    {:ok, {socket, buffer}}
  end

  @impl true
  def handle_info(:read_data, {socket, buffer}) do
    case :gen_tcp.recv(socket, 0) do
      {:ok, packet} ->
        IO.puts(packet)
        new_buffer = [packet | buffer]
        :gen_tcp.send(socket, buffer)
        send(self(), :read_data)
        {:noreply, {socket, new_buffer}}

      {:error, :closed} ->
        # If the client closed the connection, stop gracefully
        IO.puts("Client closed the connection.")
        {:stop, :normal, {socket, buffer}}

      {:error, reason} ->
        {:stop, reason, {socket, buffer}}
    end
  end
end
