defmodule Protohackers.TcpListener do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, name: :tcp_listener)
  end

  @impl true
  def init(_) do
    {:ok, socket} =
      :gen_tcp.listen(
        80,
        [:binary, packet: :line, active: :once, reuseaddr: true]
      )

    IO.puts("Listening on port 80")
    {:ok, socket}
  end
end
