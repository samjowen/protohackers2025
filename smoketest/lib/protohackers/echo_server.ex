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
        new_buffer = [packet | buffer]
        :gen_tcp.send(socket, new_buffer)
        send(self(), :close_connection)

        {:noreply, {socket, new_buffer}}

      {:error, :closed} ->
        {:stop, :normal, {socket, buffer}}

      {:error, reason} ->
        {:stop, reason, {socket, buffer}}
    end

    @impl true
    def handle_info(:close_connection, {socket, buffer}) do
      :gen_tcp.close(socket)
      {:stop, :normal, {socket, buffer}}
    end
  end
end
