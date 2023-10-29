# Open Horizon 

Open Horizon is a platform for managing the service software lifecycle of containerized workloads and related machine 
learning assets. It enables autonomous management of applications deployed to distributed web scale fleets of edge 
computing nodes and devices without requiring on-premise administrators.

Open Horizon can be used to easily manage and deploy AnyLog node(s) through their interface.
* [Open Horizon Website](https://www.lfedge.org/projects/openhorizon/)
* [IBM Documentation for Open Horizon](https://developer.ibm.com/components/open-horizon/)
* [Open Source Documentation](https://open-horizon.github.io/)
* [AnyLog Documentation](https://github.com/AnyLog-co/documentation)
* [AnyLog Website](https://anylog.co)


## Associating Machine to Open Horizon
The following steps will associate a new machine with the Open Horizon management platform. The process will complete the 
following:  
* [Create an API key](https://www.ibm.com/docs/en/eam/4.3?topic=installation-creating-your-api-key) 
* [Install Horizon CLI](https://www.ibm.com/docs/en/eam/4.1?topic=cli-installing-hzn) 
* [Install Docker](https://docs.docker.com/engine/install/) 
* Validate Open Horizon is working by deploying an _Hello World_ package

1. On the node Update / Upgrade Node
```shell
# Debian / Ubuntu 
for CMD in update upgrade ; do sudo apt-get -y ${CMD} ; done

# Redhat / CentOS 
for CMD in update upgrade ; do sudo yum -y ${CMD} ; done

# Fedora
for CMD in update upgrade ; do sudo dnf -y ${CMD} ; done


# Alpine 
sudo apk update && sudo apk upgrade
```

2. Create an Open Horizon [API Key](https://www.ibm.com/docs/en/eam/4.3?topic=installation-creating-your-api-key)

3. Update Environment variables
   * In `~/.bashrc` (or `~/.profile` for Alpine) add the following variables
```shell
export HZN_ORG_ID=<COMPANY_NAME> 
export HZN_EXCHANGE_USER_AUTH="iamapikey:<API_KEY>"
export HZN_EXCHANGE_URL=<HZN_EXCHANGE_URL>
export HZN_FSS_CSSURL=<HZN_FSS_CSSURL> 
```
   * Set Environment variables
```shell
# For non-Alpine operating systems 
source ~/.bashrc 

# For Alpine operating systems 
source ~/.profile 
```

4. Install agent and provide admin privileges
```shell
curl -u "${HZN_ORG_ID}/${HZN_EXCHANGE_USER_AUTH}" -k -o agent-install.sh ${HZN_FSS_CSSURL}/api/v1/objects/IBM/agent_files/agent-install.sh/data

chmod +x agent-install.sh

sudo -s -E ./agent-install.sh -i 'css:' -p IBM/pattern-ibm.helloworld -w '*' -T 120
```

5. Validate helloworld sample edge service is running
```shell
hzn eventlog list -f

<<COMMENT  
"2022-06-13 21:27:13:   Workload service containers for IBM/ibm.helloworld are up and running."
<<COMMENT
```

6. Docker is already installed via HZN, however needs permissions to use not as root
```shell
USER=`whoami` 
sudo groupadd docker 
sudo usermod -aG docker ${USER} 
newgrp docker
```

At the end of the process, OpenHorizon should show a new active node
![OpenHorizon_node_state.png](imgs%2FOpenHorizon_node_state.png)

