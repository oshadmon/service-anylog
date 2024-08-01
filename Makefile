#!/bin/Makefile

SHELL := /bin/bash
EDGELAKE_TYPE := generic
ifneq ($(filter-out $@,$(MAKECMDGOALS)), )
	EDGELAKE_TYPE := $(filter-out $@,$(MAKECMDGOALS))
endif

# Docker configurations
export DOCKER_IMAGE_BASE ?= anylogco/edgelake
export DOCKER_IMAGE_NAME ?= edgelake
export DOCKER_HUB_ID ?= anylogco
export DOCKER_IMAGE_VERSION := 1.3.2407
ifeq ($(ARCH), arm64)
	export DOCKER_IMAGE_VERSION := 1.3.2407-arm64
endif

# Open Horizon Configs
export HZN_ORG_ID ?= myorg
export HZN_LISTEN_IP ?= 127.0.0.1
export SERVICE_NAME ?= service-edgelake
export SERVICE_VERSION ?= 0.0.1
export ARCH=amd64
ifeq ($(ARCH), arm64)
	export ARCH=arm64
endif

# Node Deployment configs
export EDGELAKE_NODE_NAME := $(shell cat docker-makefiles/edgelake_${EDGELAKE_TYPE}.env | grep NODE_NAME | awk -F "=" '{print $$2}')
export EDGELAKE_VOLUME := $(EDGELAKE_NODE_NAME)-anylog
export BLOCKCHAIN_VOLUME := $(EDGELAKE_NODE_NAME)-blockchain
export DATA_VOLUME := $(EDGELAKE_NODE_NAME)-data
export LOCAL_SCRIPTS_VOLUME := $(EDGELAKE_NODE_NAME)-local-scripts
export REST_PORT := $(shell cat docker-makefiles/edgelake_${EDGELAKE_TYPE}.env | grep ANYLOG_REST_PORT | awk -F "=" '{print $$2}')

# Docker deployment call
DOCKER_COMPOSE := $(shell command -v docker-compose 2>/dev/null || echo "docker compose")

help: help-docker help-open-horizon
generate-docker-compose:
	EDGELAKE_TYPE=$(EDGELAKE_TYPE) envsubst < docker-makefiles/docker-compose-template.yaml > docker-makefiles/docker-compose.yaml
remove-docker-compose: 
	@rm -rf docker-makefiles/docker-compose.yaml
export-dotenv:
	@echo "Loading environment variables from docker-makefiles/edgelake_$(EDGELAKE_TYPE).env"
	@cp docker-makefiles/edgelake_$(EDGELAKE_TYPE).env docker-makefiles/edgelake_configs_tmp.env
	@sed -i 's/\(COMPANY_NAME=\)\(.*\)/\1"\2"/; s/\(MSG_TABLE=\)\(.*\)/\1"\2"/; s/\(MSG_TIMESTAMP_COLUMN=\)\(.*\)/\1"\2"/; s/\(MSG_VALUE_COLUMN=\)\(.*\)/\1"\2"/' docker-makefiles/edgelake_configs_tmp.env
	@echo "Creating temporary environment file"
	@set -o allexport; source docker-makefiles/edgelake_configs_tmp.env; set +o allexport; \
		env | grep -E '^(EDGELAKE_TYPE|DOCKER_IMAGE_BASE|DOCKER_IMAGE_NAME|DOCKER_IMAGE_VERSION|DOCKER_HUB_ID|HZN_ORG_ID|HZN_LISTEN_IP|NODE_TYPE|NODE_NAME|COMPANY_NAME|ANYLOG_SERVER_PORT|ANYLOG_REST_PORT|LEDGER_CONN)=' > docker-makefiles/edgelake_env_vars.sh

