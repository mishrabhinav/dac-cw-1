# Matthew Brookes (mb5715) and Abhinav Mishra (am8315)
defmodule Peer do

  def start id, system, lpl_drop_rate, kill_timeout, failure_timeout do
    IO.puts ["\tPeer at ", DNS.my_ip_addr()]

    app    = spawn App, :start, [id]
    lpl    = spawn LPL, :start, [id, lpl_drop_rate]
    beb    = spawn BEB, :start, [id]
    lrb    = spawn LRB, :start, [id]
    fd     = spawn FD,  :start, []
    fd_lpl = spawn LPL, :start, [id, lpl_drop_rate]

    send system, { :response, id, lpl, beb, app, lrb, fd_lpl }

    receive do
      { :bind, peer_metadata } ->
        lpls = Enum.map(peer_metadata,
                        fn { id, lpl, _, _, _, _ } -> { id, lpl } end)
        fd_lpls = Enum.map(peer_metadata,
                        fn { id, _, _, _, _, fd_lpl } -> { id, fd_lpl } end)
        processes = Enum.map(peer_metadata,
                        fn { id, _, _, _, _, _ } -> id end)

        send lpl, { :bind, beb }
        send beb, { :bind, lpl, lrb, lpls }
        send lrb, { :bind, beb, app, processes }
        send fd,  { :bind, lrb, fd_lpl, fd_lpls, failure_timeout}
        send app, { :bind, lrb, length(peer_metadata) }
    end

    if id == 3, do:
      kill kill_timeout, app, lpl, beb, lrb
  end # start

  defp kill timeout, app, lpl, beb, lrb do
    Process.sleep(timeout)
    Process.exit(app, :kill)
    Process.exit(lrb, :kill)
    Process.exit(beb, :kill)
    Process.exit(lpl, :kill)
    Process.exit(self(), :kill)
  end

end # Peer
