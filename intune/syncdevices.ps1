﻿#ProActive
#Jonas Bøgvad @ jbo@proactive.dk @ https://www.linkedin.com/in/jonas-b%C3%B8gvad-a7803675/
#v1.0 18/02-2021
$Title = "Welcome"
$Info = "Choose a platform to sync"
  
$options = [System.Management.Automation.Host.ChoiceDescription[]] @("&Windows", "&Android", "&IOS/iPadOS" , "&Quit")
[int]$defaultchoice = 3
$opt = $host.UI.PromptForChoice($Title , $Info , $Options,$defaultchoice)
switch($opt)
{
0 { Write-Host "Windows" -ForegroundColor Green
$choice = "Windows"
}
1 { Write-Host "Android" -ForegroundColor Green
$choice = "Android"
}
2 {Write-Host "IOSIPADOS" -ForegroundColor Green
$choice = "iOS"
}
3 {Write-Host "Good Bye!!!" -ForegroundColor Green
$choice = $null
}
}
if ($choice -ne $null)
{
$IntuneModule = Get-Module -Name "Microsoft.Graph.Intune" -ListAvailable
if (!$IntuneModule){
 
write-host "Microsoft.Graph.Intune Powershell module not installed..." -f Red
write-host "Install by running 'Install-Module Microsoft.Graph.Intune' from an elevated PowerShell prompt" -f Yellow
write-host "Script can't continue..." -f Red
write-host
exit
}
####################################################
# Importing the SDK Module
Import-Module -Name Microsoft.Graph.Intune
 
if(!(Connect-MSGraph)){
Connect-MSGraph
}
####################################################
 
#### Insert your script here
 
#### Gets all devices running platform chosen


$Devices = Get-IntuneManagedDevice -Filter "contains(operatingsystem,'$choice')" | Get-MSGraphAllPages
 
Foreach ($Device in $Devices)
{
 
Invoke-IntuneManagedDeviceSyncDevice -managedDeviceId $Device.managedDeviceId | Get-MSGraphAllPages
Write-Host "Sending Sync request to Device with DeviceID $($Device.managedDeviceId)" -ForegroundColor Yellow
 
}
}
