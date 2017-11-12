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

## About 'pod_dse'  

With **'pod_dse'** you can easily create and manage multiple cluster setups (different versions/settings).     
You can deploy these different configurations to the same machines and they will not interfere with each other.  
As such pod is very useful in development/testing environments as well as in production when opscenter is not an option.  

**Features:**    
- flexible: ---> can install a dse cluster locally and/or on remote machines (or span both).     
- complete: ---> will distribute, untar and configure all software sent to each server.    
- simple:   ---> settings are defined in just **two** configuration files.    
    -  one for cluster-wide settings.    
    -  one for server level settings.    

Out of the box - pod creates a desktop folder with all configured software, data and log folders all conveniently in one place.  
    
**Note:**     
By using tarballs, pod does **not require root privileges** to setup a dse cluster.    
Root access is, however, required when using opscenter, package installs or the dse-installer to setup a dse cluster.             

## Get started with 'pod_dse'   

Quick Instructions (to work out of the box):  

1) git clone https://github.com/jondowson/pod  

For Macs (both running pod and in a cluster) - you will need first run the dependencies script from the root folder of the repo.  
`  
$ ./misc/dependencies_mac.sh
`     

2) Make a folder on your desktop called '**DSE_SOFTWARE**'.  
3) Add the following folder structure and tar files (add multiple versions per folder if you like).

- DSE_SOFTWARE  
  - packages  
    - dse
      - dse-5.x.x-bin.tar.gz  
    - oracle-java  
      - jdk-8uxxx-linux-i586.tar.gz
    - opscenter    
      - opscenter-6.x.x.tar.gz    
    - datastax-agent    
      - datastax-agent-6.x.x.tar.gz     

Opscenter and agent software is not setup by pod_dse but inclusion will ensure their tarballs are distributed to each server.     
Check online datastax documents to ensure usage of compatible versions.      

4) Duplicate **builds/pod_dse/dse-5.x.x_template**, rename it and then review/edit its '**cluster_settings.sh**' file.    
`
$ cp -r builds/pod_dse/dse-5.x.x_template  builds/pod_dse/dse-5.x.x_nameIt  
`  
`
$ vi builds/pod_dse/dse-5.x.x_nameIt/cluster_settings.sh    
`   

Rename the template file in line with the dse version you intend to use.    
The '**cluster_settings.sh**' file captures cluster-wide settings such as cluster name and write paths for logs/data.    


5) Duplicate a servers template **.json** file, rename and edit it.  
`
$ cp servers/template_x.json  servers/nameIt.json  
`  
`
$ vi servers/nameIt.json    
`     

The **.json** defintion file captures server specific settings such as login credentials and ip addresses.    
    
6) For help run '**launch-pod**' passing '**-h**' or '**--help**'.  
`
$ ./launch-pod --help    
`    
    
7) Finally run '**launch-pod**' passing in the required parameters.  
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
Then edit any dse config file in the build's resources folder.    

Re-launch **pod_dse**.    
All servers will receive a bespoke version of the resources folder + all required software.     
A pod-launcher script will be run remotely and finish the server configuration.    
   
