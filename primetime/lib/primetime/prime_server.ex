defmodule Primetime.IsPrime do
  @moduledoc false

  use GenServer

  # Sent back to the client when we get a malformed JSON object
  @malformed_response "{'malformed: 'response'}"

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
