# EdgeLake Service for  OpenHorizon

EdgeLake is a decentralized network to manage IoT data. Nodes in the network are compute instances that execute the EdgeLake 
Software. Joining a network requires the following steps:
1. Install the EdgeLake Software on one or more computer instances.
2. Configure each installed node (compute instance) such that:
   1. The node joins an exiting network (or creates a new network).
   2. The node offers data management and monitoring services.  


**Table of Content**:
* [Install OpenHorizon](Documentation%2FInstall_Local_OpenHorizon.md)
* [Deploy EdgeLake](#deploy-edgelake)
  * [Master + Query](#master--query)
  * [Operator](#operator)
  * [Validate Node](#validate-node)
  * [Other](#other)
* [EdgeLake KubeArmor Integration](Documentation/EdgeLake_KubeArmor_integration.md) - Accepting KubeArmor data into EdgeLake
* [Import Grafana Dashboards](Documentation/Import_Grafana_Dashboards.md) - Importing KubeArmor related gauges into Grafana 

# General Configuration of Network

A basic network setup consists of a _master node_, 2 or more _operator nodes_  and a _query_ node - as shown in the image below. 
These nodes can be deployed either on the same physical machine, or unique machines.

![Demo Diagram](imgs/deployment_diagram.png)


## Deploy EdgeLake

In the following directions, the _Master_ and _Query_ nodes will be deployed directly via Docker, while the _Operator_ 
node will be deployed via OpenHorizon.  

Prior to deployment, docker should be [installed via OpenHorizon](Documentation/OpenHorizon_install.md), but may require 
`sudo` permissions to execute docker commands. In addition, `make` command is not installed by default. 
```shell
USER=`whoami` 
sudo groupadd docker 
sudo usermod -aG docker ${USER} 
newgrp docker

sudo apt-get -y install make
```

### Master / Query

1. Update the dotenv configuration file for the desired node - [Master](docker-makefiles/edgelake_master.env) | [Query](docker-makefiles/edgelake_query.env)
Make sure the following params get update accordingly:
   * Node Name
   * Company Name
   * LEDGER_CONN associated with Master node

2. Deploy  Node
```shell
make up EDGELAKE_TYPE=master

make up EDGELAKE_TYPE=query
```
**Note**: EdgeLake version can be updated via DOCKER_IMAGE_VERSION in [Makefile](Makefile)

### Operator

1. Update the dotenv configuration file for the [Operator](docker-makefiles/edgelake_operator.env) node
Make sure the following params get update accordingly:
   * Node Name
   * Company Name
   * LEDGER_CONN
   * Cluster Name
   * Database name


2. Make sure there aren't any services running - note existing services will redeploy as part of `agent-run` in step
```shell
hzn unregister -f
```

3. Using `publish` command deploy EdgeLake
   * publish-service
   * publish-service-policy
   * publish-deployment-policy 
   * agent-run
```shell
make publish EDGELAKE_TYPE=operator
```

### Validate Node

* Test Node
```shell
make test-node EDGELAKE_TYPE=operator 

<<COMMENT
REST Connection Info for testing operator (Example: 127.0.0.1:32149):
172.232.157.208:32149
operator Node State against 
edgelake-operator@172.232.157.208:32148 running

Test                                          Status                                                                            
---------------------------------------------|---------------------------------------------------------------------------------|
Metadata Version                             |bc5b778a91949a980f4013e8fd2da3dd                                                 |
Metadata Test                                |Pass                                                                             |
TCP test using 172.232.157.208:32148         |[From Node 172.232.157.208:32148] edgelake-operator@172.232.157.208:32148 running|
REST test using http://172.232.157.208:32149 |edgelake-operator@172.232.157.208:32148 running                                  |


    Process         Status       Details                                                                       
    ---------------|------------|-----------------------------------------------------------------------------|
    TCP            |Running     |Listening on: 172.232.157.208:32148, Threads Pool: 6                         |
    REST           |Running     |Listening on: 172.232.157.208:32149, Threads Pool: 6, Timeout: 30, SSL: False|
    Operator       |Running     |Cluster Member: True, Using Master: 127.0.0.1:32048, Threads Pool: 3         |
    Blockchain Sync|Running     |Sync every 30 seconds with master using: 127.0.0.1:32048                     |
    Scheduler      |Running     |Schedulers IDs in use: [0 (system)] [1 (user)]                               |
    Blobs Archiver |Not declared|                                                                             |
    MQTT           |Not declared|                                                                             |
    Message Broker |Not declared|No active connection                                                         |
    SMTP           |Not declared|                                                                             |
    Streamer       |Running     |Default streaming thresholds are 60 seconds and 10,240 bytes                 |
    Query Pool     |Running     |Threads Pool: 3                                                              |
    Kafka Consumer |Not declared|                                                                             |
    gRPC           |Not declared|                                                                             |
<<COMMENT
```

* Test Network
```shell
make test-network EDGELAKE_TYPE=operator

<<COMMENT
REST Connection Info for testing operator (Example: 127.0.0.1:32149):
172.232.157.208:32149 
Test Network Against: 172.232.157.208:32149

Address               Node Type Node Name         Status 
---------------------|---------|-----------------|------|
172.232.157.208:32048|master   |edgelake-master  |  +   |
172.232.157.208:32348|query    |edgelake-query   |  +   |
172.232.157.208:32148|operator |edgelake-operator|  +   |
<<COMMENT
```

### Other
* Help 
```shell
make help EDGELAKE_TYPE=operator

<<COMMENT
=====================
Docker Deployment Options
=====================
build            pull latest image for anylogco/edgelake:1.3.2408
up               bring up docker container based on EDGELAKE_TYPE
attach           attach to docker container based on EDGELAKE_TYPE
logs             view docker container logs based on EDGELAKE_TYPE
down             stop docker container based on EDGELAKE_TYPE
clean            (stop and) remove volumes and images for a docker container basd on EDGELAKE_TYPE
tset-node        using cURL make sure EdgeLake is accessible and is configured properly
test-network     using cURL make sure EdgeLake node is able to communicate with nodes in the network
make: hzn: Command not found
==============================
OpenHorizon Deployment Options
==============================
publish-service            publish service to OpenHorizon
remove-service             remove service from OpenHorizon
publish-service-policy     publish service policy to OpenHorizon
remove-service-policy      remove service policy from OpenHorizon
publish-deployment-policy  publish deployment policy to OpenHorizon
remove-deployment-policy   remove deployment policy from OpenHorizon
agent-run                  start OpenHorizon service
hzn-clean                  stop OpenHorizon service
<<COMMENT
```
* Check
```shell
make check EDGELAKE_TYPE=operator

<<COMMENT
=====================
ENVIRONMENT VARIABLES
=====================
EDGELAKE_TYPE          default: generic                               actual: operator
DOCKER_IMAGE_BASE      default: anylogco/edgelake                     actual: anylogco/edgelake
DOCKER_IMAGE_NAME      default: edgelake                              actual: edgelake
DOCKER_IMAGE_VERSION   default: latest                                actual: 1.3.2408
DOCKER_HUB_ID          default: anylogco                              actual: anylogco
HZN_ORG_ID             default: myorg                                 actual: myorg
HZN_LISTEN_IP          default: 127.0.0.1                             actual: 127.0.0.1
SERVICE_NAME                                                          actual: service-edgelake-operator
SERVICE_VERSION                                                       actual: 1.3.2408
===================
EDGELAKE DEFINITION
===================
NODE_TYPE              default: generic                               actual: operator
NODE_NAME              default: edgelake-node                         actual: edgelake-operator
COMPANY_NAME           default: New Company                           actual: New Company
ANYLOG_SERVER_PORT     default: 32548                                 actual: 32148
ANYLOG_REST_PORT       default: 32549                                 actual: 32149
LEDGER_CONN            default: 127.0.0.1:32049                       actual: 66.228.62.212:32048
<<COMMENT
```

Review [Deploy EdgeLake](https://edgelake.github.io/docs/training/quick_start.html) for farther details and specific examples
 