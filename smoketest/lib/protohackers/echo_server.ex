defmodule Protohackers.EchoTcp do
  use GenServer

  @impl true
  def init(socket) do
    send(self(), :read_data)
    Process.flag(:trap_exit, true)
    {:ok, {socket}}
  end

  @impl true
  def handle_info(:read_data, {socket}) do
    case :gen_tcp.recv(socket, 0) do
      {:ok, data} ->
        :gen_tcp.send(socket, data)
        IO.puts("Echoing #{data}")
        send(self(), :read_data)
        {:noreply, {socket}}

      {:error, :closed} ->
        IO.puts("Client finished sending, closing socket")
        # Close only after EOF
        :gen_tcp.close(socket)
        {:stop, :normal, {socket}}

      {:error, reason} ->
        {:stop, reason, {socket}}
    end
  end
end
