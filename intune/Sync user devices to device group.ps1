#https://www.lee-ford.co.uk/graph-api-paging/
# GraphAPIPaging.ps1
# Example script on paging with Graph API

### Authenticate ###
# Application (client) ID, tenant ID and secret
$clientId = ""
$tenantId = ""
$clientSecret = ''
#9a5eb988-3868-4d90-b004-c20d56b9dc67

# Construct URI
$uri = "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token"

# Construct Body
$body = @{
    client_id     = $clientId
    scope         = "https://graph.microsoft.com/.default"
    client_secret = $clientSecret
    grant_type    = "client_credentials"
}

# Get OAuth 2.0 Token
$tokenRequest = Invoke-WebRequest -Method Post -Uri $uri -ContentType "application/x-www-form-urlencoded" -Body $body -UseBasicParsing

# Access Token
$token = ($tokenRequest.Content | ConvertFrom-Json).access_token


### Query ###
$Headers = @{"Authorization" = "Bearer $token" }


$currentUri = "https://graph.microsoft.com/v1.0/groups/dbe70fef-40c4-454a-b9c6-6398ec96f157/members"

$content = while (-not [string]::IsNullOrEmpty($currentUri)) {

    # API Call
    Write-Host "`r`nQuerying $currentUri..." -ForegroundColor Yellow
    $apiCall = Invoke-WebRequest -Method "GET" -Uri $currentUri -ContentType "application/json" -Headers $Headers -ErrorAction Stop
    
    $nextLink = $null
    $currentUri = $null

    if ($apiCall.Content) {

        # Check if any data is left
        $nextLink = $apiCall.Content | ConvertFrom-Json | Select-Object '@odata.nextLink'
        $currentUri = $nextLink.'@odata.nextLink'

        $apiCall.Content | ConvertFrom-Json

    }

}
#Authentication with paging done

#https://graph.microsoft.com/v1.0/users/$user/ownedDevices
#https://docs.microsoft.com/en-us/graph/api/group-list-members?view=graph-rest-1.0&tabs=http


<#$content. | ForEach {
    $_.attributes | Add-Member -MemberType NoteProperty -Name "id" -Value $_.id
    $_.attributes | Add-Member -MemberType NoteProperty -Name "Enrollmentstate" -Value $_.enrollmentstate
}
$content.attributes | Export-Csv -Path C:\IP.csv -NoTypeInformation
#>

$users = $content.value

foreach ($user in $users)
{
$UPN = $user.userPrincipalName


$currentUri = "https://graph.microsoft.com/v1.0/users/$UPN/ownedDevices?$filter=eq(operatingSystem,'Windows')"

$content = while (-not [string]::IsNullOrEmpty($currentUri)) {

    # API Call
    Write-Host "`r`nQuerying $currentUri..." -ForegroundColor Yellow
    $apiCall = Invoke-WebRequest -Method "GET" -Uri $currentUri -ContentType "application/json" -Headers $Headers -ErrorAction Stop
    
    $nextLink = $null
    $currentUri = $null

    if ($apiCall.Content) {

        # Check if any data is left
        $nextLink = $apiCall.Content | ConvertFrom-Json | Select-Object '@odata.nextLink'
        $currentUri = $nextLink.'@odata.nextLink'

        $apiCall.Content | ConvertFrom-Json

   }
}

$devices = $content.value

foreach ($device in $devices)
{
$currentUri = "https://graph.microsoft.com/v1.0/groups/b4998701-baa4-46ed-a9f0-e14e86e9ad40/members/`$ref"
if ($device.operatingSystem -eq "Windows")
{
$DEVICETOADD = $device.id
$DEVICENAME = $device.displayName
 #https://euc365.com/add-devices-to-an-azure-ad-group-using-the-microsoft-graph-api/
        
        $Body = @{
            "@odata.id"="https://graph.microsoft.com/v1.0/devices/$DEVICETOADD"
        } | ConvertTo-Json
 

# API Call
Write-Host "`r`nQuerying $currentUri..." -ForegroundColor Yellow
Invoke-RestMethod -Method POST -Uri $currentUri -Headers $Headers -ContentType "application/json" -Body $body 
#Invoke-RestMethod -Uri $currentUri -Headers $authToken -Method Post -Body $JSON -ContentType "application/json"

Write-Host -ForegroundColor Green "Tilføjer $DEVICENAME til gruppen - Bruger $UPN"

}
}
}
