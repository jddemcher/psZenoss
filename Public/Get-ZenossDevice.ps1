Function Get-ZenossDevice {
    <#
    .DESCRIPTION
    Uses the Zenoss REST API to query for device records
    
    .PARAMETER field
    Match query based on "name", "ipAddress", "deviceClass", "productionState"
    
    .PARAMETER matchedvalue
    Value to match against for the specified field type
    
    .PARAMETER limit
    Limit of records to return (default is 1 if not specified)
    
    .PARAMETER Credential
    PSCredential parameter used for authentication
    
    .PARAMETER BaseUrl
    Instance URL of Zenoss environment
    
    .PARAMETER GetAllDevices
    Switch to specify that ignores key value pair and gets all device records
    
    .EXAMPLE
    Get-ZenossDevice -field name -matchedvalue myserver01 -apikey $apikey -BaseUrl $URL  -limit 1

    Get-ZenossDevice -apikey $apikey -BaseUrl $URL  -GetAllDevices
    #>
    
    Param (
        [Parameter(Mandatory = $false, Position = 0)]
        [ValidateSet("name", "ipAddress", "deviceClass", "productionState")]    
        [string]$field,

        [Parameter(Mandatory = $false, Position = 1, ParameterSetName='KeyValue')]
        [string]$matchedvalue,

        [Parameter(Mandatory = $false)]
        [int]$limit,

        [Parameter(Mandatory = $true)]
        [string]$apikey,

        [Parameter(Mandatory = $true)]
        [string]$BaseUrl,

        [Parameter(Mandatory = $false)]
        [switch]$GetAllDevices

    )
    

    If ($GetAllDevices -and ($Field -or $matchedvalue -or $limit)){
        Throw "Cannot use GetAllDevices switch with field/matchedvalue/limit parameters."
    }

    $Headers = @{ 'z-api-key' = $apikey }

    $Suffix = "/cz0/zport/dmd/device_router"
    $URL = $BaseUrl + $Suffix

    If ($GetAllDevices){
        $params = $null | ConvertTo-Json -Compress
    }
    Else {
    If (!($Limit)){
        $Limit = 1
    }
    $params = @{
        params = @{
            $field = $matchedvalue;
        };
        limit  = $limit
    }
    }

    $body = @{
        action = 'DeviceRouter'; 
        method = 'getDevices'; 
        data   = @($params); 
        type   = 'rpc'; 
        tid    = 4832
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