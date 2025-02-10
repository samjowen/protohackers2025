defmodule Primetime.TcpListener do
  use GenServer

  @port 80

  @impl true
  def init(init = []) do
    {:ok, listen_socket} =
      :gen_tcp.listen(
        80,
        [:binary, active: false, reuseaddr: true]
      )
  end
end
