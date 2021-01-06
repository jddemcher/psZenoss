Function New-ZenossEvent {
    <#
    .DESCRIPTION
     Uses the EventsRouter action to create new Zenoss events from the REST API
    
    .PARAMETER summary
    Parameter used to define summary of the new event
    
    .PARAMETER device
    Parameter used to define device of the new event
    
    .PARAMETER component
    Parameter used to define component of the new event
    
    .PARAMETER evclasskey
    Parameter used to define evclasskey of the new event
    
    .PARAMETER evclass
    Parameter used to define evclass of the new event
    
    .PARAMETER severity
    Parameter used to define severity of the new event
    
    .PARAMETER Credential
    PSCredential object for authentication
    
    .PARAMETER BaseUrl
    HTTPS URL of the Zenoss instance
    
    .EXAMPLE
    New-ZenossEvent -Summary "Summary description" -Device "Server01" -Component "Exchange" -Evclass "/App/Exchange" -Evclass "ExchangeAlerts" Severity Warning -apikey $apikey -BaseUrl 'https://yourinstance.saas.zenoss.com'
    #>
    
    Param (
        [Parameter(Mandatory = $true, Position = 1)]
        [string]$summary,

        [Parameter(Mandatory = $true, Position = 2)]
        [string]$device, 

        [Parameter(Mandatory = $true, Position = 3)]
        [string]$component, 

        [Parameter(Mandatory = $true, Position = 4)]
        [string]$evclasskey, 

        [Parameter(Mandatory = $true, Position = 5)]
        [string]$evclass, 

        [Parameter(Mandatory = $true, Position = 6)]
        [ValidateSet("Critical", "Error", "Warning", "Info", "Debug", "Clear")]
        [string]$severity,

        [Parameter(Mandatory = $true, Position = 7)]
        [string]$apikey,

        [Parameter(Mandatory = $true, Position = 8)]
        [string]$BaseUrl

    )

    $Headers = @{ 'z-api-key' = $apikey }

    $Suffix = "/cz0/zport/dmd/evconsole_router"
    $URL = $BaseUrl + $Suffix

    $data = @{
        summary    = $summary; 
        device     = $device; 
        component  = $component; 
        severity   = $severity; 
        evclasskey = $evclasskey;
        evclass    = $evclass
    } 

    $body = @{
        action = 'EventsRouter'; 
        method = 'add_event'; 
        data   = @($data); 
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