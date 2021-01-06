Function Set-ZenossProductionState {
    <#
    .DESCRIPTION
    Sets the ProductionState of a device 
    
    .PARAMETER uid
    UID of device to set ProductionState
    
    .PARAMETER prodState
    ProductionState integer value
    
    .PARAMETER Credential
    PSCredential object for authentication
    
    .PARAMETER BaseUrl
    HTTPS URL of the Zenoss instance
    
    .EXAMPLE
    $uid = /zport/dmd/Devices/Server/Microsoft/Windows/testserver1
    Set-ZenossProductionState -uid $uid -prodState 300 -apikey $apikey -BaseUrl $URL
    #>
    
    Param (
        [Parameter(Mandatory = $true, Position = 1)]
        [string]$uid,

        [Parameter(Mandatory = $true, Position = 2)]
        [int]$prodState,

        [Parameter(Mandatory = $true, Position = 3)]
        [string]$apikey,

        [Parameter(Mandatory = $true, Position = 4)]
        [string]$BaseUrl

    )

    $Headers = @{ 'z-api-key' = $apikey }

    $Suffix = "/cz0/zport/dmd/device_router"
    $URL = $BaseUrl + $Suffix

    $params = @{
        prodState = $prodState; 
        uids      = $uid;
        uid       = '';
        hashcheck = ''
    }
 
    $body = @{
        action = 'DeviceRouter'; 
        method = 'setProductionState'; 
        data   = @($params); 
        type   = 'rpc'; 
        tid    = 1
    } | ConvertTo-Json

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