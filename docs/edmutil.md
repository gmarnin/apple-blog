---
title: Edmutil Mac Application
nav_order: 5
---


# Edmutil Mac Application

edmutil is a command line utility designed to troubleshoot Rutgers Munki installations. It provides various commands to gather system information that can help diagnose Munki related issues.
It is currently installed by default on all Macs that use EDM's Munki service. 

`edmutil`:

```      
OVERVIEW: A command line utility to troubleshoot Rutgers Munki.

Use subcommands like disk, system, or use --all to run them all.

USAGE: edmutil [--help] [--all] <subcommand>

OPTIONS:
  -h, --help              Show extended help text.
  --all                   Runs all the subcommands. Requires admin rights.
  --version               Show the version.

SUBCOMMANDS:
  applications            Lists all installed applications, versions, install date/time, architecture, and Electron apps.
  battery                 Prints the status of the Mac battery (laptops only).
  cisco                   Shows Cisco Discovery Protocol (CDP) switch details when using ethernet on campus.
  disk                    Prints the boot volume disk information.
  mdm                     Status of MDM and Bootstrap Token.
  munki                   Prints all the Munki app details.
  munki-logs              Collects the Munki configs and current run verbose log -vvv.
  munki-reinstall         Downloads and reinstalls the latest version of the Munki application.
  network                 Prints the active network details including interface type, IP, MAC, DNS, and VPN status.
  rename                  Give this Mac a new name.
  security                Status of Gatekeeper, SIP, FileVault and Cisco AMP.
  system                  Prints system info such as hostname, serial number, hardware, macOS version, and time info.
  users                   Prints the all the user account details.

  See 'edmutil help <subcommand>' for detailed help.
```


`edmutil --help`:

```
DESCRIPTION:
    edmutil is a command line utility designed to troubleshoot Rutgers Munki installations. It provides
    various commands to gather system information that can help diagnose Munki related issues.

Foo
        
USAGE EXAMPLES:
    edmutil
        Shows all the options and subcommands

    sudo edmutil --all
        Runs all the subcommands except cisco and rename. Collects the Munki logs and saves them to a
        zip file on the current user's desktop named edmutil_logs_$hostname.
        Requires administrative privileges (as sudo)
        
    edmutil disk
        Shows information about boot volume disk
        
    sudo edmutil mdm
        Shows the status of MDM enrollment and the Bootstrap Token
              
NOTES:
    The --all flag must be run with admin rights (as sudo). Same with the cisco, mdm, munki-logs and munki-reinstall flags

```