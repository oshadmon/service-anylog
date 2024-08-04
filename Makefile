#!/bin/Makefile

SHELL := /bin/bash
EDGELAKE_TYPE := generic
ifneq ($(filter-out $@,$(MAKECMDGOALS)), )
	EDGELAKE_TYPE := $(filter-out $@,$(MAKECMDGOALS))
endif

YAML_FILE=docker-makefiles/edgelake_${EDGELAKE_TYPE}.yml

# Command to extract values from the YAML file
define YAML_PARSER
    $(eval $(1) = $(shell yq eval ".$(2)" $(YAML_FILE)))
endef

# Docker configurations
export DOCKER_IMAGE_BASE ?= anylogco/edgelake
export DOCKER_IMAGE_NAME ?= edgelake
export DOCKER_HUB_ID ?= anylogco
export DOCKER_IMAGE_VERSION := 1.3.2407-beta2
ifeq ($(ARCH), arm64)
	export DOCKER_IMAGE_VERSION := 1.3.2407-beta2-arm64
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
	# Check if the .env file exists and include it
	source docker-makefiles/edgelake_${EDGELAKE_TYPE}.envad
check: export-dotenv
	@echo "====================="
	@echo "ENVIRONMENT VARIABLES"
	@echo "====================="
	@echo "EDGELAKE_TYPE          default: generic                               actual: ${EDGELAKE_TYPE}"
	@echo "DOCKER_IMAGE_BASE      default: anylogco/edgelake                     actual: ${DOCKER_IMAGE_BASE}"
	@echo "DOCKER_IMAGE_NAME      default: edgelake                              actual: ${DOCKER_IMAGE_NAME}"
	@echo "DOCKER_IMAGE_VERSION   default: latest                                actual: ${DOCKER_IMAGE_VERSION}"
	@echo "DOCKER_HUB_ID          default: anylogco                              actual: ${DOCKER_HUB_ID}"
	@echo "HZN_ORG_ID             default: myorg                                 actual: ${HZN_ORG_ID}"
	@echo "HZN_LISTEN_IP          default: 127.0.0.1                             actual: ${HZN_LISTEN_IP}"
	@echo "==================="
	@echo "EDGELAKE DEFINITION"
	@echo "==================="
	@echo "NODE_TYPE              default: generic                               actual: ${NODE_TYPE}"
	@echo "NODE_NAME              default: edgelake-node                         actual: ${NODE_NAME}"
	@echo "COMPANY_NAME           default: New Company                           actual: ${COMPANY_NAME}"
	@echo "ANYLOG_SERVER_PORT     default: 32548                                 actual: ${ANYLOG_SERVER_PORT}"
	@echo "ANYLOG_REST_PORT       default: 32549                                 actual: ${ANYLOG_REST_PORT}"
	@echo "LEDGER_CONN            default: 127.0.0.1:32049                       actual: ${LEDGER_CONN}"
	@echo ""

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

publish: publish-service publish-service-policy publish-deployment-policy agent-run browse

# Pull, not push, Docker image since provided by third party
publish-service:
	@echo "=================="
	@echo "PUBLISHING SERVICE"
	@echo "=================="
	@hzn exchange service publish -O -P --json-file=service.definition.json
	@echo ""
remove-service:
	@echo "=================="
	@echo "REMOVING SERVICE"
	@echo "=================="
	@hzn exchange service remove -f $(HZN_ORG_ID)/$(SERVICE_NAME)_$(SERVICE_VERSION)_$(ARCH)
	@echo ""

publish-service-policy:
	@echo "========================="
	@echo "PUBLISHING SERVICE POLICY"
	@echo "========================="
	@hzn exchange service addpolicy -f service.policy.json $(HZN_ORG_ID)/$(SERVICE_NAME)_$(SERVICE_VERSION)_$(ARCH)
	@echo ""
remove-service-policy:
	@echo "======================="
	@echo "REMOVING SERVICE POLICY"
	@echo "======================="
	@hzn exchange service removepolicy -f $(HZN_ORG_ID)/$(SERVICE_NAME)_$(SERVICE_VERSION)_$(ARCH)
	@echo ""

publish-deployment-policy:
	@echo "============================"
	@echo "PUBLISHING DEPLOYMENT POLICY"
	@echo "============================"
	@hzn exchange deployment addpolicy -f deployment.policy.json $(HZN_ORG_ID)/policy-$(SERVICE_NAME)_$(SERVICE_VERSION)
	@echo ""
remove-deployment-policy:
	@echo "=========================="
	@echo "REMOVING DEPLOYMENT POLICY"
	@echo "=========================="
	@hzn exchange deployment removepolicy -f $(HZN_ORG_ID)/policy-$(SERVICE_NAME)_$(SERVICE_VERSION)
	@echo ""

agent-run:
	@echo "================"
	@echo "REGISTERING NODE"
	@echo "================"
	@hzn register --policy=node.policy.json
	@watch hzn agreement list
agent-stop:
	@echo "==================="
	@echo "UN-REGISTERING NODE"
	@echo "==================="
	@hzn unregister -f
	@echo ""

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
