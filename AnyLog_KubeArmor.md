# Kubearmor with AnyLog

AnyLog comes pre-configured with the protocol file for Kubearmor

**Steps**:
1. Make sure to have [grpc](https://pypi.org/project/grpcio/) and [grpc-tools](https://pypi.org/project/grpcio-tools/) installed locally
```shell
sudo python3 -m pip install grpcio
sudo python3 -m pip install grpcio-tools
```

2. 
   * [Deploy AnyLog](Open%20Horizon.md) 
   * [Deploy Kubearmor](https://docs.kubearmor.io/kubearmor/quick-links/deployment_guide) with proxy
```shell
# proxy command 
kubectl port-forward --address ${INTERNAL_IP} service/kubearmor 32769:32767 -n kubearmor
```

3. Locate the AnyLog volume for local-scripts
```shell
moshe@anylog-gcp-publisher:~$ docker volume ls 
DRIVER    VOLUME NAME
local     anylog-publisher_anylog-publisher-anylog
local     anylog-publisher_anylog-publisher-blockchain
local     anylog-publisher_anylog-publisher-data
local     anylog-publisher_anylog-publisher-local-scripts
local     minikube
moshe@anylog-gcp-publisher:~$ docker inspect anylog-publisher_anylog-publisher-local-scripts
[
    {
        "CreatedAt": "2024-01-19T23:11:12Z",
        "Driver": "local",
        "Labels": {
            "com.docker.compose.project": "anylog-publisher",
            "com.docker.compose.version": "2.17.2",
            "com.docker.compose.volume": "anylog-publisher-local-scripts"
        },
        "Mountpoint": "/var/snap/docker/common/var-lib-docker/volumes/anylog-publisher_anylog-publisher-local-scripts/_data",
        "Name": "anylog-publisher_anylog-publisher-local-scripts",
        "Options": null,
        "Scope": "local"
    }
]
```

4. Locate _gRPC_ file(s) 
```shell
moshe@anylog-gcp-publisher:~$ sudo ls -l /var/snap/docker/common/var-lib-docker/volumes/anylog-publisher_anylog-publisher-local-scripts/_data/grpc/
total 20
-rw-r--r-- 1 root root 1576 Jan 19 04:58 README.md
-rw-r--r-- 1 root root  920 Jan 19 04:58 compile.py
-rw-r--r-- 1 root root 5289 Jan 19 04:58 dummy_kube_server.py
drwxr-xr-x 2 root root 4096 Jan 21 01:34 kubearmor
moshe@anylog-gcp-publisher:~$ sudo ls -l /var/snap/docker/common/var-lib-docker/volumes/anylog-publisher_anylog-publisher-local-scripts/_data/grpc/kubearmor
total 48
-rw-r--r-- 1 root root     0 Jan 19 04:58 __init__.py
-rw-r--r-- 1 root root  1083 Jan 19 04:58 deploy_kubearmor_healthcheck.al
-rw-r--r-- 1 root root  1354 Jan 21 01:34 deploy_kubearmor_system.al
-rw-r--r-- 1 root root  1519 Jan 19 04:58 grpc_client.al
-rw-r--r-- 1 root root  2566 Jan 19 04:58 kubearmor.proto
-rw-r--r-- 1 root root  6356 Jan 19 04:58 kubearmor_system_policy.al
```

5. Compile protocol file 
```shell
sudo python3 /var/snap/docker/common/var-lib-docker/volumes/anylog-publisher_anylog-publisher-local-scripts/_data/grpc/compile.py /var/snap/docker/common/var-lib-docker/volumes/anylog-publisher_anylog-publisher-local-scripts/_data/grpc/kubearmor/kubearmor.proto
```
6. Update `deploy_kubearmor_system.al` file 
```anylog
#-----------------------------------------------------------------------------------------------------------------------
# Deploy process to accept data from KubeArmor
# Steps:
#   1. Compile proto file
#   2. Set params
#   3. Declare Policy
#   4. gRPC client
#-----------------------------------------------------------------------------------------------------------------------
# process $ANYLOG_PATH/deployment-scripts/grpc/kubearmor/deploy_kubearmor_system.al
on error ignore

# Compile proto file
#:compile-proto:
# on error goto compile-error
# compile proto where protocol_file=$ANYLOG_PATH/deployment-scripts/grpc/kubearmor/kubearmor/kubearmor.proto

# Set Params
:set-params:
grpc_name = system1
grpc_client_ip = 10.128.0.8 # <-- Update value 
grpc_client_port = 32769 # <-- update value 
grpc_dir = $ANYLOG_PATH/deployment-scripts/grpc/kubearmor/
grpc_proto = kubearmor
grpc_function = WatchLogs
grpc_request = RequestMessage
grpc_response = Log
grpc_service = LogService
grpc_value = (Filter = all)
grpc_limit = 0
set grpc_ingest = true
set grpc_debug = false

set alert_flag_1 = false
set alert_level = 0
ingestion_alerts = ''

table_name = bring [Operation]
set default_dbms = kubearmor

:declare-policy:
process $ANYLOG_PATH/deployment-scripts/grpc/kubearmor/kubearmor_system_policy.al


:run-grpc-client:
process $ANYLOG_PATH/deployment-scripts/grpc/kubearmor/grpc_client.al
```

7. On the AnyLog side deploy process to accept data from Kubearmor 
```anylog
AL anylog-gcp-publisher > process $ANYLOG_PATH/deployment-scripts/grpc/kubearmor/deploy_kubearmor_system.al

# to view data 
AL anylog-gcp-publisher +> get grpc client 

Name (ID) Status Connection       Proto Name Request Msg    Policy Type Policy Name Policy ID               Data Msgs Timeouts Error 
---------|------|----------------|----------|--------------|-----------|-----------|-----------------------|---------|--------|-----|
system1  |Active|10.128.0.8:32769|kubearmor |RequestMessage|mapping    |system1    |kubearmor-system-policy|        0|       0|     |

```