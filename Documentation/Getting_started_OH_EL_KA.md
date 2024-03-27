# Getting Started - Install EdgeLake (with Open Horizon) to manage KubeArmor events

## Overview
KubeArmor analyzes telemetry data to understand application behavior for container/node forensics. 
With thousands of nodes deployed (using Open Horizon), sending events streams to a centralized node is not a viable option.   

This document details an installation of EdgeLake instances to manage the KubeArmor's event data to extract real time 
insight from the data, enable real-time alerts and monitoring and service the data to analysis and AI applications, 
all of that without cloud contracts and costs.

An overview of the deployment is with the following link: [AnyLog - KubeArmor Integration](https://wiki.lfedge.org/display/OH/AnyLog+-+KubeArmor+Integration).  
Notes:
1) EdgeLake is the Open-Source release of the AnyLog Edge Software Platform.  
2) Below are the links to the technical documentation of the platform.
3) The setup EdgeLake-KubeArmor setup is using the EdgeLake code base regardless if the documentation or scripts reference AnyLog.

## AnyLog Documentation
This document guides through the deployment process. For a detailed technical understanding and training, please review the 
resources provided in this section.

* [Install Presentation](https://www.youtube.com/watch?v=mQS_VwQMYJc)
* [Product Documentation](https://github.com/AnyLog-co/documentation/blob/master/README.md)
* [Getting Started Document](https://github.com/AnyLog-co/documentation/blob/master/getting%20started.md)
* [Prerequisites](https://github.com/AnyLog-co/documentation/blob/master/training/prerequisite.md)
* [Training Documentation](https://github.com/AnyLog-co/documentation/blob/master/training/Overview.md)  
    ○ [Session I](https://github.com/AnyLog-co/documentation/blob/master/training/Session%20I%20(Demo).md)  
    ○ [Session II](https://github.com/AnyLog-co/documentation/blob/master/training/Session%20II%20(Deployment).md)  
    ○ [Fast Deployment (Cheatsheet)](https://github.com/AnyLog-co/documentation/blob/master/training/Fast%20Deployment.md)

## Deployment setup

The setup includes the following instances:
* Deploy KubeArmor instances to monitor events on pods, containers, and virtual machines.
* Deploy an EdgeLake Network with the following components:
    * One or more **Operator Nodes**. These nodes host the KubeArmor generated data.
    * One or more **Query Nodes**. These nodes service the KubeArmor data to applications that need the data.
    * One **Master Node**. The Master Node hosts the shared metadata. 

Note:  
Data is transferred between KubeArmor and an EdgeLake Node using a gRPC connector. Details on the EdgeLake 
gRPC connector are available [here](https://medium.com/anylog-network/the-anylog-grpc-service-f02ec3bd8a6a).
   
## Deployment Instructions

Use the same process to deploy each type of node as explained in section 
[Deploy via OpenHorizon Patterns](Deploy_EdgeLake.md#deploy-via-open-horizon-patterns),
however, use the node type as detailed below:

### Deploy an EdgeLake Master Node 

**One Master Node for each EdgeLake Network.**  
For Steps 2-5 use **EDGELAKE_TYPE=master**

### Deploy an EdgeLake Query Node
**A Query Node can service multiple applications, multiple nodes are deployed to reduce the load.**  
For Steps 2-5 use **EDGELAKE_TYPE=query** (for each Query Node deployed).

### Deploy an EdgeLake Operator Node
**Multiple Operator Nodes host KuberArmor generated data. A single Operator Node can service multiple KubeArmor instances.**
For Steps 2-5 use **EDGELAKE_TYPE=operator** (for each Operator Node deployed).




