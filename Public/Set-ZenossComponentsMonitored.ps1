Function Set-ZenossComponentsMonitored {
    <#
    .DESCRIPTION
    Sets the component(s) of a device(s) in either monitored or unmonitored state
    
    .PARAMETER uid
    Array of UID's to set monitored state
    
    .PARAMETER Monitor
    Boolean value to set monitored state
    
    .PARAMETER Credential
    PSCredential object for authentication
    
    .PARAMETER BaseUrl
    HTTPS URL of the Zenoss instance
    
    .EXAMPLE
    Set-ZenossComponentsMonitored -uid $Uids -Monitor 'False' -apikey $apikey -BaseUrl $BaseUrl
    #>
    
    Param (
        [Parameter(Mandatory = $true, Position = 1)]
        [array]$uid,

        [Parameter(Mandatory = $true, Position = 2)]
        [boolean]$Monitor,

        [Parameter(Mandatory = $true, Position = 3)]
        [string]$apikey,

        [Parameter(Mandatory = $true, Position = 4)]
        [string]$BaseUrl

    )

    $Headers = @{ 'z-api-key' = $apikey }

    $Suffix = "/cz0/zport/dmd/device_router"
    $URL = $BaseUrl + $Suffix

    $params = @{
        monitor = $Monitor; 
        uids      = $uid;
        hashcheck = 'None'
    }
 
    $body = @{
        action = 'DeviceRouter'; 
        method = 'setComponentsMonitored'; 
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