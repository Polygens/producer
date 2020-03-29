export FIRSTRUN := $(shell [ -f ".git/hooks/commit-msg" ] && echo "true" || echo "false")
export VERSION := $(shell git describe --tags --abbrev=0 &> /dev/null):$(shell git rev-parse --abbrev-ref HEAD &> /dev/null)
export PROJECT := $(shell basename $(CURDIR))
export OUTPUT := $(shell echo $$HOME/go/bin/$(shell basename $(CURDIR)))

setup:
ifeq ($(FIRSTRUN), false)
	# install k3d/k3s
	brew install k3d
	# Create a k3s cluster, configure kubectl
	-k3d create --enable-registry -n k3s --publish 8080:8080 --api-port 6550 --wait 120 && k3d get-kubeconfig -n k3s && \
	KUBECONFIG=~/.config/k3d/k3s/kubeconfig.yaml:~/.kube/config kubectl config view --flatten > ~/.kube/temp && \
	mv ~/.kube/temp ~/.kube/config
	# Add bitname repo to helm repostiories if not yet added
	helm repo add bitnami https://charts.bitnami.com/bitnami
	# Install kafka and zookeeper if not yet installed in the cluster and configure kaf tool
	sleep 5
	-helm install kafka bitnami/kafka --set externalAccess.enabled=true,externalAccess.service.type=LoadBalancer,externalAccess.service.port=19092,externalAccess.autoDiscovery.enabled=true,serviceAccount.create=true,rbac.create=true && \
	kaf config add-cluster k3s -b k3s:19092
	# Confgure jira ticket and conventional commit hooks
	echo "#!/bin/bash\n\n. .github/commit.sh\nticket_prefix \$$1 \$$2" > .git/hooks/prepare-commit-msg
	echo "#!/bin/bash\n\n. .github/commit.sh\nconventional_commit_validator \$$1" > .git/hooks/commit-msg
	# Setup hosts
	@echo "\n\nWARNING: Run the following lines to complete your setup:"
	@echo 'sudo -- sh -c "echo $$(kubectl get svc traefik -n kube-system -o jsonpath="{.status.loadBalancer.ingress[*].ip}") k3s >> /etc/hosts"'
	@echo 'sudo -- sh -c "echo 127.0.0.1 registry.local >> /etc/hosts"'; echo "\n\n"
endif

setup-helm: 
	k3d start -n k3s
	kubectl config use-context k3s

build:
	@CGO_ENABLED=0 go build -ldflags="-w -s -X main.version=$$VERSION" -o $$OUTPUT

docker-build:
	docker build -t $$PROJECT -t registry.local:5000/$$PROJECT:latest -t docker.pkg.github.com/polygens/$$PROJECT/$$PROJECT:latest --build-arg VERSION=$$VERSION .

run: setup build
	@$$PROJECT 

helm: setup docker-build setup-helm
	@docker push registry.local:5000/$$PROJECT:latest
	helm upgrade -i $$PROJECT ./charts --set image.repository=registry.local:5000/$$PROJECT --recreate-pods --set image.pullPolicy=Always --wait --set ingress.enabled=true
	
helm-logs: helm	
	@kubectl logs -l app.kubernetes.io/name=$$PROJECT -f
