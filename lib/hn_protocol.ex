defmodule HnProtocol do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # Define workers and child supervisors to be supervised
      # worker(HnProtocol.Worker, [arg1, arg2, arg3]),
    ]

    if Application.get_env(:hn_protocol, :server) do
      port = 9000
      IO.puts "Starting server on port #{port}"
      start_ranch port
    end

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: HnProtocol.Supervisor]
    Supervisor.start_link(children, opts)
  end


  def start_ranch(port) do
    protocol_opts = []
    transport_opts = [port: port]
    number_of_acceptors = 100
    {:ok, _} = :ranch.start_listener(
      :hn_protocol,
      number_of_acceptors,
      :ranch_tcp,
      transport_opts,
      HnProtocol.ProtocolServer,
      protocol_opts
    )
  end
end
