
### Changes in pod-version-1.5.1

**1) pod_dependencies.sh**

+ convenient 'fpod' alias added to bash_profile to cd into pod folder  
+ this is available on all servers in the cluster

### Arriving in pod-version-1.5.2

**1) pod_DSE**

+ update/config/restart datastax-agents independently of dse

**2) pod_REMOVE-PODS**

+ flag to remove a specific build from a pod

**3) pod_DSE-SECURITY**

+ NEW POD !!!!    
+ turn on/off audit logging
+ configure LDAP authorisation
+ encryption:
    ssl, tde, agents-opscenter, LDAP, client-server

**4) pod_DSE-OPSCENTER**

+ block in cassandra-env.sh to force opscenter cluster to be used for metric storage
