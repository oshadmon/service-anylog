# Define variables
$(eval COMPOSE_FILE := docker-compose-operator.yaml)
CONTAINER_NAME := anylog-operator

# Set default target
all: up
## Define targets
#master-up:
#	$(eval COMPOSE_FILE := docker-compose-master.yaml)
#	$(MAKE) up
#operator-up:
#	$(eval COMPOSE_FILE := docker-compose-operator.yaml)
#	$(MAKE) up
#query-up:
#	$(eval COMPOSE_FILE  := docker-compose-query.yaml)
#	$(MAKE) up
#
#master-down:
#	$(eval COMPOSE_FILE := docker-compose-master.yaml)
#	$(MAKE) down
#operator-down:
#	$(eval COMPOSE_FILE := docker-compose-operator.yaml)
#	$(MAKE) down
#query-down:
#	$(eval COMPOSE_FILE := docker-compose-query.yaml)
#	$(MAKE) down
#
#master-clean:
#	$(eval COMPOSE_FILE := docker-compose-master.yaml)
#	$(MAKE) clean
#operator-clean:
#	$(eval COMPOSE_FILE := docker-compose-operator.yaml)
#	$(MAKE) clean
#query-clean:
#	$(eval COMPOSE_FILE := docker-compose-query.yaml)
#	$(MAKE) clean
#
#master-attach:
#	CONTAINER_NAME := anylog-master
#	$(MAKE) attach
#operator-attach:
#	CONTAINER_NAME := anylog-operator
#	$(MAKE) attach
#query-attach:
#	CONTAINER_NAME := anylog-query
#	$(MAKE) attach
#
#master-exec:
#	CONTAINER_NAME := anylog-master
#	$(MAKE) exec
#operator-exec:
#	CONTAINER_NAME := anylog-operator
#	$(MAKE) exec
#query-exec:
#	CONTAINER_NAME := anylog-query
#	$(MAKE) exec

build:
	docker pull anylogco/anylog-network:edgelake
up:
	docker-compose -f ${COMPOSE_FILE} up -d
logs:
	docker-compose -f ${COMPOSE_FILE} logs -f
attach:
	docker attach --detach-keys=ctrl-d ${CONTAINER_NAME}
exec:
	docker exec -it ${CONTAINER_NAME} bash
down:
	docker-compose -f ${COMPOSE_FILE} down

clean:
	docker-compose -f ${COMPOSE_FILE} down -v --remove-orphans

help:
	@echo "Usage: make [target]"
	@echo "Targets:"
	@echo "  build       Build the containers"
	@echo "  up          Start the containers"
	@echo "  attach      Attach to AnyLog instance"
	@echo "  exec        Attach to shell interface for container"
	@echo "  down        Stop and remove the containers"
	@echo "  logs        View logs of the containers"
	@echo "  clean       Clean up volumes and network"
	@echo "  help        Show this help message"
	@echo "Sample command: make master-up"