check: export-dotenv
	@echo "====================="
	@echo "ENVIRONMENT VARIABLES"
	@echo "====================="
	@source docker-makefiles/edgelake_env_vars.sh; \
	echo "EDGELAKE_TYPE          default: generic                               actual: $$EDGELAKE_TYPE"; \
	echo "DOCKER_IMAGE_BASE      default: anylogco/edgelake                     actual: $$DOCKER_IMAGE_BASE"; \
	echo "DOCKER_IMAGE_NAME      default: edgelake                              actual: $$DOCKER_IMAGE_NAME"; \
	echo "DOCKER_IMAGE_VERSION   default: latest                                actual: $$DOCKER_IMAGE_VERSION"; \
	echo "DOCKER_HUB_ID          default: anylogco                              actual: $$DOCKER_HUB_ID"; \
	echo "HZN_ORG_ID             default: myorg                                 actual: $$HZN_ORG_ID"; \
	echo "HZN_LISTEN_IP          default: 127.0.0.1                             actual: $$HZN_LISTEN_IP"; \
	echo "==================="; \
	echo "EDGELAKE DEFINITION"; \
	echo "==================="; \
	echo "NODE_TYPE              default: generic                               actual: $$NODE_TYPE"; \
	echo "NODE_NAME              default: edgelake-node                         actual: $$NODE_NAME"; \
	echo "COMPANY_NAME           default: New Company                           actual: $$COMPANY_NAME"; \
	echo "ANYLOG_SERVER_PORT     default: 32548                                 actual: $$ANYLOG_SERVER_PORT"; \
	echo "ANYLOG_REST_PORT       default: 32549                                 actual: $$ANYLOG_REST_PORT"; \
	echo "LEDGER_CONN            default: 127.0.0.1:32049                       actual: $$LEDGER_CONN"; \
	echo ""

build:
	@echo "Pulling image $(DOCKER_IMAGE_BASE):$(DOCKER_IMAGE_VERSION)"
	docker pull $(DOCKER_IMAGE_BASE):$(DOCKER_IMAGE_VERSION)
up: generate-docker-compose
	@echo "Deploying EdgeLake with config file: edgelake_$(EDGELAKE_TYPE).env"
	@$(DOCKER_COMPOSE) -f docker-makefiles/docker-compose.yaml up -d
	@$(MAKE) remove-docker-compose
down: generate-docker-compose
	@echo "Stopping EdgeLake with config file: edgelake_$(EDGELAKE_TYPE).env"
	$(DOCKER_COMPOSE) -f docker-makefiles/docker-compose.yaml down
	@$(MAKE) remove-docker-compose
clean: generate-docker-compose
	@echo "Cleaning EdgeLake with config file: edgelake_$(EDGELAKE_TYPE).env"
	@$(DOCKER_COMPOSE) -f docker-makefiles/docker-compose.yaml down -v --rmi all
	@$(MAKE) remove-docker-compose
test-node:
	@echo "Test Node Against: $(HZN_LISTEN_IP):$(REST_PORT)"
	@curl -X GET $(HZN_LISTEN_IP):$(REST_PORT)
	@curl -X GET $(HZN_LISTEN_IP):$(REST_PORT) -H "command: test node"
test-network:
	@echo "Test Network Against: $(HZN_LISTEN_IP):$(REST_PORT)"
	@curl -X GET $(HZN_LISTEN_IP):$(REST_PORT) -H "command: test network"
attach:
	@docker attach --detach-keys=ctrl-d $(EDGELAKE_NODE_NAME)
logs:
	@docker logs $(EDGELAKE_NODE_NAME)
publish-service:
	hzn exchange service publish -o $(HZN_ORG_ID) -O -P --json-file=service.definition.json
publish-service-policy: export-dotenv
	hzn exchange service addpolicy -f service.policy.json $(HZN_ORG_ID)/$(SERVICE_NAME)_$(SERVICE_VERSION)_$(ARCH)
help-docker:
	@echo "====================="
	@echo "Docker Deployment Options"
	@echo "====================="
	@echo "build            pull latest image for $(DOCKER_IMAGE_BASE):$(DOCKER_IMAGE_VERSION)"
	@echo "up               bring up docker container based on EDGELAKE_TYPE"
	@echo "attach           attach to docker container based on EDGELAKE_TYPE"
	@echo "logs             view docker container logs based on EDGELAKE_TYPE"
	@echo "down             stop docker container based on EDGELAKE_TYPE"
	@echo "clean            (stop and) remove volumes and iamges for a docker container basd on EDGELAKE_TYPE"
	@echo "tset-node        using cURL make sure EdgeLake is accessible and is configured properly"
	@echo "test-network     using cURL make sure EdgeLake node is able to communicate with nodes in the network"
