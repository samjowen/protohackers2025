defmodule Primetime.PrimeServer do
  @moduledoc false
  use GenServer

  defstruct [:socket]

  @impl true
  def init(%__MODULE__{} = initial_state) do
    send(self(), :main_routine)
    {:ok, initial_state, {:continue, :handle_recieve}}
  end

  @impl true
  def handle_continue(:handle_recieve, %__MODULE__{} = state) do
    case :gen_tcp.recv(state.socket, 0) do
      {:ok, _packet} ->
        :gen_tcp.send(state.socket, ~s({"method":"isPrime","prime":false}))
        {:noreply, state, {:continue, :handle_recieve}}

      _ ->
        {:stop, state}
    end

    {:noreply, state, {:continue, :handle_recieve}}
  end
end
