# Makefile

# Default target
all: help
build:
	docker pull anylogco/anylog-network:edgelake
up:
	@echo "Deploy with AnyLog config file: anylog_$(filter-out $@,$(MAKECMDGOALS)).env"
	docker-compose -f docker-compose-$(filter-out $@,$(MAKECMDGOALS)).yaml up -d
down:
	docker-compose -f docker-compose-$(filter-out $@,$(MAKECMDGOALS)).yaml down
clean:
	docker-compose -f docker-compose-$(filter-out $@,$(MAKECMDGOALS)).yaml down -v --remove-orphans
attach:
	docker attach --detach-keys=ctrl-d anylog-$(filter-out $@,$(MAKECMDGOALS))
exec:
	docker exec -it anylog-$(filter-out $@,$(MAKECMDGOALS))
logs:
	docker logs anylog-$(filter-out $@,$(MAKECMDGOALS))
# Help target
help:
	@echo "Usage: make [target] [anylog-type]"
	@echo "Targets:"
	@echo "  build       Pull the docker image"
	@echo "  up          Start the containers"
	@echo "  attach      Attach to AnyLog instance"
	@echo "  exec        Attach to shell interface for container"
	@echo "  down        Stop and remove the containers"
	@echo "  logs        View logs of the containers"
	@echo "  clean       Clean up volumes and network"
	@echo "  help        Show this help message"
	@echo "	 supported AnyLog types: master, operator and query"

