Function Remove-ZenossMaintWindow {
    <#
    .DESCRIPTION
    Get a list of available Zenoss production states

    .PARAMETER MaintenanceWindow
    PSCustomObject holding the maintenance window information from Get-ZenossMaintWindow
    
    .PARAMETER Credential
    PSCredential object for authentication
    
    .PARAMETER BaseUrl
    HTTPS URL of the Zenoss instance
    
    .EXAMPLE
    $Device = Get-ZenossDevice -field name -matchedvalue myserver01 -apikey $apikey -BaseUrl $URL  -limit 1
    $mw = Get-ZenossMaintWindow -uid $Device.uid -apikey $apikey -BaseUrl 'https://myinstance.saas.zenoss.com'
    Remove-ZenossMaintWindow -uid $mw.uid -id $mw.id -apikey $apikey -BaseUrl 'https://myinstance.saas.zenoss.com'
    #>
    
    Param (
        [Parameter(ValueFromPipeline, Mandatory = $true)]
        [PSCustomObject]$MaintenanceWindow,

        [Parameter(Mandatory = $true, Position = 0)]
        [string]$apikey,

        [Parameter(Mandatory = $true, Position = 1)]
        [string]$BaseUrl

    )

    $Headers = @{ 'z-api-key' = $apikey }

    $Suffix = "/cz0/zport/dmd/devicemanagement_router"
    $URL = $BaseUrl + $Suffix

    $uid = $MaintenanceWindow.uid
    $id = $MaintenanceWindow.id

    $params = @{
        uid = $uid;
        id  = $id
    }

    $body = @{
        action = 'DeviceManagementRouter'; 
        method = 'deleteMaintWindow';
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