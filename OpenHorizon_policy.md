# OpenHorizon Policy Deployment

OpenHorizon Policy-based deployment allows to use aa blueprint paattern to deploy a service via terminal.

* [Install OpenHorizon](OpenHorizon_install.md)
* [Deploy via Edge Service](OpenHorizon_EdgeService.md)

## Deploy AnyLog

By deploying AnyLog, users can monitor Distributed Edge Nodes and Data from a single point, without centralizing the data.

1. Clone repository 
```shell
git clone https://github.com/open-horizon-services/service-anylog
```

2. Log into AnyLog repository
```shell
docker login -u anyloguser -p dckr_pat_zcjxcPOKvHkOZMuLY6UOuCs5jUc
```

3. Export needed params
```shell
export SERVICE_VERSION=1.3.2403
```

3. Update values in [service.definition.json](policy_deployment%2Fservice.definition.json)
   * LEDGER_CONN 
   * NODE_NAME 
   * COMPANY_NAME
   * NODE_TYPE
   * For operator - CLUSTER_NAME and DEFAULT_DBMS
   
4. Publish service to exchange 
```shell
hzn exchange service publish -P -r "docker.io:anyloguser:dckr_pat_zcjxcPOKvHkOZMuLY6UOuCs5jUc" -f service.definition.json
```

5. Add deployment policy 
```shell
hzn exchange deployment addpolicy -f deployment.policy.json anylog/anylog-node
```

6. Register policy
```shell
hzn register --policy node.policy.json
```

7. Track workload agreement negotiation
```shell
[watch] hzn agreement list
```
