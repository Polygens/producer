export FIRSTRUN := $(shell [ -f ".git/hooks/commit-msg" ] && echo "true" || echo "false")
export VERSION := $(shell git describe --tags --abbrev=0 &> /dev/null):$(shell git rev-parse --abbrev-ref HEAD &> /dev/null)
export OUTPUT := $(shell echo $$HOME/go/bin/producer)

setup:
ifeq ($(FIRSTRUN), false)
	brew install k3d
	k3d create --enable-registry -n k3s --publish 8080:8080 --api-port 6550
	# sudo -- sh -c "echo 127.0.0.1 registry.local >> /etc/hosts"
	# Setup kubectl
	go mod download
	echo "#!/bin/bash\n\n. .github/commit.sh\nticket_prefix \$$1 \$$2" > .git/hooks/prepare-commit-msg
	echo "#!/bin/bash\n\n. .github/commit.sh\nconventional_commit_validator \$$1" > .git/hooks/commit-msg
endif

build:
	CGO_ENABLED=0 go build -ldflags="-w -s -X main.version=$$VERSION" -o $$OUTPUT

docker-build:
	docker build -t producer -t registry.local:5000/producer:latest -t docker.pkg.github.com/polygens/producer/producer:latest --build-arg VERSION=$$VERSION .

run: setup build
	producer 

helm: setup docker-build
	k3d start -n k3s
	kubectl config use-context k3s
	docker push registry.local:5000/producer:latest
	helm upgrade -i producer ./charts --set image.repository=registry.local:5000/producer --set image.pullPolicy=Always --wait --set ingress.enabled=true
	kubectl logs -l app.kubernetes.io/name=producer -f
