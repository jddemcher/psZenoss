# Posh-Zenoss

This module is a PowerShell wrapper based on the Zenoss RESTful API. Anyone with powershell can use this module provided they have valid API credentials to their Zenoss platform.

## Installing the Module

Download this zip Posh-Module package and copy to your local powershell module directory (C:\Program Files\WindowsPowerShell\Modules). Once the package is in the modules directory, you can run the import module command to load the package into your session.

```powershell
Import-Module Posh-Zenoss
``` 

## Commands

```powershell
Get-Command -Module Posh-Zenoss
```

### Close-ZenossEvent
### Get-ZenossDevice
### Get-ZenossDeviceComponent
### Get-ZenossEvent
### Get-ZenossGroupTree
### Get-ZenossMaintWindow
### Get-ZenossProductionState
### New-ZenossEvent
### New-ZenossMaintWindow
### Remove-ZenossMaintWindow
### Set-ZenossComponentsMonitored
### Set-ZenossMaintWindow
### Set-ZenossProductionState
### Update-ZenossEventLog

## Examples

```powershell
#Populate key var
$apikey = 'lkasdjflwkeurpaoskdjf'

#Define a URL
$URL = "https://myzenossinstance.saas.zenoss.com"

#Get a zenoss device
Get-ZenossDevice -field name -matchedvalue 'servername' -apikey $apikey -BaseUrl $URL

#Get a zenoss group tree
$GroupPath = 'CMDBGroups/Patching Schedule'
Get-ZenossGroupTree -GroupPath $GroupPath -apikey $apikey -BaseUrl $URL
```
