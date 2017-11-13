# pod

## About 'pod'

**pod** is about automating tasks over many machines.    
It is written in bash because sometimes thats all you can use in locked down environments (banking).    
Tested on Mac, Ubuntu and Centos.    
   
It is extensible and new modules (or 'pods') can be added quickly that make use of pod's core capabilities.  
Its first 'pod' makes it easy to set up and run a DSE cluster from **tarballs**.  
- **pod_dse**:    
    - setup, configure and distribute dse + java (optional) software to all servers in a cluster.    
    - perform rolling starts and stops.            

Other dse specific pods are in the pipeline:    
- **pod_dse_security**    
    - to automate configuration of files concerned with cluster encryption.    
- **pod_dse_opscenter**    
    - to automate the setup, configuration and encryption of opscenter/agents.    

## Versioning 'pod'

To update to the latest version when on 'master' branch.      
`
$ git pull                            
`    
To change to a different version.    
`    
$ git checkout -b <pod-version-x.x>     
`    
The master branch is always kept in sync with the latest stable branch of pod.   

**The latest stable version is:** 
```diff
+ **pod-version-1.0**
```

## About 'pod_dse'  

With **'pod_dse'** you can easily create and manage multiple cluster setups (different versions/settings).     
You can deploy these different configurations to the same machines and they will not interfere with each other.  
As such **pod_dse** is very useful in development / testing environments as well as in production if opscenter is not an option.  

**Features:**    
- **available:** by using tarballs, pod does **not require root privileges** to setup a dse cluster.    
- **flexible:** can install a dse cluster locally and/or on remote machines (or span both).     
- **complete:** will distribute, untar and configure all software sent to each server.    
- **speed:** 0-cluster in minutes !!
- **simple:** settings are defined in just **two** configuration files.    
    -  one for cluster-wide settings.    
    -  one for server level settings.    
- **control:** all dse settings and installation paths may be configured.     

Out of the box - pod creates a desktop folder with all configured software, data and log folders all conveniently in one place.  
    
## Get started with 'pod_dse'   

Quick Instructions (to work out of the box):  

1) Setup passwordless access to all servers (including local machine).    
`
$ ssh keygen -t rsa   # hit enter to all questions
`    

The above step is required if you do not already have a local key setup.    

`
$ ssh-copy-id user@remote-machine
`    

This will send your key to the remote server to enable passwordless authentication.    

2) git clone https://github.com/jondowson/pod  

For Macs (both running pod and in a cluster) - you will need first run the dependencies script from the root folder of the repo.  
`  
$ ./misc/dependencies_mac.sh
`     

3) Make a folder on your desktop called '**DSE_SOFTWARE**'.  
4) Add the following folder structure and tar files (add multiple versions per folder if you like).

- **DSE_SOFTWARE**  
  - **packages**  
    - **dse**
      - dse-5.x.x-bin.tar.gz  
    - **oracle-java**  
      - jdk-8uxxx-linux-i586.tar.gz
    - opscenter    
      - opscenter-6.x.x.tar.gz    
    - datastax-agent    
      - datastax-agent-6.x.x.tar.gz     

Opscenter and agent software is not setup by pod_dse but inclusion will ensure their tarballs are distributed to each server.     
Check online datastax documents to ensure usage of compatible versions.      

5) Duplicate **builds/pod_dse/dse-5.x.x_template**, rename it and then review/edit its '**cluster_settings.sh**' file.    
`   
$ cp -r builds/pod_dse/dse-5.x.x_template  builds/pod_dse/dse-5.x.x_nameIt  
`     
`   
$ vi builds/pod_dse/dse-5.x.x_nameIt/cluster_settings.sh    
`   

Rename the template file in line with the dse version you intend to use.    
The '**cluster_settings.sh**' file captures cluster-wide settings such as cluster name and write paths for logs/data.    


6) Duplicate a servers template **.json** file, rename and edit it.  
`   
$ cp servers/template_x.json  servers/nameIt.json  
`   
`   
$ vi servers/nameIt.json    
`        

The **.json** defintion file captures server specific settings such as login credentials and ip addresses.    
    
7) For help run '**launch-pod**' passing '**-h**' or '**--help**'.  
`   
$ ./launch-pod --help    
`       
    
8) Finally run '**launch-pod**' passing in the required parameters.  
`   
$ ./launch-pod --pod pod_dse --servers nameIt.json --build dse-x.x.x_nameIt    
`   

**Note:**    
When you first run pod, it will look in your specified builds folder to see if there is a '**resources**' folder.    
If there is not, it will untar your choosen dse version tarball and copy its resourcs folder there.    
This copied folder is stripped of all **non-config files** - the remainder are then available for editing.    

The settings specified in '**cluster_settings.sh**' and the servers '**.json**' will be edited into this copied resources folder.    
But for all the settings they do not cover, you can manually edit any of them.    
So if required, hit **\<ctrl-c\>** at the end of this initial stage - you will have 10 seconds!   
Then edit any dse config file in the build's **resources** folder.    

Re-launch **pod_dse**.    
All servers will receive a bespoke version of the resources folder + all required software.     
A pod-launcher script will be run remotely and finish the server configuration.  
You can then perform a rolling start of the cluster - see help for example.    
        
