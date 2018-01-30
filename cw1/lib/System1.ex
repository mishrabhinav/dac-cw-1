# Matthew Brookes (mb5715) and Abhinav Mishra (am8315)
defmodule System1 do
  def main do
    peers = for _ <- 1..5, do: spawn(Peer, :start, [])
    max_broadcasts = 1000
    timeout = 3000
    for peer <- peers, do:
      send peer, {:broadcast, max_broadcasts, timeout}
    # Send message to first peer
    send Enum.at(peers, 0), {:broadcast, 1000, 3000}
  end
end
