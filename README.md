# pod

## What?
A bash application to rapidly setup and configure a dse cluster.  
Tested on Mac, Ubuntu and Centos.   
A work in progress !!  

## About?
From duplicated templates, define:  
-  a json file that describes the servers in your cluster.
-  a 'cluster_settings' file that species software versions, paths and fundamental cluster-wide settings.  

Then launch pod, passing in these two files as parameters.  
Pod will distribute, untar and configure all the software to each server in your json defintion.  
Out of the box - this will create a folder on your desktop with all the unpacked software, data and log folders.  
You can specify other locations to install software,logs etc when defining your server json and cluster_settings.

With pod you can easily create and manage multiple cluster setups (different versions/settings).  
You can deploy these different configurations to the same machines and they will not interfere with each other.  
As such pod is very useful in development/testing environments as well as setting up dse when opscenter is not an option.     

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
$ cp builds/pod_dse/dse-5.x.x_template.sh builds/pod_dse/dse-<version>_<name>  
`
`
$ vi builds/pod_dse/dse-<version>_<name>/cluster_settings.sh    
`  

5) Create a servers definition file 'servers/<name>.json' - base it off a duplicated template.  
`
$ cp servers/<template>.json servers/<server_def>.json  
`  

6) Review/edit the 'pods/pod_dse' runtime settings.  
`
$ vi pods/pod_dse.sh  
`  

7) Finally run 'launch-pod' passing in the required parameters.  
`
$ ./launch-pod --pod pod_dse --servers <server_def>.json --build dse-<version>_<name>
`
