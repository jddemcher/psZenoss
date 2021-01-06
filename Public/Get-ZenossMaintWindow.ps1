Function Get-ZenossMaintWindow {
    <#
    .DESCRIPTION
    Get a list of available Zenoss maintenance window for a device

    .PARAMETER uid
    UID of device to get maint windows
    
    .PARAMETER Credential
    PSCredential object for authentication
    
    .PARAMETER BaseUrl
    HTTPS URL of the Zenoss instance
    
    .EXAMPLE
    $Device = Get-ZenossDevice -field name -matchedvalue myserver01 -apikey $apikey -BaseUrl $URL  -limit 1
    Get-ZenossMaintWindows -uid $Device.uid -apikey $apikey -BaseUrl 'https://myinstance.saas.zenoss.com'
    #>
    
    Param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$uid,

        [Parameter(Mandatory = $true, Position = 1)]
        [string]$apikey,

        [Parameter(Mandatory = $true, Position = 2)]
        [string]$BaseUrl

    )

    $Headers = @{ 'z-api-key' = $apikey }

    $Suffix = "/cz0/zport/dmd/devicemanagement_router"
    $URL = $BaseUrl + $Suffix

    $params = @{
        uid = $uid
    }

    $body = @{
        action = 'DeviceManagementRouter'; 
        method = 'getMaintWindows';
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