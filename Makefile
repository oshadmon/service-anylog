# Makefile

ANYLOG_TYPE := operator
ifneq ($(filter-out $@,$(MAKECMDGOALS)), )
	ANYLOG_TYPE = $(filter-out $@,$(MAKECMDGOALS))
endif

all: help
login:
	docker login -u anyloguser -p dckr_pat_zcjxcPOKvHkOZMuLY6UOuCs5jUc
build:
	docker pull anylogco/anylog-network:edgelake
up:
	@echo "Deploy AnyLog with config file: anylog_$(ANYLOG_TYPE).env"
	ANYLOG_TYPE=$(ANYLOG_TYPE) envsubst < docker_makefile/docker-compose-template.yaml > docker_makefile/docker-compose.yaml
	@docker-compose -f docker_makefile/docker-compose.yaml up -d
	@rm -rf docker_makefile/docker-compose.yaml
down:
	ANYLOG_TYPE=$(ANYLOG_TYPE) envsubst < docker_makefile/docker-compose-template.yaml > docker_makefile/docker-compose.yaml
	@docker-compose -f docker_makefile/docker-compose.yaml down
	@rm -rf docker_makefile/docker-compose.yaml
clean:
	ANYLOG_TYPE=$(ANYLOG_TYPE) envsubst < docker_makefile/docker-compose-template.yaml > docker_makefile/docker-compose.yaml
	@docker-compose -f docker_makefile/docker-compose.yaml down -v --remove-orphans --rmi all
	@rm -rf docker_makefile/docker-compose.yaml
attach:
	docker attach --detach-keys=ctrl-d anylog-$(ANYLOG_TYPE)
test:
	@if [ "$(ANYLOG_TYPE)" = "master" ]; then \
		curl -X GET 127.0.0.1:32049 -H "command: test node" -H "User-Agent: AnyLog/1.23"; \
	elif [ "$(ANYLOG_TYPE)" = "operator" ]; then \
		curl -X GET 127.0.0.1:32149 -H "command: test node" -H "User-Agent: AnyLog/1.23"; \
	elif [ "$(ANYLOG_TYPE)" = "query" ]; then \
		curl -X GET 127.0.0.1:32349 -H "command: test node" -H "User-Agent: AnyLog/1.23"; \
	fi
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
	@echo "  test		 Using cURL validate node is running"
	@echo "  exec        Attach to shell interface for container"
	@echo "  down        Stop and remove the containers"
	@echo "  logs        View logs of the containers"
	@echo "  clean       Clean up volumes and network"
	@echo "  help        Show this help message"
	@echo "  supported AnyLog types: master, operator, and query"
	@echo "Sample calls: make up ANYLOG_TYPE=master | make attach ANYLOG_TYPE=master | make clean ANYLOG_TYPE=master"
