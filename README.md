# Producer
![Build Go](https://github.com/Polygens/producer/workflows/Build%20Go/badge.svg)

## How to run?

### Requirements

1. Make sure you have brew installed on your mac, linux or wsl if on Windows.
2. Install
   * make: `brew install make`
   * helm: `brew install helm`
   * kubectl: `brew install kubernetes-cli`
   * kaf
   * go: `brew install go`
   * docker
   * k9s

### Running

Either use `make run` from inside the folder to run locally or use `make helm` to run inside Kubernetes locally using k3s.
