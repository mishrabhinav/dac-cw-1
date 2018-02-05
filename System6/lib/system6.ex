defmodule System6 do

  def main do
    IO.puts ["\tSystem at ", DNS.my_ip_addr()]

    max_broadcasts = if System.get_env("MAX_BROADCASTS") do
                       String.to_integer(System.get_env("MAX_BROADCASTS"))
                     else
                       1000
                     end
    timeout        = if System.get_env("TIMEOUT") do
                       String.to_integer(System.get_env("TIMEOUT"))
                     else
                       3000
                     end
    pl_reliability = if System.get_env("LPL_DROP_RATE") do
                       100 - String.to_integer(System.get_env("LPL_DROP_RATE"))
                     else
                       100
                     end
    kill_timeout   = if System.get_env("KILL_TIMEOUT") do
                       String.to_integer(System.get_env("KILL_TIMEOUT"))
                     else
                       5
                     end
    num_peers = 5

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
