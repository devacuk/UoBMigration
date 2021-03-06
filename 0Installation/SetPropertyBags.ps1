##
#inspired by https://ramanselva.wordpress.com/2014/06/07/configuration-values-in-sharepoint-2010-timer-job/
#set the three property bags for a given environment
#run this on a web front end - it will not work on the migration server!!
<#  
    .SYNOPSIS
    set timer job property bag values at the central admin scope
    .DESCRIPTION
    we need some config entries for say the length of time to check passed to delete 
    mysite doclibs (not the profiles themselves)
    you need to supply these parameters, examples in quote
    -centralAdminUri
    -mysiteuri
    -uobmigrationperiodcheckweeks
    -uobmigrationarmed
    -recycleordelete  
    .EXAMPLE
    .\SetPropertyBags.ps1 -centralAdminUri "http://xxxxxx.xxxxxx.ac.uk/user" `
    -mysiteuri "http://xxxxxx.xxxxxxx.ac.uk" `
    -uobmigrationperiodcheckweeks "6" `
    -uobmigrationarmed "true" `
    -recycleordelete "recycle"
    .NOTES
    Author : Tristian O'Brien - t.xxxxxx@xxxxxxx.ac.uk
    Version:        1.0
    Creation Date:  4/1/2018
    Change Date: n/a
    Purpose/Change: n/a
    .LINK
    https://xxxxx.xxxxxxxx.ac.uk/migration

#>




[CmdLetBinding()]
Param(
    [Parameter(Mandatory=$True,Position=1)]
    [string]$centralAdminUri, #http://server:51015 | https://mysite.xxxxxxx.ac.uk
    [Parameter(Mandatory=$True)]
    [string]$mysiteuri, #http://xxxxxx.xxxxxxx.ac.uk | http://xxxxx.xxxxxxxx.ac.uk
    [Parameter(Mandatory=$True)]
    [string]$uobmigrationperiodcheckweeks, #6
    [Parameter(Mandatory=$True)]
    [string]$uobmigrationarmed, #arm meaning mysite will be deleted, set to true to arm!
    [Parameter(Mandatory=$True)]
    [string]$recycleordelete #recycle | delete    
)

cls
$snapin = Get-PSSnapin | Where-Object {$_.Name -eq ‘Microsoft.SharePoint.Powershell’}

if ($snapin -eq $null) {
    Write-Output "Loading SharePoint Powershell Snapin"
    Add-PSSnapin "Microsoft.SharePoint.Powershell"
}

if ($snapin -eq $null) {
    Write-Host -foregroundcolor red -backgroundcolor yellow "You did bad... you're not running this from a SharePoint 2010 web server are you!?"
    break
}

Write-Output "Task initialized…"

###todo make this a function passing the above 
function Set-PropertyBag($name, $value) {    
    $url= [System.Web.HttpUtility]::UrlDecode($centralAdminUri)
    $site = New-Object Microsoft.SharePoint.SPSite($url)
    $rootWeb = $site.RootWeb
    Write-Host -foregroundcolor Green "The current Site"$rootWeb
    $PropertyKey = $name
    $webvalue = $value
    $PropertyValue = [System.Web.HttpUtility]::UrlDecode($webvalue)   
    try {
        $rootWeb.AllowUnsafeUpdates = $true;
    } catch {
        throw "You did bad... you're not running this from a SharePoint 2010 web server are you!?"
        break
    }
    $Currentvalue = $rootWeb.Properties[$PropertyKey]
    Write-Host -foregroundcolor Green "The current value of the property bag $PropertyKey is "$Currentvalue

    if (!$rootWeb.Properties.ContainsKey($PropertyKey))
    {
        $rootWeb.Properties.Add($PropertyKey, $PropertyValue);
    }
    else
    {
        $rootWeb.Properties[$PropertyKey] = $PropertyValue;
    }

    $rootWeb.Properties.Update();
    $rootWeb.Update();
    $rootWeb.AllowUnsafeUpdates = $false;

    $UpdatedValue =  $rootWeb.Properties[$PropertyKey]
    Write-Host -foregroundcolor Green "Value of the property bag PropertyKey is updated with " $UpdatedValue
    if ($rootWeb -ne $null)
    {
        $rootWeb.Dispose()

    }
    If ($site -ne $null)
    {
        $site.Dispose();
    }

    Write-Host -foregroundcolor Green "Script has finished executing "
    Write-Output "Task completed…"
}

#bag it up!
Set-PropertyBag  "mysiteuri" $mysiteuri 
Set-PropertyBag  "uobmigrationperiodcheckweeks" $uobmigrationperiodcheckweeks
Set-PropertyBag  "uobmigrationarmed" $uobmigrationarmed 
Set-PropertyBag  "recycleordelete" "$recycleordelete" 





