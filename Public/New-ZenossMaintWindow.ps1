Function New-ZenossMaintWindow {
    <#
.DESCRIPTION
Creates a maintenance window for given device UID

.PARAMETER uid
UID of device for which to create maintenance window

.PARAMETER name
name of the window

.PARAMETER startDate
start date in datetime format, example: Get-Date '11/1/2019 4:00 PM'

.PARAMETER durationDays
duration of days for the window

.PARAMETER durationHours
duration of hours for the window

.PARAMETER durationMinutes
duration of minutes for the window

.PARAMETER repeat
repeat interval for this window

.PARAMETER Credential
PSCredential object for authentication

.PARAMETER BaseUrl
HTTPS URL of the Zenoss instance

.EXAMPLE
$Device = Get-ZenossDevice -field name -matchedvalue myserver01 -apikey $apikey -BaseUrl $URL  -limit 1
New-ZenossMaintWindow -uid $Device.uid -name 'Test1' -startDate (Get-Date '11/1/2019 4:00 PM') -durationDays 0 -durationHours 1 durationMinutes 30 -repeat Never -apikey $apikey -BaseUrl $URL
#>

    
    Param (
        [Parameter(Mandatory = $true)]
        [string]$uid,

        [Parameter(Mandatory = $true)]
        [string]$name,

        [Parameter(Mandatory = $true)]
        [datetime]$startDate,

        [Parameter(Mandatory = $true)]
        [string]$durationDays,

        [Parameter(Mandatory = $true)]
        [string]$durationHours,

        [Parameter(Mandatory = $true)]
        [string]$durationMinutes,

        [Parameter(Mandatory = $true)]
        [ValidateSet("Daily", "Weekly", "Never")]  
        [string]$repeat,

        [Parameter(Mandatory = $true)]
        [string]$apikey,

        [Parameter(Mandatory = $true)]
        [string]$BaseUrl

    )

    $Headers = @{ 'z-api-key' = $apikey }

    $Suffix = "/cz0/zport/dmd/devicemanagement_router"
    $URL = $BaseUrl + $Suffix

    $Date = [int](Get-Date $StartDate -UFormat %s)
    
    $params = @{
        params = @{
            uid                  = $uid;
            id                   = '';
            name                 = $name;
            enabled              = $True;
            startDateTime        = $Date; #"1572577424"
            durationDays         = $durationDays; #"0"
            durationHours        = $durationHours; #"8"
            durationMinutes      = $durationMinutes; #"0"
            repeat               = $repeat; #"Daily"
            startProductionState = 200
        }

    }

    $body = @{
        action = 'DeviceManagementRouter'; 
        method = 'addMaintWindow';
        data   = @($params);
        type   = 'rpc'; 
        tid    = 1
    } | ConvertTo-Json -Depth 4

    $Result = Invoke-WebRequest -UseBasicParsing -Uri $URL -Headers $Headers -Method Post -Body $body -ContentType "application/json"
    If ($Result.statuscode -eq '200') {
        Try {
            $Content = $Result.Content | ConvertFrom-Json
        }
        Catch {
            Throw "Empty response from web request"
        }
        $output = $Content.result
        Return $Output
    }
    else {
        Throw "REST call to $URL failed. `n Exception: $($Result.StatusCode) - $($Result.StatusDescription)"
    }
}