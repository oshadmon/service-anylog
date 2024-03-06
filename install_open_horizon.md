# Policy Based Deployment 


* [Quick Start](https://open-horizon.github.io/quick-start/)
* Based on [Grafana Service](https://github.com/open-horizon-services/service-grafana)


## Prerequisites
* **Management Hub:** [Install the Open Horizon Management Hub](https://open-horizon.github.io/quick-start) or have access to an existing hub in order to publish this service and register your edge node.  You may also choose to use a downstream commercial distribution based on Open Horizon, such as IBM's Edge Application Manager.  If you'd like to use the Open Horizon community hub, you may [apply for a temporary account](https://wiki.lfedge.org/display/LE/Open+Horizon+Management+Hub+Developer+Instance) and have credentials sent to you.

* **Edge Node:** You will need an x86 computer running Linux or macOS, or a Raspberry Pi computer (arm64) running Raspberry Pi OS or Ubuntu to install and use Grafana deployed by Open Horizon.  You will need to install the Open Horizon agent software, anax, on the edge node and register it with a hub.

* **Optional utilities to install:**  With `brew` on macOS (you may need to install _that_ as well), `apt-get` on Ubuntu or Raspberry Pi OS, `yum` on Fedora, install `gcc`, `make`, `git`, `jq`, `curl`, `net-tools`.  Not all of those may exist on all platforms, and some may already be installed.  But reflexively installing those has proven helpful in having the right tools available when you need them.


## Install Open-Horizon 

1. Export following params - I tend to store the params as part of `~/.bashrc`, that way when the node
reboots the environment variables still exist 
```shell
export HZN_ORG_ID=[ORG_ID]
export HZN_EXCHANGE_USER_AUTH=[USER_AUTH]
export HZN_EXCHANGE_URL=[EXCHANGE_URL]
export HZN_FSS_CSSURL=[FSS_CSSURL]
```

2. Download the installation agent & provide admin permissions
```shell
curl -u "${HZN_ORG_ID}/${HZN_EXCHANGE_USER_AUTH}" -k -o agent-install.sh ${HZN_FSS_CSSURL}/api/v1/objects/IBM/agent_files/agent-install.sh/data
chmod +x agent-install.sh
```

3. Confirm _hzn_ is installed 
**Command**
```shell
hzn version
```

**Output**
```shell
Horizon CLI version: 2.30.0-1435
Horizon Agent version: 2.30.0-1435
```

3. Test agent is installed by deploying _IBM/pattern-ibm.helloworld_
**Command**
```shell
sudo -s -E ./agent-install.sh -i 'css:' -p IBM/pattern-ibm.helloworld -w '*' -T 120
```
**Output**
```shell
...
Waiting for up to 120 seconds for following services to start:
        IBM/ibm.helloworld
Status of the services you are watching:
        IBM/ibm.helloworld      Progress so far: no agreements formed yet
Status of the services you are watching:
        IBM/ibm.helloworld      Progress so far: no agreements formed yet
Status of the services you are watching:
        IBM/ibm.helloworld      Progress so far: agreement proposal has been received
Status of the services you are watching:
        IBM/ibm.helloworld      Progress so far: agreement is finalized
Status of the services you are watching:
        IBM/ibm.helloworld      Progress so far: execution is started
Status of the services you are watching:
        IBM/ibm.helloworld      Success
```

4. Check node is running
**Command**
```shell
hzn eventlog list -f
```
**Output**
```shell
  "2024-03-06 00:37:03:   Start node configuration/registration for node test-node.",
  "2024-03-06 00:37:04:   Start service auto configuration for IBM/ibm.helloworld.",
  "2024-03-06 00:37:04:   Complete service auto configuration for IBM/ibm.helloworld.",
  "2024-03-06 00:37:04:   Complete node configuration/registration for node test-node.",
  "2024-03-06 00:37:04:   Start policy advertising with the Exchange for service IBM/ibm.helloworld.",
  "2024-03-06 00:37:05:   Complete policy advertising with the Exchange for service IBM/ibm.helloworld.",
  "2024-03-06 00:37:47:   Node received Proposal message using agreement c577e4956773624647aaca2e32e3f1fafa96107dedfe7f00e0463b3f44265705 for service IBM/ibm.helloworld from the agbot IBM/agbot.",
  "2024-03-06 00:37:47:   Node received Proposal message using agreement 7b258ca1a6824322d20ac0d5e15e54d7ccfe9dc86486ed1ef6cc562bf93aff3b for service IBM/ibm.helloworld from the agbot IBM/agbot.",
  "2024-03-06 00:37:47:   Agreement c577e4956773624647aaca2e32e3f1fafa96107dedfe7f00e0463b3f44265705 already exists, ignoring proposal: ibm.helloworld",
  "2024-03-06 00:37:57:   Agreement reached for service ibm.helloworld. The agreement id is c577e4956773624647aaca2e32e3f1fafa96107dedfe7f00e0463b3f44265705.",
  "2024-03-06 00:37:57:   Start dependent services for IBM/ibm.helloworld.",
  "2024-03-06 00:37:57:   Start workload service for IBM/ibm.helloworld.",
  "2024-03-06 00:37:58:   Image loaded for IBM/ibm.helloworld.",
  "2024-03-06 00:37:59:   Workload service containers for IBM/ibm.helloworld are up and running."
```

5. Unregister _IBM/pattern-ibm.helloworld_
```shell
hzn unregister -f
```

