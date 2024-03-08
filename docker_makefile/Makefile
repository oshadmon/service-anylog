# Makefile

ifeq ($(firstword $(MAKECMDGOALS)),login)
    ANYLOG_TYPE = $(word 2,$(MAKECMDGOALS))
    ifeq ($(ANYLOG_TYPE),)
        ANYLOG_TYPE = operator
    endif
endif


all: help
login:
	docker login -u anyloguser -p dckr_pat_zcjxcPOKvHkOZMuLY6UOuCs5jUc
build:
	docker pull anylogco/anylog-network:edgelake
up:
	@echo "Deploy AnyLog with config file: anylog_$(ANYLOG_TYPE).env"up
	ANYLOG_TYPE=$(ANYLOG_TYPE) envsubst < docker-compose-template.yaml > docker-compose.yaml
	docker-compose up -d --build
down:
	ANYLOG_TYPE=$(ANYLOG_TYPE) envsubst < docker-compose-template.yaml > docker-compose.yaml
	docker-compose down
clean:
	ANYLOG_TYPE=$(ANYLOG_TYPE) envsubst < docker-compose-template.yaml > docker-compose.yaml
	docker-compose down -v --remove-orphans --rmi all
attach:
	docker attach --detach-keys=ctrl-d anylog-$(ANYLOG_TYPE)
exec:
	docker exec -it anylog-$(ANYLOG_TYPE)
logs:
	docker logs anylog-$(ANYLOG_TYPE)
help:
	@echo "Usage: make [target] [anylog-type]"
	@echo "Targets:"
	@echo "  login       Log into AnyLog docker repository"
	@echo "  build       Pull the docker image"
	@echo "  up          Start the containers"
	@echo "  attach      Attach to AnyLog instance"
	@echo "  exec        Attach to shell interface for container"
	@echo "  down        Stop and remove the containers"
	@echo "  logs        View logs of the containers"
	@echo "  clean       Clean up volumes and network"
	@echo "  help        Show this help message"
	@echo "  supported AnyLog types: master, operator, and query"
	@echo "Sample calls: make up ANYLOG_TYPE=master | make attach ANYLOG_TYPE=master | make clean ANYLOG_TYPE=master"
