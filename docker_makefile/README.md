# Docker Makefile

This repository provides a Dockerized environment for running AnyLog instances with different roles: _master_, 
_operator_, or _query_. Use this README to set up and manage your AnyLog environment 

## Prerequisites
* make
```shell
sudo apt-get -y install make
```
* docker and docker-compose
```shell
sudo snap install docker

# Grant non-root user permissions to use docker
USER=`whoami` 
sudo groupadd docker 
sudo usermod -aG docker ${USER} 
newgrp docker
```

## Update `.env` configurations 
* [master node](anylog_master.env)
* [operator node](anylog_operator.env)
* [query node](anylog_query.env)

### Sample Configuration file
```dotenv
#--- General ---
# Information regarding which AnyLog node configurations to enable. By default, even if everything is disabled, AnyLog starts TCP and REST connection protocols
NODE_TYPE=master
# Name of the AnyLog instance
NODE_NAME=anylog-master
# Owner of the AnyLog instance
COMPANY_NAME=New Company

#--- Networking ---
# Port address used by AnyLog's TCP protocol to communicate with other nodes in the network
ANYLOG_SERVER_PORT=32048
# Port address used by AnyLog's REST protocol
ANYLOG_REST_PORT=32049
# A bool value that determines if to bind to a specific IP and Port (a false value binds to all IPs)
TCP_BIND=false
# A bool value that determines if to bind to a specific IP and Port (a false value binds to all IPs)
REST_BIND=false

#--- Blockchain ---
# TCP connection information for Master Node
LEDGER_CONN=127.0.0.1:32048

#--- Advanced Settings ---
# Whether to automatically run a local (or personalized) script at the end of the process
DEPLOY_LOCAL_SCRIPT=false
```

## Usage
### `make` commands 
```shell
Usage: make [target] [anylog-type]
Targets:
  build       Pull the docker image
  up          Start the containers
  attach      Attach to AnyLog instance
  exec        Attach to shell interface for container
  down        Stop and remove the containers
  logs        View logs of the containers
  clean       Clean up volumes and network
  help        Show this help message
         supported AnyLog types: master, operator and query
Sample calls: make up master | make attach master | make clean master
```

### Sample Commands 
* Bring up a _query_ node
```shell
make up query
```

* Attach to _query_ node
```shell
# to detach: ctrl-d
make attach query  
```

* Bring down _query_ node
```shell
make down query
``` 

If a _node-type_ is not set, then an operator node would automatically be used    

