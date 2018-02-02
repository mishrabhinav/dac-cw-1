defmodule System6 do

  def main do
    max_broadcasts = 1000
    timeout = 3000
    kill_timeout = 5
    num_peers = 5
    lpl_drop_rate = 33

    peers =
      case System.get_env("DOCKER") || "false" do
        "true" -> for i <- 1..num_peers, do: { i, Node.spawn(:"peer#{i}@peer#{i}.localdomain", Peer, :start, [i, self(), lpl_drop_rate, kill_timeout]) }
        "false" -> for i <- 1..num_peers, do: { i, spawn(Peer, :start, [i, self(), lpl_drop_rate, kill_timeout]) }
      end

    peer_bebs =
      for _ <- 1..num_peers do
        receive do
          { :response, id, lpl, beb, app } -> { id, lpl, beb, app }
        end
      end

    for { _, peer } <- peers, do:
      send peer, { :bind, peer_bebs }

    for { _, lpl, _, _ } <- peer_bebs, do:
      send lpl, { :pl_send, max_broadcasts, timeout }

  end # main

end
