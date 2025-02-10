defmodule Primetime.Net.IsPrime do
  @moduledoc false

  use GenServer

  @impl true
  def init(socket) do
    send(self(), :main_routine)
    {:ok, socket}
  end

  @impl true
  def handle_info(:main_routine, socket) do
    {:noreply, socket}
  end
end
