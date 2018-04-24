
### Changes in pod-version-1.5.3

**1) pod_**    

+ pushed more functionality into the generic pod_ framework  

**2) pod_DSE**        

+ update/config/restart datastax-agents independently of dse
+ now works with dse 6.0      

**3) pod_DSE-OPSCENTER**

+ block in cassandra-env.sh to force opscenter cluster to be used for metric storage    
+ tested to work with opscenter 6.5.0

**3) General**    

+ tidy up of code comments    
+ improved screen messages    
+ move write test variables into build_settings.bash for easier handling   
+ added some generic handy flags for use by any pod

### Roadmap

**1) pod_DSE**   

+ add option for agent swagger UI to build_settings.bash (address.yaml)    

**2) pod_REMOVE-PODS**    

+ flag to remove a specific build from a pod

**3) pod_DSE-SECURITY**    

+ NEW POD !!!!    
+ turn on/off audit logging
+ configure LDAP authorisation
+ encryption:
    ssl, tde, agents-opscenter, LDAP, client-server
