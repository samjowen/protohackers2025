defmodule Primetime.PrimeServer do
  @moduledoc false
  use GenServer

  defstruct [:socket]

  @impl true
  def init(socket) do
    send(self(), :main_routine)
    {:ok, socket, {:continue, :handle_recieve}}
  end

  @impl true
  def handle_continue(:handle_recieve, state) do
    case :gen_tcp.recv(state, 0) do
      {:ok, _packet} ->
        :gen_tcp.send(state, ~s({"method":"isPrime","number" :123}))
        {:noreply, state, {:continue, :handle_recieve}}

      _ ->
        {:stop, state}
    end

    {:noreply, state, {:continue, :handle_recieve}}
  end
end
