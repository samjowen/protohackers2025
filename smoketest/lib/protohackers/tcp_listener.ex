defmodule Protohackers.TcpListener do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, name: :tcp_listener)
  end

  @impl true
  def init(_) do
    Process.flag(:trap_exit, true)

    {:ok, socket} =
      :gen_tcp.listen(
        80,
        [:binary, packet: :line, active: false, reuseaddr: true]
      )

    IO.puts("Listening on port 80")
    send(self(), :accept_loop)
    {:ok, socket}
  end

  @impl true
  def handle_info(:accept_loop, socket) do
    case :gen_tcp.accept(socket) do
      {:ok, client_socket} ->
        IO.puts("Accepted connection...")
        {:ok, _pid} = GenServer.start(Protohackers.EchoTcp, client_socket)
        send(self(), :accept_loop)
        {:noreply, socket}

      {:error, _reason} ->
        send(self(), :accept_loop)
        {:noreply, socket}
    end
  end
end
