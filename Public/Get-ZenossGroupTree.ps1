Function Get-ZenossGroupTree {
    <#
    .DESCRIPTION
    Uses the Zenoss REST API to query for device records
    
    .PARAMETER GroupPath
    Match query based on the device ID path E.g. '/Groups/TestGroup1/GroupA'

    .PARAMETER Credential
    PSCredential parameter used for authentication
    
    .PARAMETER BaseUrl
    Instance URL of Zenoss environment
    
    .EXAMPLE
    Get-ZenossGroupTree -GroupPath '/Groups/TestGroup1/GroupA' -apikey $apikey -BaseUrl $URL
    #>
    
    Param (
        [Parameter(Mandatory = $false, Position = 0)]
        [string]$GroupPath,

        [Parameter(Mandatory = $true)]
        [string]$apikey,

        [Parameter(Mandatory = $true)]
        [string]$BaseUrl
    )

    $Headers = @{ 'z-api-key' = $apikey }

    $Suffix = "/cz0/zport/dmd/device_router"
    $URL = $BaseUrl + $Suffix

    $params = @{
            'id' = "/zport/dmd/Groups/$GroupPath"
    }

    $body = @{
        action = 'DeviceRouter'; 
        method = 'asyncGetTree'; 
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