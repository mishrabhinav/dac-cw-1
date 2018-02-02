defmodule System2 do

  def main do
    max_broadcasts = 1000
    timeout = 3000
    num_peers = 5

    peers = for i <- 1..num_peers, do: { i, spawn(Peer, :start, [i, self()]) }

    peer_pls =
      for _ <- 1..num_peers do
        receive do
          { :response, id, pl } -> { id, pl }
        end
      end

    for { id, peer } <- peers, do:
      send peer, { :bind, peer_pls }

    for { id, pl } <- peer_pls, do:
      send pl, { :pl_send, max_broadcasts, timeout }

  end # main

end
