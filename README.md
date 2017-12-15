# pod

## pod intro

**pod** is about automating tasks over many machines.    
It is written in bash because sometimes thats all you can use in locked down environments (banking).    
Tested on Mac, Ubuntu, Centos and Redhat.    

It is extensible and new modules (or 'pods') can be added quickly that make use of pod's core capabilities.  
Its first 'pod' makes it easy to set up and run a DSE cluster from **tarballs**.  
- **pod_DSE**:    
    - setup, configure and distribute dse software to all servers in a cluster.    
    - perform rolling starts and stops.            

## pod versioning

**The latest stable version is:**
```diff
+ pod-version-1.2
```    
The master branch is in sync with the latest stable version.    

To update to the latest version when on 'master' branch.      
`
$ git pull                            
`    
To change to a different version.    
`    
$ git checkout -b <pod-version-x.x>     
`    

## pod modules

- pod is meant to be extensible and its core functions enable distribution and configuration of files.        
- pod modules ('pods') are discrete projects that make use of these core functions.    
- each 'pod' contain the same sub folders and can make use of the generic 'pod_' for common tasks.    
- pod workflows are organised into one or more **STAGES**, consisting of one or more **TASKS**, containing action(s).     

### pod #1 - 'pod_DSE'  

With **pod_DSE** you can easily create and manage multiple dse cluster setups with varying versions / settings.     
Different configurations can be deployed to the same machines and they will not interfere with each other.  
As such **pod_DSE** is very useful in development / testing environments as well as in production if opscenter is not an option.  

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

## Get started with 'pod_DSE'   

Quick Instructions (to work out of the box):  

1) Setup passwordless access to all servers (including local machine).    
`    
$ ssh-keygen -t rsa    # hit enter to all questions    
`    
`
$ ssh-copy-id user@remote-machine
`    
The first step is required if you do not already have a local key setup.    
This second step will send your key to the remote server to enable passwordless authentication.    

2) git clone https://github.com/jondowson/pod  

3) For Macs (both running pod and in a cluster) - first run the dependencies script from the root folder of the repo.  
`  
$ ./misc/install_podDependencies_mac.sh
`     

4) Make a folder on your desktop called '**POD_SOFTWARE**'.  
5) Add the following folder structure and tar files (add multiple versions per folder if you like).

- **POD_SOFTWARE**  
  - **DATASTAX**  
    - **dse**
      - dse-5.x.x-bin.tar.gz  
    - opscenter    
      - opscenter-6.x.x.tar.gz    
    - datastax-agent    
      - datastax-agent-6.x.x.tar.gz
  - JAVA    
    - **oracle**  
      - jdk-8uxxx-linux-i586.tar.gz
  - **POD**    
    - **pod**   

- add the pod software to the POD folder !    
Opscenter and agent software is not setup by pod_DSE but inclusion will ensure their tarballs are distributed to each server.     
Check online datastax documents to ensure usage of compatible versions.      

6) Duplicate **pods/pod_DSE/builds/dse-5.x.x_template**, rename it and then review/edit its '**build_settings.bash**' file.    
`   
$ cp -r pods/pod_DSE/builds/dse-5.x.x_template  pods/pod_DSE/builds/dse-5.x.x_nameIt  
`     
`   
$ vi pods/pod_DSE/builds/dse-5.x.x_nameIt/build_settings.bash    
`   

Rename the template file in line with the dse version you intend to use.    
The '**build_settings.bash**' file captures cluster-wide settings such as cluster name and write paths for logs/data.    

7) Duplicate a servers template **.json** file, rename and edit it.  
`   
$ cp pods/pod_DSE/servers/template_x.json  servers/nameIt.json  
`   
`   
$ vi servers/nameIt.json    
`        

The **.json** defintion file captures server specific settings such as login credentials and ip addresses.    

8) For help run '**launch-pod**' passing '**-h**' or '**--help**'.  
`   
$ ./launch-pod --help    
`       

9) Finally run '**launch-pod**' passing in the required parameters.  
`   
$ ./launch-pod --pod pod_DSE --servers nameIt.json --build dse-x.x.x_nameIt    
`   

**Note:**    
When you first run pod, it will look in your specified builds folder to see if there is a '**resources**' folder.    
If there is not, it will untar your chosen dse version tarball and copy its resources folder there.    
This copied folder is stripped of all **non-config files** - the remainder are then available for editing.    

The settings specified in '**build_settings.bash**' and the servers '**.json**' will be edited into this copied resources folder.    
But for all the settings they do not cover, you can manually edit any of them.    
So if required, hit **\<ctrl-c\>** at the end of this initial stage - you will have 10 seconds!   
Then edit any dse config file in the build's **resources** folder.    

Re-launch **pod_DSE**.    
All servers will receive a bespoke version of the resources folder + all required software.     
A pod-launcher script will be run remotely and finish the server configuration, including merging the resources folder.  
You can then perform a rolling start of the cluster using pod_DSE - see help for example.    
