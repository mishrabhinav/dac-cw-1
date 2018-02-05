defmodule System7 do

  def main do
    IO.puts ["\tSystem at ", DNS.my_ip_addr()]

    max_broadcasts = 1000
    timeout = 3000
    kill_timeout = 5
    num_peers = 5
    pl_reliability = 100

    peers =
      case System.get_env("DOCKER") || "false" do
        "true" ->
          for i <- 1..num_peers, do:
           { i,
             Node.spawn(:"peer#{i}@peer#{i}.localdomain",
                        Peer,
                        :start,
                        [i, self(), pl_reliability, kill_timeout])
           }
        "false" ->
          for i <- 1..num_peers, do:
            { i,
              spawn(Peer, :start, [i, self(), pl_reliability, kill_timeout])
            }
      end

    peer_metadata =
      for _ <- 1..num_peers do
        receive do
          { :response, id, lpl, beb, app, erb } ->
            { id, lpl, beb, app, erb }
        end
      end

    for { _, peer } <- peers, do:
      send peer, { :bind, peer_metadata }

    for { _, lpl, _, _, _ } <- peer_metadata, do:
      send lpl, { :pl_send, max_broadcasts, timeout }

  end # main

end
