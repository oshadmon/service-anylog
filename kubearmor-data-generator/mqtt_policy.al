<run mqtt client where broker=rest and port=!anylog_rest_port and user-agent=anylog and log=false and topic=(
    name=aks and
    dbms=openhorizon and
    table=kubearmor and
    column.timestamp.timestamp="bring [UpdatedTime]" and
    column.cluster_name=(type=str and value="bring [ClusterName]") and
    column.hostname=(type=str and value="bring [HostName]") and
    column.namespace=(type=str and value="bring [NamespaceName]") and
    column.owner=(type=str and value="bring [Owner][Name]" and optional=true) and
    column.owner_ref=(type=str and value="bring [Owner][Ref]" and optional=true) and
    column.owner_namespace=(type=str and value="bring [Owner][Namespace]" and optional=true) and
    column.podname=(type=str and value="bring [PodName]" and optional=true) and
    column.labels=(type=str and value="bring [Labels]" and optional=true) and
    column.container_id=(type=str and value="bring [ContainerID]" and optional=true) and
    column.container_name=(type=str and value="bring [ContainerName]" and optional=true) and
    column.container_image=(type=str and value="bring [ContainerImage]" and optional=true) and
    column.parent_process_name=(type=str and value="bring [ParentProcessName]" and optional=true) and
    column.process_name=(type=str and value="bring [ProcessName]" and optional=true) and
    column.host_ppid=(type=str and value="bring [HostPPID]" and optional=true) and
    column.host_pid=(type=str and value="bring [HostPID]" and optional=true) and
    column.ppid=(type=str and value="bring [PPID]" and optional=true) and
    column.pid=(type=str and value="bring [PID]" and optional=true) and
    column.uid=(type=str and value="bring [UID]" and optional=true) and
    column.type=(type=str and value="bring [Type]" and optional=true) and
    column.source=(type=str and value="bring [Source]" and optional=true) and
    column.resource=(type=str and value="bring [Resource]" and optional=true) and
    column.operation=(type=str and value="bring [Operation]" and optional=true) and
    column.data=(type=str and value="bring [Data]" and optional=true) and
    column.result=(type=str and value="bring [Result]" and optional=true)
)>