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
| 4             | P2P Links drop messages at an `LPL_RELIABILITY` |
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

## Running each System on a cluster of nodes

### Setup
Prerequisites:
- Digital Ocean Account
- Terraform

A terrform configuration file has been supplied to setup the Peers and the System on a bunch of Digital Ocean droplets. Before running the terraform config, create a file (`terraform.tfvars`) with the following content.

```
digitalocean_token = "<Digital Ocean API Key>"
fingerprint        = "<Fingerprint of the SSH Key added to Digital Ocean>"
private_key_file   = "<Location of the private key file>"
```

You can get the Digital Ocean API key from their portal. Please make sure that you have access to the private key file as it will be required to SSH into the `system` node to run the elixir proccessess. You might have to change the scripts to point to the private key file. For minimal changes, name the private key file `digital_rsa` and place it in the `~/.ssh` directory. After the configuration file is ready, do the following:

```
> cd Terraform
> terraform validate # This validates the terraform config
> terraform plan     # Shows you a plan of the deployment
> terraform apply    # Runs terraform to create the necessary resources
```

Now you should be in a state to start the Peers for System X on the peer nodes. Run the following in the `Terraform` directory.

```
> ./run peers.txt system.txt ../<SystemX> # X = 1..7
```
*Note:* You will have to start all the peers separately by running the command for all the Systems.

This will SSH into every peer node, check the requirements, and start an elixir node in detached mode with `peer<X>@<ipv4_address>` as the name and `darthvader` as the cookie. It also checks the system node for the requirements. After the script finished, once can SSH into the system node and navigate to `dac-cw-1/System<X>` and run the following command to start the SystemX (X = 1..7).
```
> elixir --name system@<ipv4_address> --cookie darthvader -S mix run --no-halt -e System<X>.main_net
```
This should automatically connect to the peer nodes and run the system. The system ip can be found in `system.txt` and the peer ip's can be found in `peers.txt`. A lot of log (`.txt`) files are also generated for debugging purposes.

### Cleanup
Execute the following commands for a proper cleanup and destruction of the resources.
```
> cd Terraform
> rm *.txt
> terraform destroy
```

At this point, all the Digital Ocean resources should have been destroyed but it's safer to double check on the dashboard.

*NOTE:* It is pretty important to remove the `txt` files as the deployments heavily depend on them and in case one forgets to remove them, it can the leave the future deployments in an inconsistent state.

### Detailed Provisioning
It is a pretty straightforward setup. The terraform config creates 5 peer nodes and 1 system node by default. These number can be changed manually for creating a different number of nodes. All the peer nodes are created before the system node as the system node has to save the IP addresses of the peer nodes. After the peer droplet (node) is created, a series of scripts are run to setup elixir, clone the source code, and save the IPv4 address both locally and on the node. The system node is setup is a similar fashion except a file with all the peer ipv4 addresses is copied to `/etc/ips.txt` for the `System` process to read peer IP's.

## Specifying configuration options
Each system has a number of configurable options which are overriden using environment variables. The environment variables in the user shell are also passed into the container by `docker-compose` or can be specified with the `docker run -e` syntax.

The following table shows which options are available and in which System they can be used.

| Configuration Option | Available in Systems |
|:--------------------:|:--------------------:|
| MAX_BROADCASTS       | 1,2,3,4,5,6,7        |
| TIMEOUT              | 1,2,3,4,5,6,7        |
| LPL_RELIABILITY      | 4,5,6,7              |
| KILL_TIMEOUT         | 5,6,7                |
| FAILURE_TIMEOUT      | 7                    |
