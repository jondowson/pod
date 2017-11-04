# CLUSTA %%

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

1) git clone https://github.com/jondowson/dse-setup  

If you are on a mac - first run the dependencies script from the root folder of the repo.  
`  
$ ./lib/dependencies_mac.sh
`     

2) Make a folder on your desktop called 'DSE_SOFTWARE'.  
3) Add the following folder structure and tar files (add multiple versions if you like).

- DSE_SOFTWARE  
  - packages  
    - dse
      - dse-5.x.x-bin.tar.gz  
    - oracle-java  
      - jdk-8uxxx-linux-i586.tar.gz  

4) Duplicate the config template, rename it and edit to your needs.  
`
$ cp configs/setup_dse/config_dse5.x_template.sh configs/setup_dse/my_config.sh`  
`  
$ vi configs/setup_dse/my_config.sh    
`  
5) Reference 'my_config.sh' at top of 'setup_dse.sh'  
`
$ vi setup_dse.sh  
`  
6) Finally run 'setup_dse.sh' and follow on-screen instructions.  
`
$ ./setup_dse.sh
`
