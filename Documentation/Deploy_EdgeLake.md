# Deploying EdgeLake

Transform your edge nodes into members of a permissioned decentralized network, optimized to manage and monitor data and resources at the edge.

Deploy EdgeLake instances on your nodes at the edge.
* Enable services on each node.
* Stream data from your PLCs, Sensors, and applications to the edge nodes.
* Query the distributed data from a single point (as if the data is hosted in a centralized database).
* Manage your edge resources from a single point (the network of nodes reflects a Single System Image).

## Prepare Node
**Option 1**: [Install OpenHorizon Service](OpenHorizon_install.md) 
1. Install _make_ 
```shell
sudo apt-get -y install make
```

2. Follow directions in [OpenHorizon Installation](OpenHorizon_install.md) to install _docker_ and connect to OpenHorizon


3. Clone [service-edgelake](https://github.com/open-horizon-services/service-edgelake) 
```shell
git clone https://github.com/open-horizon-services/service-edgelake
```

**Option 2**: Manually install requirements (without OpenHorizon)
1. Install _make_
 ```shell
sudo apt-get -y install make
```

2. Install docker and set permissions for non-sudo user
```shell
sudo snap install docker
USER=`whoami` 
sudo groupadd docker 
sudo usermod -aG docker ${USER} 
newgrp docker 
```

3. Install _docker-compose_
```shell
sudo apt-get -y install docker-compose
```

4. Clone [service-edgelake](https://github.com/open-horizon-services/service-edgelake) 
```shell
git clone https://github.com/open-horizon-services/service-edgelake
```

## Deploy via make and docker-compose 
1. Update .env configurations for the node(s) being deployed - Edit `LEDGER_CONN` in _Query_ and _Operator_ using IP address of _Master node_
    * [docker_makefile/edgelake_master.env](../docker_makefile/edgelake_master.env)
    * [docker_makefile/edgelake_operator.env](../docker_makefile/edgelake_operator.env)
    * [docker_makefile/edgelake_query.env](../docker_makefile/edgelake_query.env)
```dotenv
#--- General ---
# Information regarding which AnyLog node configurations to enable. By default, even if everything is disabled, AnyLog starts TCP and REST connection protocols
NODE_TYPE=master
# Name of the AnyLog instance
NODE_NAME=edgelake-master
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

#--- Database ---
# Physical database type (sqlite or psql)
DB_TYPE=sqlite
# Username for SQL database connection
DB_USER=""
# Password correlated to database user
DB_PASSWD=""
# Database IP address
DB_IP=127.0.0.1
# Database port number
DB_PORT=5432
# Whether to set autocommit data
AUTOCOMMIT=false

#--- Blockchain ---
# TCP connection information for Master Node
LEDGER_CONN=127.0.0.1:32048

#--- Advanced Settings ---
# Whether to automatically run a local (or personalized) script at the end of the process
DEPLOY_LOCAL_SCRIPT=false
```

2. Start Node using makefile
```shell
make up EDGELAKE_TYPE=[NODE_TYPE]
```

### Makefile Commands for docker deployment 

* help
```shell
Usage: make [target] EDGELAKE_TYPE=[anylog-type]
Targets:
  build       Pull the docker image
  up          Start the containers
  attach      Attach to EdgeLake instance
  exec        Attach to shell interface for container
  down        Stop and remove the containers
  logs        View logs of the containers
  clean       Clean up volumes and network
  help        Show this help message
         supported EdgeLake types: master, operator and query
Sample calls: make up EDGELAKE_TYPE=master | make attach EDGELAKE_TYPE=master | make clean EDGELAKE_TYPE=master
```

* Bring up a _query_ node
```shell
make up EDGELAKE_TYPE=query
```

* Attach to _query_ node
```shell
# to detach: ctrl-d
make attach EDGELAKE_TYPE=query  
```

* Bring down _query_ node
```shell
make down EDGELAKE_TYPE=query
```
If a _node-type_ is not set, then a generic node would automatically be used    

