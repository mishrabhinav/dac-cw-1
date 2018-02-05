# Distributed Algorithms Coursework 1
## Authors
* Matthew Brookes (mb5715)
* Abhinav Mishra (am8315)

## Summary of each System
| System number | Summary |
|:-------------:|:--------|
| 1             | Each Peer broadcasts a `:hello` message to each other until `MAX_BROADCASTS` are sent or `TIMEOUT` is reached whilst awaiting a message |
| 2             | Peers use Perfect P2P Links for communication |
| 3             | Peers use Best Effort Broadcast for communication |
| 4             | P2P Links drop messages at an `LPL_DROP_RATE` |
| 5             | Peer 3 terminates after `KILL_TIMEOUT` milliseconds |
| 6             | Peers use Eager Reliable Broadcast for communication |
| 7             | Peers use Lazy Reliable Broadcast for communication, checking for dead processes after `FAILURE_TIMEOUT` milliseconds |

## Running each System locally through Docker
The simplest way to run a system on a machine with `Docker` and `docker-compose` installed is to use the `start.sh` script. Invoking the script and specifying a `SYSTEM_NO` will launch that system with five peers and destroy the containers when stopped.
```
SYSTEM_NO=7 ./start.sh
```
Additionally configuration parameters can be passed in as environment variables (see later section for more details).
```
SYSTEM_NO=7 MAX_BROADCASTS=3000 KILL_TIMEOUT=100 ./start.sh
```

## Running each System locally through `mix`
From the root directory of each System use the following `mix run` command replacing `SystemX.main` with the System number e.g. `System7.main`.
```
mix run --no-halt -e SystemX.main
```
Additionally configuration parameters can be passed in as environment variables (see later section for more details).
```
MAX_BROADCASTS=3000 KILL_TIMEOUT=100 mix run --no-halt -e SystemX.main
```

## Specifying configuration options
Each system has a number of configurable options which are overriden using environment variables. The environment variables in the user shell are also passed into the container by `docker-compose` or can be specified with the `docker run -e` syntax.

The following table shows which options are available and in which System they can be used.

| Configuration Option | Available in Systems |
|:--------------------:|:--------------------:|
| MAX_BROADCASTS       | 1,2,3,4,5,6,7        |
| TIMEOUT              | 1,2,3,4,5,6,7        |
| LPL_DROP_RATE        | 4,5,6,7              |
| KILL_TIMEOUT         | 5,6,7                |
| FAILURE_TIMEOUT      | 7                    |
