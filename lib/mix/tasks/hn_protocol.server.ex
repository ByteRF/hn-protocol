defmodule Mix.Tasks.HnProtocol.Server do
  use Mix.Task

  # Borrowed from Phoenix
  # https://github.com/phoenixframework/phoenix/blob/master/lib/mix/tasks/phoenix.server.ex

  def run(_) do
    Application.put_env(:hn_protocol, :server, true)
    Mix.Task.run "run", run_args
  end


  defp run_args do
    if iex_running?, do: [], else: ["--no-halt"]
  end


  defp iex_running? do
    Code.ensure_loaded?(IEx) && IEx.started?
  end
end
