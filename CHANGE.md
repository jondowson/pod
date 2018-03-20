
### pod-version-1.5.1 - 20/03/18

**1) pod_dependencies.sh**

+ convenient 'fpod' alias added to bash_profile to cd into pod folder  

**2) pod_DSE**

+ update/config/restart datastax-agents independently of dse

**3) pod_REMOVE-PODS**

+ flag to remove a specific build from a pod

**4) pod_DSE-SECURITY**

+ NEW POD !!!!    
+ turn on/off audit logging
+ configure LDAP authorisation
+ encryption:
    ssl, tde, agents-opscenter, LDAP, client-server

**5) pod_DSE-OPSCENTER**

+ block in cassandra-env.sh to force opscenter cluster to be used for metric storage
