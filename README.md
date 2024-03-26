# EdgeLake Service for  OpenHorizon

EdgeLake is a decentralized network to manage IoT data. Nodes in the network are compute instances that execute the EdgeLake 
Software. Joining a network requires the following steps:
1. Install the EdgeLake Software on computer instance
2. Configure a node such that it can join an exiting network (or create a new network).


**Table of Content**:
* [Install OpenHorizon](Documentation/OpenHorizon_install.md) - Steps to install OpenHorizon
* [EdgeLake via Makefile](Documentation/Deploy_EdgeLake.md)) - Using [_Makefile_](Makefile), install EdgeLake via _Open Horizon policy_ or _docker-compose_
* [EdgeLake_KubeArmor_integration.md](Documentation/EdgeLake_KubeArmor_integration.md) - Accepting KubeArmor data into EdgeLake
* [Import_Grafana_Dashboards.md](Documentation/Import_Grafana_Dashboards.md) - Importing KubeArmor related gauges into Grafana 

# General Configuration of Network

A basic network setup consists of a _master_, 2 _operator_  and _query_ node - as shown in the image below. These nodes 
can be deployed either on the same physical machine, or unique machines.

![Demo Diagram](imgs/deployment_diagram.png)


 