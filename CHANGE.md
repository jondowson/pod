
### Changes in pod-version-1.5.2

**1) pod_**    

+ pushed more functionality into the generic pod_ framework  

**2) pod_DSE**        

+ removed unused function: lib_doStuff_remotely_agentEnvironment    

**3) pod_DSE-OPSCENTER**

+ block in cassandra-env.sh to force opscenter cluster to be used for metric storage    


### Roadmap

**1) pod_DSE**   

+ update/config/restart datastax-agents independently of dse    
+ add option for swagger UI to build_settings.bash (address.yaml)    

**2) pod_REMOVE-PODS**    

+ flag to remove a specific build from a pod

**3) pod_DSE-SECURITY**    

+ NEW POD !!!!    
+ turn on/off audit logging
+ configure LDAP authorisation
+ encryption:
    ssl, tde, agents-opscenter, LDAP, client-server
