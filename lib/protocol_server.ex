defmodule HnProtocol.ProtocolServer do
  use GenServer
  @behaviour :ranch_protocol
  @timeout 100000
  @api_base_url "https://hacker-news.firebaseio.com/v0"


  def start_link(ref, socket, transport, options) do
    :proc_lib.start_link(__MODULE__, :init, [ref, socket, transport, options])
  end


  def init(ref, socket, transport, _options) do
    :ok = :proc_lib.init_ack {:ok, self}
    :ok = :ranch.accept_ack ref
    :ok = transport.setopts socket, [active: :once]

    state = %{socket: socket, transport: transport}
    :gen_server.enter_loop __MODULE__, [], state, @timeout
  end


  def handle_info({:tcp, socket, "quit\r\n"}, state=%{socket: socket, transport: transport}) do
    {:stop, :normal, state}
  end


  def handle_info({:tcp, socket, data}, state=%{socket: socket, transport: transport}) do
    :ok = transport.setopts socket, [active: :once]
    output = data
    |> String.split
    |> cmd

    case output do
      :quit ->
        {:stop, :normal, state}
      value ->
        :ok = transport.send socket, "#{value}\r\n"
        {:noreply, state, @timeout}
    end
  end

  def handle_info({:tcp_closed, _socket}, state) do
    {:stop, :normal, state}
  end

  def handle_info({:tcp_error, _, reason}, state) do
    {:stop, reason, state}
  end

  def handle_info(:timeout, state) do
    {:stop, :normal, state}
  end


  def cmd(["QUIT"]) do
    :quit
  end


  def cmd(["TOP"]) do
    {:ok, req} = HTTPoison.get("#{@api_base_url}/topstories.json")
    story_ids = Poison.decode!(req.body)
    |> Enum.take(10)
    |> Enum.join("\r\n")
  end


  def cmd(["ASK"]) do
    {:ok, req} = HTTPoison.get("#{@api_base_url}/askstories.json")
    story_ids = Poison.decode!(req.body)
    |> Enum.take(10)
    |> Enum.join("\r\n")
  end


  def cmd(["SHOW", story_id]) do
    {:ok, req} = HTTPoison.get("#{@api_base_url}/item/#{story_id}.json")
    story = Poison.decode!(req.body)
    "#{story["title"]}\r\n#{story["by"]}\r\n#{story["text"] || story["url"]}"
  end


  def cmd(_) do
    "INVALID"
  end
end