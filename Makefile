# Makefile

EDGELAKE_TYPE := generic
ifneq ($(filter-out $@,$(MAKECMDGOALS)), )
	EDGELAKE_TYPE := $(filter-out $@,$(MAKECMDGOALS))
endif

# include docker-makefiles/edgelake_$(EDGELAKE_TYPE).env

export EXTRACT_NODE_NAME := $(shell cat docker_makefile/edgelake_master.env | grep NODE_NAME | awk -F "=" '{print $$2}')
export DOCKER_IMAGE_BASE ?= anylogco/edgelake
export DOCKER_IMAGE_NAME ?= edgelake

export DOCKER_IMAGE_VERSION := 1.3.2407-beta1
ifeq ($(ARCH), arm64)
	export DOCKER_IMAGE_VERSION := 1.3.2405-arm64
endif

export DOCKER_HUB_ID ?= anylogco
export HZN_ORG_ID ?= alog

export DEPLOYMENT_POLICY_NAME := deployment-policy-edgelake-$(EDGELAKE_TYPE)
export NODE_POLICY_NAME := node-policy-edgelake-$(EDGELAKE_TYPE)
export SERVICE_NAME := service-edgelake-$(EDGELAKE_TYPE)
export SERVICE_VERSION := $(shell curl -s https://raw.githubusercontent.com/EdgeLake/EdgeLake/main/setup.cfg | grep "version = " | awk -F " = " '{print $$2}')

export EDGELAKE_VOLUME := edgelake-$(EDGELAKE_TYPE)-anylog
export BLOCKCHAIN_VOLUME := edgelake-$(EDGELAKE_TYPE)-blockchain
export DATA_VOLUME := edgelake-$(EDGELAKE_TYPE)-data
export LOCAL_SCRIPTS_VOLUME := edgelake-$(EDGELAKE_TYPE)-local-scripts

DOCKER_COMPOSE := $(shell command -v docker-compose 2>/dev/null || echo "docker compose")

# Targets
all: help-docker help-open-horizon

build:
	$(DOCKER_COMPOSE) pull

up:
	@echo "Deploying AnyLog with config file: anylog_$(EDGELAKE_TYPE).env"
	EDGELAKE_TYPE=$(EDGELAKE_TYPE) envsubst < docker_makefile/docker-compose-template.yaml > docker_makefile/docker-compose.yaml
	$(DOCKER_COMPOSE) -f docker_makefile/docker-compose.yaml up -d
	@rm -rf docker_makefile/docker-compose.yaml

down:
	EDGELAKE_TYPE=$(EDGELAKE_TYPE) envsubst < docker_makefile/docker-compose-template.yaml > docker_makefile/docker-compose.yaml
	$(DOCKER_COMPOSE) -f docker_makefile/docker-compose.yaml down
	@rm -rf docker_makefile/docker-compose.yaml

clean:
	EDGELAKE_TYPE=$(EDGELAKE_TYPE) envsubst < docker_makefile/docker-compose-template.yaml > docker_makefile/docker-compose.yaml
	$(DOCKER_COMPOSE) -f docker_makefile/docker-compose.yaml down -v --remove-orphans --rmi all
	@rm -rf docker_makefile/docker-compose.yaml

attach:
	docker attach --detach-keys=ctrl-d edgelake-$(EDGELAKE_TYPE)

node-status:
	@if [ "$(EDGELAKE_TYPE)" = "master" ]; then \
		curl -X GET 127.0.0.1:32049 -H "command: get status" -H "User-Agent: AnyLog/1.23" -w "\n"; \
	elif [ "$(EDGELAKE_TYPE)" = "operator" ]; then \
		curl -X GET 127.0.0.1:32149 -H "command: get status" -H "User-Agent: AnyLog/1.23" -w "\n"; \
	elif [ "$(EDGELAKE_TYPE)" = "query" ]; then \
		curl -X GET 127.0.0.1:32349 -H "command: get status" -H "User-Agent: AnyLog/1.23" -w "\n"; \
	elif [ "$(EDGELAKE_TYPE)" = "generic" ]; then \
		curl -X GET 127.0.0.1:32549 -H "command: get status" -H "User-Agent: AnyLog/1.23" -w "\n"; \
	fi

test-node:
	@if [ "$(EDGELAKE_TYPE)" = "master" ]; then \
		curl -X GET 127.0.0.1:32049 -H "command: test node" -H "User-Agent: AnyLog/1.23" -w "\n"; \
	elif [ "$(EDGELAKE_TYPE)" = "operator" ]; then \
		curl -X GET 127.0.0.1:32149 -H "command: test node" -H "User-Agent: AnyLog/1.23" -w "\n"; \
	elif [ "$(EDGELAKE_TYPE)" = "query" ]; then \
		curl -X GET 127.0.0.1:32349 -H "command: test node" -H "User-Agent: AnyLog/1.23" -w "\n"; \
	elif [ "$(EDGELAKE_TYPE)" = "generic" ]; then \
		curl -X GET 127.0.0.1:32549 -H "command: test node" -H "User-Agent: AnyLog/1.23" -w "\n"; \
	fi

test-network:
	@if [ "$(EDGELAKE_TYPE)" = "master" ]; then \
		curl -X GET 127.0.0.1:32049 -H "command: test network" -H "User-Agent: AnyLog/1.23" -w "\n"; \
	elif [ "$(EDGELAKE_TYPE)" = "operator" ]; then \
		curl -X GET 127.0.0.1:32149 -H "command: test network" -H "User-Agent: AnyLog/1.23" -w "\n"; \
	elif [ "$(EDGELAKE_TYPE)" = "query" ]; then \
		curl -X GET 127.0.0.1:32349 -H "command: test network" -H "User-Agent: AnyLog/1.23" -w "\n"; \
	elif [ "$(EDGELAKE_TYPE)" = "generic" ]; then \
		curl -X GET 127.0.0.1:32549 -H "command: test network" -H "User-Agent: AnyLog/1.23" -w "\n"; \
	fi

exec:
	docker exec -it edgelake-$(EDGELAKE_TYPE) bash

logs:
	docker logs edgelake-$(EDGELAKE_TYPE)

# OpenHorizon targets
publish-service:
	hzn exchange service publish -O -P --json-file=hzn/service.definition.json

remove-service:
	hzn exchange service remove -f $(HZN_ORG_ID)/$(SERVICE_NAME)_$(SERVICE_VERSION)_$(ARCH)

publish-service-policy:
	hzn exchange service addpolicy -f hzn/service.policy.json $(HZN_ORG_ID)/$(SERVICE_NAME)_$(SERVICE_VERSION)_$(ARCH)

remove-service-policy:
	hzn exchange service removepolicy -f $(HZN_ORG_ID)/$(SERVICE_NAME)_$(SERVICE_VERSION)_$(ARCH)

publish-deployment-policy:
	hzn exchange deployment addpolicy -f hzn/deployment.policy.$(EDGELAKE_TYPE).json $(HZN_ORG_ID)/policy-$(SERVICE_NAME)-$(EDGELAKE_TYPE)

remove-deployment-policy:
	hzn exchange deployment removepolicy -f hzn/deployment.policy.$(EDGELAKE_TYPE).json $(HZN_ORG_ID)/policy-$(SERVICE_NAME)-$(EDGELAKE_TYPE)_$(SERVICE_VERSION)_$(EXTRACT_NODE_NAME).json

agent-run:
	hzn register --policy=hzn/node.policy.$(EDGELAKE_TYPE).json
	watch hzn agreement list

agent-stop:
	hzn unregister -f

deploy-check:
	hzn deploycheck all -t device -B hzn/deployment.policy.$(EDGELAKE_TYPE).json --service=hzn/service.definition.json --node-pol=hzn/node.policy.$(EDGELAKE_TYPE).json

# Help targets
help-docker:
	@echo "Usage: make [target] EDGELAKE_TYPE=[edgelake-type]"
	@echo "Targets:"
	@echo "  all           Get help for both docker and OpenHorizon deployments"
	@echo "  build         Pull the docker image"
	@echo "  up            Start the containers"
	@echo "  attach        Attach to EdgeLake instance"
	@echo "  test-node     Validate node is able to communicate and has a valid blockchain file"
	@echo "  exec          Attach to shell interface for container"
	@echo "  down          Stop and remove the containers"
	@echo "  logs          View logs of the containers"
	@echo "  node-status   Validate node is accessible via REST"
	@echo "  test-network  Validate node is able to communicate with other nodes within its network"
	@echo "  clean         Clean up volumes and network"
	@echo "  help-docker   Show this help message"
	@echo "Supported EdgeLake types: generic, master, operator, and query"

