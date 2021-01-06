Function Get-ZenossEvent {
    <#
    .DESCRIPTION
    Uses the EventsRouter action to query Zenoss events from the REST API
    
    .PARAMETER field
    Parameter used to define the field to be used to lookup events
    
    .PARAMETER matchedvalue
    Parameter used to define the lookup value to match on based on the field parameter
    
    .PARAMETER limit
    Parameter used to define the number of records to return from the query
    
    .PARAMETER Credential
    PSCredential object for authentication
    
    .PARAMETER BaseUrl
    HTTPS URL of the Zenoss instance
    
    .EXAMPLE
    Get-ZenossEvent -field device -matchedvalue 'server01' -limit 10 -apikey $apikey -BaseUrl 'https://yourinstance.saas.zenoss.com'
    #>
    
    Param (
        [Parameter(Mandatory = $true, Position = 1)]
        [ValidateSet("device", "DeviceClass", "eventClassKey", "evid", "severity", "summary", "details","message")]    
        [string]$field,

        [Parameter(Mandatory = $true, Position = 2)]
        [string]$matchedvalue,

        [Parameter(Mandatory = $true, Position = 3)]
        [int]$limit,

        [Parameter(Mandatory = $true, Position = 4)]
        [string]$apikey,

        [Parameter(Mandatory = $true, Position = 5)]
        [string]$BaseUrl

    )

    $Headers = @{ 'z-api-key' = $apikey }

    $Suffix = "/cz0/zport/dmd/evconsole_router"
    $URL = $BaseUrl + $Suffix

    $params = @{
        params = @{
            $field = $matchedvalue;
        };
        limit  = $limit
    }

    $body = @{
        action = 'EventsRouter'; 
        method = 'query'; 
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