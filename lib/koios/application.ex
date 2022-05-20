defmodule Koios.Application do
  use Application

  @impl true
  def start(_type, _args) do
    Koios.Supervisor.start_link(name: Koios.Supervisor)
  end
end
