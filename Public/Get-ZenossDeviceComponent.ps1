Function Get-ZenossDeviceComponent {
    <#
    .DESCRIPTION
    Uses the Zenoss REST API to query for device record components
    
    .PARAMETER uid
    UID of device to get related components
    
    .PARAMETER pagelimit
    Limit of records to return in pagination (default is 1 if not specified)
    
    .PARAMETER Credential
    PSCredential parameter used for authentication
    
    .PARAMETER BaseUrl
    Instance URL of Zenoss environment
    
    .EXAMPLE
    $Device = Get-ZenossDevice -field name -matchedvalue myserver01 -apikey $apikey -BaseUrl $URL -limit 1

    Get-ZenossDeviceComponent -uid $Device.devices.uid -apikey $apikey -BaseUrl $URL
    #>
    
    Param (
        [Parameter(Mandatory = $true)]
        [string]$uid,

        [Parameter(Mandatory = $false)]
        [int]$pagelimit,

        [Parameter(Mandatory = $false)]
        [string]$metatype,

        [Parameter(Mandatory = $true)]
        [string]$apikey,

        [Parameter(Mandatory = $true)]
        [string]$BaseUrl

    )
    
    $Headers = @{ 'z-api-key' = $apikey }

    $Suffix = "/cz0/zport/dmd/device_router"
    $URL = $BaseUrl + $Suffix

    If (!($pagelimit)) {
        $pagelimit = 10
    }

    $params = @{
        uid   = $uid;
        limit = $pagelimit;
        meta_type = $metatype
    }

    $body = @{
        action = 'DeviceRouter'; 
        method = 'getComponents'; 
        data   = @($params); 
        type   = 'rpc'; 
        tid    = 4832
    } | ConvertTo-Json -Compress

    $Result = Invoke-WebRequest -UseBasicParsing -Uri $URL -Headers $Headers -Method Post -Body $body -ContentType "application/json"
    If ($Result.statuscode -eq '200') {
        Try {
            $Content = ($Result.Content | ConvertFrom-Json).result
        }
        Catch {
            Throw "Empty response from web request"
        }

        #Pagination
        $ReturnCount = ($Content.data).count
        $TotalCount = $Content.totalCount
        $output = @()
        $output += $Content.data
        If ($ReturnCount -lt $TotalCount) {
            $offset = 0
            Do {
                $offset = $offset + ($Content.data).count
                $params = @{
                    uid   = $uid;
                    limit = $pagelimit;
                    start = $offset;
                    meta_type = $metatype
                }
        
                $body = @{
                    action = 'DeviceRouter'; 
                    method = 'getComponents'; 
                    data   = @($params); 
                    type   = 'rpc'; 
                    tid    = 4832
                } | ConvertTo-Json -Compress

                $Result = Invoke-WebRequest -UseBasicParsing -Uri $URL -Headers $Headers -Method Post -Body $body -ContentType "application/json"
                $Content = ($Result.Content | ConvertFrom-Json).result
                $Output += $Content.data
            }
            Until ($Output.count -ge $TotalCount)
        }
        Return $Output
    }
    else {
        Throw "REST call to $URL failed. `n Exception: $($Result.StatusCode) - $($Result.StatusDescription)"
    }
}