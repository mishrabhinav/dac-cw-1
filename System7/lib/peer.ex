# Matthew Brookes (mb5715) and Abhinav Mishra (am8315)
defmodule Peer do

  def start id, system, lpl_drop_rate, kill_timeout, failure_timeout do
    IO.puts ["\tPeer at ", DNS.my_ip_addr()]

    app    = spawn App, :start, [id]
    lpl    = spawn LPL, :start, [id, lpl_drop_rate]
    beb    = spawn BEB, :start, [id]
    erb    = spawn ERB, :start, [id]
    fd     = spawn FD,  :start, []
    fd_lpl = spawn LPL, :start, [id, lpl_drop_rate]

    send system, { :response, id, lpl, beb, app, erb, fd_lpl }

    receive do
      { :bind, peer_metadata } ->
        lpls = Enum.map(peer_metadata,
                        fn { id, lpl, _, _, _, _ } -> { id, lpl } end)
        fd_lpls = Enum.map(peer_metadata,
                        fn { id, _, _, _, _, fd_lpl } -> { id, fd_lpl } end)

        send lpl, { :bind, beb }
        send beb, { :bind, lpl, erb, lpls }
        send erb, { :bind, beb, app }
        send fd,  { :bind, erb, fd_lpl, fd_lpls, failure_timeout}
        send app, { :bind, erb, length(peer_metadata) }
    end

    if id == 3, do:
      kill kill_timeout, app, lpl, beb, erb
  end # start

  defp kill timeout, app, lpl, beb, erb do
    Process.sleep(timeout)
    Process.exit(app, :kill)
    Process.exit(erb, :kill)
    Process.exit(beb, :kill)
    Process.exit(lpl, :kill)
    Process.exit(self(), :kill)
  end

end # Peer
