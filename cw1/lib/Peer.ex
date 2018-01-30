# Matthew Brookes (mb5715) and Abhinav Mishra (am8315)
defmodule Peer do
    def start() do
      receive do
        { id, peers } -> next(id, peers)
      end
    end

    defp next(id, peers) do
      IO.puts(id)
    end
end
