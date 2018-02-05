# Matthew Brookes (mb5715) and Abhinav Mishra (am8315)

defmodule System7 do

  def main do
    init :local, []
  end # main

  def main_docker do
    init :docker, []
  end # main_docker

  def main_net do
    domains =
      File.stream!("/etc/ips.txt")
      |> Stream.map(&String.trim_trailing/1)
      |> Enum.to_list

    init :net, domains
  end # main_net

  defp init env, domains do
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
    failure_timeout = if System.get_env("FAILURE_TIMEOUT") do
                       String.to_integer(System.get_env("FAILURE_TIMEOUT"))
                     else
                       1000
                     end
    num_peers = 5

    peers = for i <- 1..num_peers do
      case env do
        :net    -> { i, Node.spawn(:"peer7@#{Enum.at(domains, i - 1)}", Peer, :start, [i, self(), pl_reliability, kill_timeout, failure_timeout])}
        :docker -> { i, Node.spawn(:"peer#{i}@peer#{i}.localdomain", Peer, :start, [i, self(), pl_reliability, kill_timeout, failure_timeout])}
        :local  -> { i, spawn(Peer, :start, [i, self(), pl_reliability, kill_timeout, failure_timeout])}
      end
    end

    peer_metadata =
      for _ <- 1..num_peers do
        receive do
          { :response, id, lpl, beb, app, lrb, fd_lpl } ->
            { id, lpl, beb, app, lrb, fd_lpl }
        end
      end

    for { _, peer } <- peers, do:
      send peer, { :bind, peer_metadata }

    for { _, lpl, _, _, _, _ } <- peer_metadata, do:
      send lpl, { :pl_send, max_broadcasts, timeout }

  end # main

end
