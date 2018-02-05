variable "digitalocean_token" {}
variable "fingerprint" {}
variable "private_key_file" {}

provider "digitalocean" {
  token = "${var.digitalocean_token}"
}

resource "digitalocean_droplet" "peers" {
  count  = 5
  image  = "ubuntu-16-04-x64"
  name   = "peer${count.index}"
  region = "lon1"
  size   = "1gb"

  ssh_keys = [
    "${var.fingerprint}"
  ]

  connection {
    user        = "root"
    type        = "ssh"
    private_key = "${file("${var.private_key_file}")}"
    timeout     = "1m"
  }

  provisioner "remote-exec" {
    inline = [
      "wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb && sudo dpkg -i erlang-solutions_1.0_all.deb",
      "sudo apt-get -qq -y update",
      "sudo apt-get -qq install -y esl-erlang",
      "sudo apt-get -qq install -y elixir"
    ]
    on_failure = "continue"
  }

  provisioner "remote-exec" {
    inline = [
      "git clone https://github.com/mishrabhinav/dac-cw-1.git",
    ]
    on_failure = "continue"
  }

  provisioner "local-exec" {
    command = "echo ${self.ipv4_address} >> peers.txt"
  }
}

resource "digitalocean_droplet" "system" {
  image  = "ubuntu-16-04-x64"
  name   = "system"
  region = "lon1"
  size   = "1gb"

  ssh_keys = [
    "${var.fingerprint}"
  ]

  connection {
    user        = "root"
    type        = "ssh"
    private_key = "${file("${var.private_key_file}")}"
    timeout     = "1m"
  }

  depends_on = ["digitalocean_droplet.peers"]

  provisioner "remote-exec" {
    inline = [
      "wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb && sudo dpkg -i erlang-solutions_1.0_all.deb",
      "sudo apt-get -qq -y update",
      "sudo apt-get -qq install -y esl-erlang",
      "sudo apt-get -qq install -y elixir"
    ]
    on_failure = "continue"
  }

  provisioner "remote-exec" {
    inline = [
      "git clone https://github.com/mishrabhinav/dac-cw-1.git",
    ]
    on_failure = "continue"
  }

  provisioner "file" {
    source      = "peers.txt"
    destination = "/etc/ips.txt"
  }

  provisioner "local-exec" {
    command = "echo ${self.ipv4_address} >> system.txt"
  }
}
