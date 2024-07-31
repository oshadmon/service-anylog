#!/bin/Makefile

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

# Node Deployment configs
export EDGELAKE_NODE_NAME := $(shell cat docker-makefiles/edgelake_${EDGELAKE_TYPE}.env | grep NODE_NAME | awk -F "=" '{print $$2}')
export EDGELAKE_VOLUME := $(EDGELAKE_NODE_NAME)-anylog
export BLOCKCHAIN_VOLUME := $(EDGELAKE_NODE_NAME)-blockchain
export DATA_VOLUME := $(EDGELAKE_NODE_NAME)-data
export LOCAL_SCRIPTS_VOLUME := $(EDGELAKE_NODE_NAME)-local-scripts
export REST_PORT := $(shell cat docker-makefiles/edgelake_${EDGELAKE_TYPE}.env | grep ANYLOG_REST_PORT | awk -F "=" '{print $$2}')

# Docker deployment call
DOCKER_COMPOSE := $(shell command -v docker-compose 2>/dev/null || echo "docker compose")

all: help-docker help-open-horizon
generate-docker-compose:
	EDGELAKE_TYPE=$(EDGELAKE_TYPE) envsubst < docker-makefiles/docker-compose-template.yaml > docker-makefiles/docker-compose.yaml
remove-docker-compose: 
	@rm -rf docker-makefiles/docker-compose.yaml
check:
	@echo "====================="
	@echo "ENVIRONMENT VARIABLES"
	@echo "====================="
	@echo "EDGELAKE_TYPE          default: generic                               actual: ${EDGELAKE_TYPE}"
	@echo "DOCKER_IMAGE_BASE      default: anylogco/edgelake                     actual: ${DOCKER_IMAGE_BASE}"
	@echo "DOCKER_IMAGE_NAME      default: edgelake                              actual: ${DOCKER_IMAGE_NAME}"
	@echo "DOCKER_IMAGE_VERSION   default: latest                                actual: ${DOCKER_IMAGE_VERSION}"
# 	@echo "DOCKER_VOLUME_NAME     default: homeassistant_config                  actual: ${DOCKER_VOLUME_NAME}"
	@echo "DOCKER_HUB_ID          default: anylogco                              actual: ${DOCKER_HUB_ID}"
	@echo "HZN_ORG_ID             default: myorg                                 actual: ${HZN_ORG_ID}"
	@echo "HZN_LISTEN_IP		  default: 127.0.0.1                             actual: $(HZN_LISTEN_IP)"
# 	@echo "MY_TIME_ZONE           default: America/New_York                      actual: ${MY_TIME_ZONE}"
# 	@echo "DEPLOYMENT_POLICY_NAME default: deployment-policy-homeassistant       actual: ${DEPLOYMENT_POLICY_NAME}"
# 	@echo "NODE_POLICY_NAME       default: node-policy-homeassistant             actual: ${NODE_POLICY_NAME}"
# 	@echo "SERVICE_NAME           default: service-homeassistant                 actual: ${SERVICE_NAME}"
# 	@echo "SERVICE_VERSION        default: 0.0.1                                 actual: ${SERVICE_VERSION}"
# 	@echo "ARCH                   default: amd64                                 actual: ${ARCH}"
	@echo "=================="
	@echo "SERVICE DEFINITION"
	@echo "=================="
#	@cat service.definition.json | envsubst
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
	@curl -X GET $(HZN_LISTEN_IP):$(REST_PORT) -H "command: test network"
attach:
	@docker attach --detach-keys=ctrl-d $(EDGELAKE_NODE_NAME)
logs:
	@docker logs $(EDGELAKE_NODE_NAME)