# Data Generator 

Remote CLI: http://45.79.92.25:31800/  

**Notes**: 
1. we separated the content in [azure-k8s][azure-k8s-cluster-telemetry.json](azure-k8s-cluster-telemetry.json) into 2 tables 
2. I added the following rows to the JSON file, that way _host_list_ has the same hostnames as _kubearmor_
```json
{"ClusterName": "default", "HostName": "aks-agentpool-84859103-vmss000000", "PPID": 0, "UID": 0}
{"ClusterName": "default", "HostName": "aks-agentpool-84859103-vmss000001", "PPID": 0, "UID": 0}
```

## Setup Directions 
The following steps are done on the _Operator_ node unless stated otherwise

1. Start AnyLog - directions can be found iin [Open Horizon](../Open%20Horizon.md)

2. locate `anylog-operator_anylog-operator-local-scripts`
```shell
ubuntu@anylog-operator:~/deployments/docker-compose/anylog-operator$ docker volume ls 
DRIVER    VOLUME NAME
local     anylog-operator_anylog-operator-anylog
local     anylog-operator_anylog-operator-blockchain
local     anylog-operator_anylog-operator-data
local     anylog-operator_anylog-operator-local-scripts
```

3. Inspect volume 
```shell
ubuntu@anylog-operator:~/deployments/docker-compose/anylog-operator$ docker volume inspect anylog-operator_anylog-operator-local-scripts 
[
    {
        "CreatedAt": "2023-11-29T02:01:16Z",
        "Driver": "local",
        "Labels": {
            "com.docker.compose.project": "anylog-operator",
            "com.docker.compose.version": "1.29.2",
            "com.docker.compose.volume": "anylog-operator-local-scripts"
        },
        "Mountpoint": "/var/lib/docker/volumes/anylog-operator_anylog-operator-local-scripts/_data",
        "Name": "anylog-operator_anylog-operator-local-scripts",
        "Options": null,
        "Scope": "local"
    }
]
```

4. Copy [mqtt_policy](mqtt_policy.al) into volume 
```shell
cp -r mqtt_policy.al var/lib/docker/volumes/anylog-operator_anylog-operator-local-scripts/_data/node-deployment/local_script.al
```

5. On the AnyLog side, start MQTT client 
```anylog
process !local_scripts/local_script.al
```

6. Get AnyLog connection information 
```anylog
AL openhorizon-operator1 +> get connections 

Type      External Address      Internal Address      Bind Address  
---------|---------------------|---------------------|-------------|
TCP      |170.187.154.190:32148|170.187.154.190:32148|0.0.0.0:32148|
REST     |170.187.154.190:32149|170.187.154.190:32149|0.0.0.0:32149| <-- we'll be using this address
Messaging|Not declared         |Not declared         |Not declared |
```

7. Run data processing 
```shell
python3 process_data.py --conn 170.187.154.190:32149
```

## Sample Queries 
* columns 
```anylog 
get columns where dbms=openhorizon and table=kubearmor
```

* Summary of data: 
```anylog
# number of rows per timestamp  
sql openhorizon format=table "select increments(second, 1, timestamp), MIN(timestamp), MAX(timestamp), count(*) FROM kubearmor;"

# number of rows per host
sql openhorizon format=table "select hostname, count(*) FROM kubearmor group by hostname;"

# host_list all columns 
sql openhorizon format=table "select * FROM host_list;" 
``` 

* Sections of data 
 ```anylog
sql openhorizon format=table "select timestamp, hostname, cluster_name, namespace from kubearmor;"

sql openhorizon format=table "select timestamp, owner, owner_ref, owner_namespace from kubearmor where hostname='aks-bahnodepool-23812902-vmss000000' ;"
```

* Full data 
```anylog
sql openhorizon format=table "select timestamp, hostname, namespace, owner, owner_ref, owner_namespace, podname, labels, container_id, container_name, container_image, process_name, host_ppid, host_pid, ppid, pid, uid, type, source, resource, operation, data, result from kubearmor where period(second, 1, '2023-12-11 16:46:56.699370', timestamp) order by timestamp"
```

