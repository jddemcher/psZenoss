Function Close-ZenossEvent {
    <#
    .DESCRIPTION
    Uses the EventsRouter action to close Zenoss events from the REST API based on an event ID number
    
    .PARAMETER evid
    Event ID of the event to close
    
    .PARAMETER Credential
    PSCredential object for authentication
    
    .PARAMETER BaseUrl
    HTTPS URL of the Zenoss instance
    
    .EXAMPLE
    Close-ZenossEvent -evid '0242ac11-000a-8d58-11e9-f1ga318c9015' -apikey $apikey -BaseUrl 'https://yourinstance.saas.zenoss.com'
    #>
    
    Param (
        [Parameter(Mandatory = $true, Position = 1)]
        [string]$evid,

        [Parameter(Mandatory = $true, Position = 2)]
        [string]$apikey,

        [Parameter(Mandatory = $true, Position = 8)]
        [string]$BaseUrl

    )

    $Headers = @{ 'z-api-key' = $apikey }

    $Suffix = "/cz0/zport/dmd/evconsole_router"
    $URL = $BaseUrl + $Suffix

    $data = @{
        evids = @($evid)
    } 

    $body = @{
        action = 'EventsRouter'; 
        method = 'close'; 
        data   = @($data); 
        type   = 'rpc'; 
        tid    = 1
    } | ConvertTo-Json -Depth 3

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