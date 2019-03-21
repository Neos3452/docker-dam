# Docker Dam - simple firewall manager for docker

It will close the docker containers' ports to the outside world.

## Installation

```bash
sudo -- bash -c 'curl -sL https://raw.githubusercontent.com/Neos3452/docker-dam/master/docker-dam.sh > /usr/bin/damdocker && chmod +x /usr/bin/damdocker && damdocker --install'
```

You now have `damdocker` command available. Access is blocked and Docker Dam will run on startup.

## Usage

See `damdocker --help`. Docker Dam requires root priviliges so sudo your way out of it.

Cookbook:
- `sudo damdocker --open` - open all docker ports
- `sudo damdocker --close` - shutdown outside access to containers
- `sudo damdocker --uninstall` - stop Docker Dam from running on startup
- `sudo damdocker --install` - restore start on boot

