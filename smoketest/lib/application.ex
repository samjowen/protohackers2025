defmodule Protohackers.Application do
  use Application

  def start(_start_type, _start_args) do
    children = [
      {Protohackers.TcpListener, []}
    ]

    opts = [strategy: :one_for_one, name: Protohackers.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
