# Minecraft Bedrock Server Updater

## Description

This script is used to always keep your Windows based bedrock server always up to date.

## Script Assumptions

The script expects the following directories to exist

* `C:\Minecraft\VersionBackup\`
  * Used to keep a backup of previous instalations
* `C:\Minecraft\Server`
  * Source for bedrock server service to execute from

You may change these directories in the top Paramaters section of the script   
The script by default will ignore the following files when updating

        "permissions.json",
        "server.properties",
        "whitelist.json"
These files are important for maintaining the current state of your world.   
Please see Bedrock Server documentation if you would like to learn more about them.

## Script Execution

### This is left up to you

You could run this is as a daily scheduled task or manually if you wanted to.  
The choice is up to you.

## Contact Me If You Have Any Questions
### *Disclaimer
I wrote this script and readme in an evening...  
Please be nice :)