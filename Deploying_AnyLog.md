# Deploying AnyLog 

The following provides direction to deploy AnyLog using [_makefile_](Makefile) for Docker-based deployment. 

**Requirements**
* [Open Horizon](OpenHorizon_install.md) - includes docker
```shell
sudo snap install docker
 
# Grant non-root user permissions to use docker
USER=`whoami` 
sudo groupadd docker 
sudo usermod -aG docker ${USER} 
newgrp docker
```

* _docker-compose_
```shell
sudo apt-get -y install docker-compose 
```

* _make_
```shell
sudo apt-get -y install make
```

## Prepare Machine
1. Clone _service-anylog_
```shell
git clone https://github.com/open-horizon-services/service-anylog/
cd service-anylog
```

2. Log into AnyLog Docker hub 
```shell
make login
```

## Deploy AnyLog via Docker 
1. Update `.env` configurations for the node(s) being deployed 
   * [master node](dokcer_makefile/anylog_master.env)
   * [operator node](dokcer_makefile/anylog_operator.env)
   * [query node](dokcer_makefile/anylog_query.env)

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

2. Start Node using _makefile_
```shell
make up [NODE_TYPE]
```

### Makefile Commands for Docker
* help
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
If a _node-type_ is not set, then a generic node would automatically be used    

