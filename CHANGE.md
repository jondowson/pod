
### Changes in pod-version-1.5.4

**1) pod_**    

+ pushed more functionality into the generic pod_ framework   
+ defined rules for varaible declaration:    
  + all user defined variables in json + build_settings are lower case, seperated by underscore     
  + all non user defined variables are upper case (paths)    
  + all other funtion variables are lowerCamelCase

**2) pod_DSE**        

+ updated status messages when running pod to be more accurate   
+ now works with dse 5.0, 5.1 + 6.0            

**3) pod_DSE-OPSCENTER**

+ updated status messages when running pod to be more accurate   

**3) General**    

+ tidy up of code comments    
+ improved screen messages    

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
