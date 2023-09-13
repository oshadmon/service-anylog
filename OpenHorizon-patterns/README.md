# Deploy AnyLog Pattern 

Directions for deploying an AnyLog pattern using Open Horizon. We've already created _generic_ configuration files per 
node type. 

* [master](master)
* [query](query)
* [operator](operator)

## General steps for deploying via Pattern  
1. Update configurations values for service.definition.json
   * org          
   * url
   * Under userInput
     * LICENSE_KEY      
     * NODE_TYPE       
     * NODE_NAME       
     * COMPANY_NAME     
     * ANYLOG_SERVER_PORT  
     * ANYLOG_REST_PORT   
     * ANYLOG_REST_PORT   
     * MONITOR_NODE_COMPANY  

2. Publisher service definition 
```shell
hzn exchange service publish -P -r "docker.io:anyloguser:dckr_pat_zThA7XRQ_a-9J8_OKculQM9kYrw" -f service.definition.json
```

3. Update configuration vaules for deployment.policy.json

4. Add deployment policy 
```shell
hzn exchange deployment addpolicy -f deployment.policy.json ${ORG}/anylog-node_0.1.0_amd64​
```

5. node.policy.json contains a property value of anylog.master == true (again just our arbitrary string value) so once 
you issue the register command the anylog-node​ service will be deployed to it, assuming you have created the 
deployment policy before registering the node ... but you can add the userinput.json file in order to tweak the 
environment variables to make it an query node or operator node. You'll notice I only modified NODE_TYPE, NODE_NAME and 
CLUSTER_NAME so you may need to add the correct ANYLOG_SERVER_PORT and ANYLOG_REST_PORT values assuming I understood your 
previous message correctly. Register your edge node with the given node policy with this command:
```shell
hzn register --policy node.policy.json --input-file=userinput.json
```
   