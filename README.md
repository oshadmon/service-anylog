![AnyLog Logo](imgs/anylog_logo.png)
# AnyLog Service for  OpenHorizon  

* [AnyLog Documentation](https://github.com/AnyLog-co/documentation)

* [Open Horizon Deployment](Open%20Horizon.md) - How to deploy AnyLog with Open Horizon

* [Deployment Scripts](https://github.com/AnyLog-co/deployment-scripts) - AnyLog code used to configure different types 
of AnyLog nodes. 

* [Deployments Package](https://github.com/AnyLog-co/deployments) - Tool to deploy AnyLog with either _Docker_ or _Kubernetes_
  * [anylog-generic](anylog-generic/) - docker-compose file(s) to deploy an AnyLog instance. Users should update values  
  in [anylog_configs.env](anylog-generic/anylog_configs.env), as well as [.env](anylog-generic/.env), if deploying 
  multiple nodes on the same physical machine.
  
* Sample [Dockerfile](sample-docker/Dockerfile) - Dockerfile that uses AnyLog as a base image, and start an empty node


# General Configuration of Network

A basic network setup consists of a _master_, 2 _operator_  and _query_ node - as shown in the image below. These nodes 
can be deployed either on the same physical machine, or unique machines. Directions for [Quick Deployment](https://github.com/AnyLog-co/documentation/blob/master/deployments/Quick%20Deployment.md)
of the diagram. 

![Demo Diagram](imgs/deployment_diagram.png)

