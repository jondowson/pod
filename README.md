# pod

## What?
A bash application to rapidly setup and configure a dse cluster.  
Tested on Mac, Ubuntu and Centos.   
A work in progress !!  

## About?
Duplicate a template and in it configure cluster settings + software versions.    
Then reference the config file in the 'setup_dse.sh' script before running it.  
This will untar all the software and configure all the files as per your configuration file.  
Out of the box - this will create a folder on your desktop with all the unpacked software, data and log folders.

Create multiple config files for multiple setups (different versions/settings).  

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

4) Duplicate the config template, rename it and review/edit cluster settings.  
`
$ cp builds/pod_dse/config_dse-5.x.x_template.sh builds/pod_dse/dse-<version>_<name>  
`  
$ vi builds/pod_dse/dse-<version>_<name>/cluster_settings.sh    
`  
5) Review the 'pods/pod_dse' runtime settings.  
`
$ vi pods/pod_dse.sh  
`  
5) Create a servers definition file 'servers/<name>.json' - base it off a duplicated template.  
`
$ cp servers/<template>.json servers/<server_def>.json  
`  
6) Finally run 'launch-pod' passing in the required parameters.  
`
$ ./launch-pod --pod pod_dse --servers <server_def>.json --build dse-<version>_<name>
`
