# pod

## What?
A bash application to rapidly setup and configure a dse cluster.  
Tested on Mac, Ubuntu and Centos.   
A work in progress !!  

## About?
From duplicated templates, define a servers json defintion file + a cluster_settings file.    
Then launch pod, passing in these two files as parameters.  
Pod will distribute, untar and configure all the software to each server in your json defintion.  
Out of the box - this will create a folder on your desktop with all the unpacked software, data and log folders.
You can specify other locations to install software,logs etc when defining your server json and cluster_settings.

With pod you can easily create multiple config files for multiple setups (different versions/settings).  

## How?

Quick Instructions (to work out of the box):  

1) git clone https://github.com/jondowson/pod  

If you are on a mac - first run the dependencies script from the root folder of the repo.  
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

4) Duplicate the builds template, rename it and review/edit cluster settings.  
`
$ cp builds/pod_dse/dse-5.x.x_template.sh builds/pod_dse/dse-<version>_<name>  
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
