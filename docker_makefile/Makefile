# Makefile

all: help
login:
	docker login -u anyloguser -p dckr_pat_zcjxcPOKvHkOZMuLY6UOuCs5jUc
build:
	docker pull anylogco/anylog-network:edgelake
up:
	@echo "Deploy AnyLog with config file: anylog_$(filter-out $@,$(MAKECMDGOALS)).env"
	docker-compose -f docker-compose-$(filter-out $@,$(MAKECMDGOALS)).yaml up -d
down:
	docker-compose -f docker-compose-$(filter-out $@,$(MAKECMDGOALS)).yaml down
clean:
	docker-compose -f docker-compose-$(filter-out $@,$(MAKECMDGOALS)).yaml down -v --remove-orphans --rmi alls
attach:
	docker attach --detach-keys=ctrl-d anylog-$(filter-out $@,$(MAKECMDGOALS))
exec:
	docker exec -it anylog-$(filter-out $@,$(MAKECMDGOALS))
logs:
	docker logs anylog-$(filter-out $@,$(MAKECMDGOALS))
help:
	@echo "Usage: make [target] [anylog-type]"
	@echo "Targets:"
	@echo "	 login		 Log into AnyLog docker repository"
	@echo "  build       Pull the docker image"
	@echo "  up          Start the containers"
	@echo "  attach      Attach to AnyLog instance"
	@echo "  exec        Attach to shell interface for container"
	@echo "  down        Stop and remove the containers"
	@echo "  logs        View logs of the containers"
	@echo "  clean       Clean up volumes and network"
	@echo "  help        Show this help message"
	@echo "	 supported AnyLog types: master, operator and query"
	@echo "Sample calls: make up master | make attach master | make clean master"
