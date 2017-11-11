# pod

## What?
A bash application to rapidly setup and configure a dse cluster.  
Tested on Mac, Ubuntu and Centos.   
A work in progress !!  

## About?
pod is about performing tasks over many machines.    
It is written in bash because sometimes thats all you can use in locked down environments (banking).    
Effort has been made to make pod as extensible as possible with new modules (or 'pods') planned.  
Its first two pods are specific to setting up and running a DSE cluster from tarballs.  
- pod_dse:                   setup, configure, distribute software to all servers in a cluster.  
- pod_dse_rollingStartStop:  start and stop a dse cluster gracefully.   

Other dse specific pods in the pipeline:    
- pod_dse_security  - to automate configuration of files concerned with cluster encryption.    
- pod_dse_opscenter - to automate the setup, configuration and encryption of opscenter/agents.    

## About pod_dse  

With 'pod_dse' you can easily create and manage multiple cluster setups (different versions/settings).  
You can deploy these different configurations to the same machines and they will not interfere with each other.  
As such pod is very useful in development/testing environments as well as setting up dse in production when opscenter is not an option.  

Pod will distribute, untar and configure all software sent to each server as per two configuration files.    
Out of the box - this will create a folder on your desktop with the unpacked software, data and log folders all in one place.  
Note: you have control over where data,logs and folders are put by editing its two configuration files.    

## Get started with 'pod_dse'   

Quick Instructions (to work out of the box):  

1) git clone https://github.com/jondowson/pod  

For Macs (both running pod and in a cluster) - you will need first run the dependencies script from the root folder of the repo.  
`  
$ ./misc/dependencies_mac.sh
`     

2) Make a folder on your desktop called 'DSE_SOFTWARE'.  
3) Add the following folder structure and tar files (add multiple versions if you like).

- DSE_SOFTWARE  
  - packages  
    - dse
      - dse-5.x.x-bin.tar.gz  
    - oracle-java  
      - jdk-8uxxx-linux-i586.tar.gz    


4) In pod, duplicate the builds template folder, rename it and then review/edit its 'cluster_settings.sh' file.    
`
$ cp -r builds/pod_dse/dse-5.x.x_template  builds/pod_dse/dse-x.x.x_nameIt  
`  
`
$ vi builds/pod_dse/dse-x.x.x_nameIt/cluster_settings.sh    
`  

5) In pod, duplicate a servers template json file, rename and edit it.  
`
$ cp servers/template_x.json  servers/nameIt.json  
`  
`
$ vi servers/nameIt.json  
`    

6) Finally run 'launch-pod' passing in the required parameters.  
`
$ ./launch-pod --pod pod_dse --servers nameIt.json --build dse-x.x.x_nameIt    
`

Note:    
When you first run pod, it will look in your specified builds folder to see if there is 'resources' folder.    
If there is not, it will untar your choosen dse version tarball and copy its resourcs folder there.    
Before the copy, the folder is stripped of all non-config files and the remainder are available for editing.    
The settings specified in 'cluster_settings.sh' and your .json defintions file take precedence.    
But for all the settings they do not cover, you can edit manually in the resurces folder.    
So if you need to adjust more settings, press <ctrl-c> at the end of this stage (you have 10 seconds!) to exit pod.    
