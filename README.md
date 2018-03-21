# pod

## pod intro

**pod** is about automating tasks over many machines.    
It is written in bash because sometimes thats all you can use in locked down environments (banking).    
Tested on Mac, Ubuntu, Centos and Redhat.    

It is extensible and new modules (or 'pods') can be added quickly that make use of pod's core capabilities.  

**Pod Use Cases**    

1) Install and configure software.    
2) Harvest os/application data - cpu, memory, diskspace, mounts, swap etc    
3) Test - security, readiness (best practice), network/port connectivity, write paths and file permissions.    
4) Tidy up machines - remove software, unmount/mount drives, stop processes.    
5) 'sudo tasks' - setup cron jobs, create services, user accounts.               

## pod versioning

**The latest stable version is:**
```diff
+ pod-version-1.5.0
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

The first 'pod' makes it easy to set up and run a DSE cluster from **tarballs**.  

  - setup, configure and distribute DSE software to all servers in a cluster.
  - setup and configure datastax-agent software.    
  - perform rolling start and stop for DSE clusters.

With **pod_DSE** you can easily create and manage multiple dse cluster setups with varying versions / settings.     
Different configurations can be deployed to the same machines and they will not interfere with each other.  
As such **pod_DSE** is very useful in development / testing environments as well as in production if DSE opscenter is not an option.  

**Features:**    
- **available:**    by using tarballs, pod does **not require root privileges** to setup a dse cluster.    
- **flexible:**     can install a dse cluster locally and/or on remote machines (or span both).     
- **complete:**     will distribute, untar and configure all software sent to each server.    
- **speed:**        0-cluster in minutes !!
- **simple:**       settings are defined in just **two** configuration files.    
          -  one for cluster-wide settings.    
          -  one for server level settings.    
- **control:**      all dse settings and installation paths may be configured.     

Out of the box - pod creates a desktop folder with all configured software, data and log folders all conveniently in one place.  

## Get started with 'pod_DSE'   

Quick Instructions (to work out of the box):  

1) Make a folder on your desktop called '**POD_SOFTWARE**'.  
2) Add the following folder structure and tar files (add multiple versions per folder if you like).

- **POD_SOFTWARE**  
  - **DATASTAX**  
    - **dse**
      - dse-5.x.x-bin.tar.gz  
    - **opscenter**    
      - opscenter-6.x.x.tar.gz    
    - **datastax-agent**    
      - datastax-agent-6.x.x.tar.gz
  - **JAVA**    
    - **oracle**  
      - jdk-8uxxx-linux-i586.tar.gz
  - **POD**          

3) cd to POD_SOFTWARE/POD folder
4) git clone https://github.com/jondowson/pod or download + uncompress zip here.  
5) run the dependencies script from the root folder of the repo.  
`  
$ ./misc/pod_dependencies.sh
`

**Note:**  
On a Mac this will install/refresh homebrew package manager and retrieve a number of packages.    
On all OS, it will add pod to the path, so pod can be run from any folder.    
It is neccessary to run this on the machine running pod (or any Mac in the cluster).        

6) Setup passwordless access to all servers (including local machine).        
`    
$ ssh-keygen -t rsa    # hit enter to all questions    
`    
`
$ ssh-copy-id user@remote-machine
`    
The first step is required if you do not already have a local key setup.    
This second step will send your key to the remote server to enable password-less authentication.    

7) Duplicate **pods/pod_DSE/builds/dse-5.x.x_template**, rename it and then review/edit its '**build_settings.bash**' file.    
`   
$ cp -r pods/pod_DSE/builds/dse-5.x.x_template  pods/pod_DSE/builds/dse-5.x.x_nameIt  
`     
`   
$ vi pods/pod_DSE/builds/dse-5.x.x_nameIt/build_settings.bash    
`   

Rename the template file in line with the dse version you intend to use.    
The '**build_settings.bash**' file captures cluster-wide settings such as cluster name and write paths for logs/data.    

8) Duplicate a servers template **.json** file, rename and edit it.  
`   
$ cp pods/pod_DSE/servers/template_x.json  servers/nameIt.json  
`   
`   
$ vi servers/nameIt.json    
`        

The **.json** defintion file captures server specific settings such as login credentials and ip addresses.    

9) For help run '**pod**' passing '**-h**' or '**--help**'.  
`   
$ pod --help    
`       

10) Finally run '**pod**' passing in the required parameters (without directory names).  
`   
$ chmod +x pod   
`  
`   
$ pod --pod pod_DSE --servers nameIt.json --build dse-x.x.x_nameIt    
`   

**Note:**    
When you first run pod_DSE, it will look in your specified builds folder to see if there is a '**resources**' folder.    
If there is not, it will uncompress your chosen dse version tarball and copy its resources folder there.    
This copied folder is stripped of all **non-config files** - the remainder are then available for editing.    

The settings specified in **build_settings.bash** and the **<servers.json>** are edited into this copied resources folder.    
But for all the settings they do not cover, you can manually edit any of them.    
So if required, hit **\<ctrl-c\>** at the end of this initial stage - by default you will have 5 seconds!   
Then edit any DSE config file in the build's **resources** folder and re-launch **pod_DSE**.       

All servers will receive a bespoke version of the resources folder + all required software.     
A pod-launcher script will be run remotely and finish the server configuration:    
- uncompress software.    
- merge the bespoke resources folder.    
- setup environment variables.      
Once finished - pod_DSE has a rolling start command to start DSE (choice of modes) and datastax-agents - see help for example.    
