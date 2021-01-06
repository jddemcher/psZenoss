Function Get-ZenossProductionState {
    <#
    .DESCRIPTION
    Get a list of available Zenoss production states
    
    .PARAMETER Credential
    PSCredential object for authentication
    
    .PARAMETER BaseUrl
    HTTPS URL of the Zenoss instance
    
    .EXAMPLE
    Get-ZenossProductionStates -apikey $apikey -BaseUrl 'https://myinstance.saas.zenoss.com'
    #>
    
    Param (

        [Parameter(Mandatory = $true, Position = 0)]
        [string]$apikey,

        [Parameter(Mandatory = $true, Position = 1)]
        [string]$BaseUrl

    )

    $Headers = @{ 'z-api-key' = $apikey }

    $Suffix = "/cz0/zport/dmd/device_router"
    $URL = $BaseUrl + $Suffix

    $body = @{
        action = 'DeviceRouter'; 
        method = 'getProductionStates'; 
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