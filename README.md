# Producer
![Build Go](https://github.com/Polygens/Producer/workflows/Build%20Go/badge.svg)

## Requirements

### k3d

brew install k3d
k3d create --enable-registry -n k3s --publish 8080:8080 --api-port 6550

sudo -- sh -c "echo 127.0.0.1 registry.local >> /etc/hosts"
