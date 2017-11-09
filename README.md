# pod

## What?
A bash application to rapidly setup and configure a dse cluster.  
Tested on Mac, Ubuntu and Centos.   
A work in progress !!  

## About?
From duplicated templates, define:  
-  [1] a json file that describes the servers in your cluster.
-  [2] a build folder wth 'cluster_settings' file that species software versions, paths and fundamental cluster-wide settings.  

Then launch pod, passing in these two files as parameters.  
Pod will distribute, untar and configure all the software to each server in your json defintion.  
Out of the box - this will create a folder on your desktop with all the unpacked software, data and log folders in one place.  
You can specify other locations to install software,logs etc when defining [1] + [2].

With pod you can easily create and manage multiple cluster setups (different versions/settings).  
You can deploy these different configurations to the same machines and they will not interfere with each other.  
As such pod is very useful in development/testing environments as well as setting up dse in production when opscenter is not an option.     

## How?

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

4) Duplicate a builds template folder, rename it and then review/edit its 'cluster_settings.sh' file.    
`
$ cp -r builds/pod_dse/dse-5.x.x_template  builds/pod_dse/dse-x.x.x_nameIt  
`  
`
$ vi builds/pod_dse/dse-<version>_<name>/cluster_settings.sh    
`  

5) Duplicate a servers definition file 'servers/template_?.json' and the edit it.  
`
$ cp servers/template_?.json  servers/nameIt.json  
`  
`
$ vi servers/nameIt.json  
`    

6) Finally run 'launch-pod' passing in the required parameters.  
`
$ ./launch-pod --pod pod_dse --servers nameIt.json --build dse-x.x.x_nameIt
`
