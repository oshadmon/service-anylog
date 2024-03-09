# Multi-arch docker container instance of the open-source grafana project intended for Open Horizon Linux edge nodes
# grafana docker supports amd64, arm/v7 and arm64
export DOCKER_IMAGE_BASE ?= anylogco/anylog-network
export DOCKER_IMAGE_NAME ?= latest
export DOCKER_IMAGE_VERSION ?= latest
#export DOCKER_VOLUME_NAME ?= grafana-storage

# DockerHub ID of the third party providing the image (usually yours if building and pushing) 
export DOCKER_HUB_ID ?= anyloguser

# The Open Horizon organization ID namespace where you will be publishing the service definition file
export HZN_ORG_ID ?= examples

# Variables required by Home Assistant, can be overridden by your environment variables
#export MY_TIME_ZONE ?= America/New_York

# Open Horizon settings for publishing metadata about the service
export DEPLOYMENT_POLICY_NAME ?= deployment-policy-anylog
export NODE_POLICY_NAME ?= node-policy-anylog
export SERVICE_NAME ?= service-anylog
export SERVICE_VERSION ?= 1.3.2403

# Default ARCH to the architecture of this machine (assumes hzn CLI installed)
export ARCH ?= amd64

# Detect Operating System running Make
OS := $(shell uname -s)

default: init run browse

check:
	@echo "====================="
	@echo "ENVIRONMENT VARIABLES"
	@echo "====================="
	@echo "DOCKER_IMAGE_BASE      default: anylogco/anylog-network			actual: ${DOCKER_IMAGE_BASE}"
	@echo "DOCKER_IMAGE_NAME      default: latest                        	actual: ${DOCKER_IMAGE_NAME}"
	@echo "DOCKER_IMAGE_VERSION   default: latest                        	actual: ${DOCKER_IMAGE_VERSION}"
#	@echo "DOCKER_VOLUME_NAME     default: grafana-storage                 	actual: ${DOCKER_VOLUME_NAME}"
	@echo "DOCKER_HUB_ID           default: anyloguser                     	actual: ${DOCKER_HUB_ID}"
	@echo "HZN_ORG_ID             default: examples                        	actual: ${HZN_ORG_ID}"
	@echo "MY_TIME_ZONE           default: America/New_York                	actual: ${MY_TIME_ZONE}"
	@echo "DEPLOYMENT_POLICY_NAME default: deployment-policy-grafana       	actual: ${DEPLOYMENT_POLICY_NAME}"
	@echo "NODE_POLICY_NAME       default: node-policy-grafana             	actual: ${NODE_POLICY_NAME}"
	@echo "SERVICE_NAME           default: service-grafana                 	actual: ${SERVICE_NAME}"
	@echo "SERVICE_VERSION        default: 1.3.2303                        	actual: ${SERVICE_VERSION}"
	@echo "ARCH                   default: amd64                           	actual: ${ARCH}"
	@echo ""
	@echo "=================="
	@echo "SERVICE DEFINITION"
	@echo "=================="
	@cat service.definition.json | envsubst
	@echo ""
stop:
	@docker rm -f $(DOCKER_IMAGE_NAME) >/dev/null 2>&1 || :

init:
	@docker volume create $(DOCKER_VOLUME_NAME)

run: stop
	@docker run -d \
		--name $(DOCKER_IMAGE_NAME) \
		--restart=unless-stopped \
		-e TZ=$(MY_TIME_ZONE) \
		-v $(DOCKER_VOLUME_NAME):/var/lib/grafana \
		-p 3000:3000 \
		$(DOCKER_IMAGE_BASE):$(DOCKER_IMAGE_VERSION)

dev: run attach

attach: 
	@docker exec -it \
		`docker ps -aqf "name=$(DOCKER_IMAGE_NAME)"` \
		/bin/bash		

test:
	@curl -sS http://127.0.0.1:3000

browse:
ifeq ($(OS),Darwin)
	@open http://127.0.0.1:3000
else
	@xdg-open http://127.0.0.1:3000
endif

clean: stop
	@docker rmi -f $(DOCKER_IMAGE_BASE):$(DOCKER_IMAGE_VERSION) >/dev/null 2>&1 || :
	@docker volume rm $(DOCKER_VOLUME_NAME)

distclean: agent-stop remove-deployment-policy remove-service-policy remove-service clean

build:
	@echo "There is no Docker image build process since this container is provided by a third-party from official sources."

push:
	@echo "There is no Docker image push process since this container is provided by a third-party from official sources."

publish: publish-service publish-service-policy publish-deployment-policy agent-run browse

# Pull, not push, Docker image since provided by third party
# create service in GUI/services + docker image to edge node
publish-service:
	@echo "=================="
	@echo "PUBLISHING SERVICE"
	@echo "=================="
	@hzn exchange service publish -O -P --json-file=service.definition.json
	@echo ""

# remove service from GUI
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

# added policy
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

# hzn run followed by watch
agent-run:
	@echo "================"
	@echo "REGISTERING NODE"
	@echo "================"
	@hzn register --policy=node.policy.json
	@watch hzn agreement list

# unregister
agent-stop:
	@echo "==================="
	@echo "UN-REGISTERING NODE"
	@echo "==================="
	@hzn unregister -f
	@echo ""

deploy-check:
	@hzn deploycheck all -t device -B deployment.policy.json --service=service.definition.json --service-pol=service.policy.json --node-pol=node.policy.json

log:
	@echo "========="
	@echo "EVENT LOG"
	@echo "========="
	@hzn eventlog list
	@echo ""
	@echo "==========="
	@echo "SERVICE LOG"
	@echo "==========="
	@hzn service log -f $(SERVICE_NAME)

.PHONY: default stop init run dev test clean build push attach browse publish publish-service publish-service-policy publish-deployment-policy publish-pattern agent-run distclean deploy-check check log remove-deployment-policy remove-service-policy remove-service

