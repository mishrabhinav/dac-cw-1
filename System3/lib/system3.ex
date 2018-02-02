defmodule System3 do

  def main do
    max_broadcasts = 1000
    timeout = 3000
    num_peers = 5

    peers = for i <- 1..num_peers, do: { i, spawn(Peer, :start, []) }

    for { id, peer } <- peers, do:
      send peer, {:request, id, self()}

    peer_metadata =
      for _ <- 1..num_peers do
        receive do
          { :response, id, pl } -> { id, pl }
        end
      end

    for { _, pl } <- peer_metadata, do:
      send pl, { :bind, peer_metadata }

    for { _, pl } <- peer_metadata, do:
      send pl, { :broadcast, max_broadcasts, timeout }

  end # main

end
