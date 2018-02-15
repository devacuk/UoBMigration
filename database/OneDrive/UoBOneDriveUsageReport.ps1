
dont use this need to sutover to new report


<#  
    .SYNOPSIS
    script to generate the Onedrive usage table for a tenant. needs to run on migration server
    .DESCRIPTION
    as it needs powershell > 2 wont run on a SharePoint 2010 WFE    
    you need to supply these parameters, examples in quotes    
    -Server "SP-MIG-xxxx\xxxxxx" `
    -Database  "SPMigration" `
    -uid "university\xxxxxx" `
    -pwd "xxx" `
    -force $TRUE `
    -setCredential $false `
    -truncate $true `
    -LDAPPassword "xx" `
    -admin "migadmin@xxxxxx.onmicrosoft.com" `
    -pass "xxx$" `
    -mysiteHost "https://xxxxxx-my.sharepoint.com" 
    .EXAMPLE
    .\uobonedriveusagereport.ps1 -Server "SP-MIG-xxxx\xxxxxx" `
    -Database  "xxxx" `
    -uid "xxxx\xxxxx" `
    -pwd "xxxxx" `
    -force $TRUE `
    -setCredential $false `
    -truncate $true `
    -LDAPPassword "xxxx" `
    -admin "xxxx@xxxxx.onmicrosoft.com" `
    -pass "xxxxx$" `
    -mysiteHost "https://xxxx-my.sharepoint.com"
    .NOTES
    Author : Tristian O'Brien - t.xxxxxx@xxxxxx.ac.uk
    Version:        1.1
    Creation Date:  8/2/2018
    Change Date: 9/2/2018
    Purpose/Change: halndel users that have no email address
    .LINK
    https://itwiki.xxxxxxx.ac.uk/migration

#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory=$True,Position=1)]
    [string]$Server,
    [Parameter(Mandatory=$True)]
    [string]$Database, 
    [Parameter(Mandatory=$True)]
    [string]$uid, 
    [Parameter(Mandatory=$True)]
    [string]$pwd, 
    [Parameter(Mandatory=$True)]
    [bool]$force, 
    [Parameter(Mandatory=$True)]
    [bool]$setCredential,
    [Parameter(Mandatory=$True)]
    [bool]$truncate,
    [Parameter(Mandatory=$True)]
    [string]$LDAPPassword,    
    [Parameter(Mandatory=$True)]
    [string]$admin,
    [Parameter(Mandatory=$True)]
    [string]$pass,
    [Parameter(Mandatory=$True)]
    [string]$mysiteHost
)
Import-Module dbatools
Clear-Host

$securePass = $(convertto-securestring $pass -asplaintext -force)
## this will prompt - no good for a scheduled script  $pass=Read-Host "Enter Password: " -AsSecureString 
$global:truncateToggle = $truncate
$ExportToCSV=$true
$CSVPath="C:\migration\database\OneDrive\test.csv"
$Table = "OneDrive"
$dbcred = New-Object -TypeName System.Management.Automation.PSCredential -argumentlist $uid, $(convertto-securestring $pwd -asplaintext -force)
$spocred = New-Object -TypeName System.Management.Automation.PSCredential -argumentlist $admin, $securePass

# Vadim Gremyachev's method. It is briliant

Function Invoke-LoadMethod() {
param(
   [Microsoft.SharePoint.Client.ClientObject]$Object = $(throw "Please provide a Client Object"),
   [string]$PropertyName
) 
   $ctx = $Object.Context
   $load = [Microsoft.SharePoint.Client.ClientContext].GetMethod("Load") 
   $type = $Object.GetType()
   $clientLoad = $load.MakeGenericMethod($type) 


   $Parameter = [System.Linq.Expressions.Expression]::Parameter(($type), $type.Name)
   $Expression = [System.Linq.Expressions.Expression]::Lambda(
            [System.Linq.Expressions.Expression]::Convert(
                [System.Linq.Expressions.Expression]::PropertyOrField($Parameter,$PropertyName),
                [System.Object]
            ),
            $($Parameter)
   )
   $ExpressionArray = [System.Array]::CreateInstance($Expression.GetType(), 1)
   $ExpressionArray.SetValue($Expression, 0)
   $clientLoad.Invoke($ctx,@($Object,$ExpressionArray))
}


function Get-SPOWeb
{
<#
    .link
    http://social.technet.microsoft.com/wiki/contents/articles/32334.sharepoint-online-spomod-cmdlets-resources.aspx
    thanks to Arleta Wanat (MVP, Microsoft Community Contributor) and Vadim Gremyachev's
#>
param (
        [Parameter(Mandatory=$true,Position=1)]
		[string]$Username,
		[Parameter(Mandatory=$true,Position=2)]
		[string]$Url,
        [Parameter(Mandatory=$true,Position=3)]
		$AdminPassword

		)
  
  # Connecting to particular personal site
  $ctx=New-Object Microsoft.SharePoint.Client.ClientContext($Url)
  $ctx.Credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($Username, $AdminPassword)
  $ctx.Load($ctx.Web)
  $ctx.Load($ctx.Site)
  $errorMessage=""
  try
  {
  $ctx.ExecuteQuery()
  }
  catch [Net.WebException]
  {
    $errorMessage=$_.Exception.ToString()
  }
  
  # loading usage data for the site
  Invoke-LoadMethod -Object $ctx.Site -PropertyName "Usage"
  try {
    $ctx.ExecuteQuery()
    $outputty=1099511627776-$ctx.Site.Usage.Storage
  } catch {
    #we know this may happen as the onedrive doesnt have a secondary admin?, we'll address later on
  }
  if(!$ctx.Site.Usage.StoragePercentageUsed -eq 0)
  {
  $storageAvailable=$ctx.Site.Usage.Storage/$ctx.Site.Usage.StoragePercentageUsed /1GB 
  }

  # User output, feel free to modify the message content
    if($storageAvailable -ne $null)
  {
  Write-Host "Storage available: " $storageAvailable " GB"
  Write-Host "Storage: " $ctx.Site.Usage.Storage
  Write-Host "Percentage used: "  $ctx.Site.Usage.StoragePercentageUsed

  Write-Host "Storage free: " $outputty
  }
  else
  {
  Write-Host "Failed" -ForegroundColor Red
  }
  
  if($ExportToCSV)
  {
  if($storageAvailable -ne $null)
  {
     
     $obj = New-Object PSObject
     $obj | Add-Member NoteProperty Url($Url)
     $obj | Add-Member NoteProperty StorageAvailable($storageAvailable.ToString()+" GB")
     $obj | Add-Member NoteProperty Storage($ctx.Site.Usage.Storage)
     $obj | Add-Member NoteProperty PercentageUsed($ctx.Site.Usage.StoragePercentageUsed)
     $obj | Add-Member NoteProperty FreeStorage($outputty)
     $obj | Add-Member NoteProperty Failed("n/a")
   }


     if($storageAvailable -eq $null)
  {

     $DBNull = [System.DBNull]::Value 
     <#$obj = New-Object PSObject
     $obj | Add-Member NoteProperty Url($Url)
     $obj | Add-Member NoteProperty StorageAvailable($dbnull)
     $obj | Add-Member NoteProperty Storage($DBNull)
     $obj | Add-Member NoteProperty PercentageUsed($DBNull)
     $obj | Add-Member NoteProperty FreeStorage($DBNull)
     $obj | Add-Member NoteProperty Failed($errorMessage)#>
    $obj = New-Object PSObject
     $obj | Add-Member NoteProperty Url($Url)
     $obj | Add-Member NoteProperty StorageAvailable(0)
     $obj | Add-Member NoteProperty Storage(0)
     $obj | Add-Member NoteProperty PercentageUsed(0)
     $obj | Add-Member NoteProperty FreeStorage(0)
     $obj | Add-Member NoteProperty Failed($errorMessage)
   }
  
  if ($setCredential -eq $true) {      

     
        if ($force -eq $true) {             
            Write-SqlTableData -serverInstance $Server -database $Database -TableName $Table -SchemaName dbo -InputData $obj -force -Credential $cred 
            $force = $false
        } else {
            if ($truncateToggle -eq $true) {
                Invoke-Sqlcmd -Query "TRUNCATE TABLE onedrive" -ServerInstance $Server -database $Database -Credential $cred 
                $global:truncateToggle = $false
            } 
            Write-SqlTableData -serverInstance $Server -database $Database -TableName $Table -SchemaName dbo -InputData $obj -PassThru -Credential $cred
        }                
    } else {

        if ($force -eq $true) {             
            Write-SqlTableData -serverInstance $Server -database $Database -TableName $Table -SchemaName dbo -InputData $obj -force  
            $force = $false
        } else {
            if ($global:truncateToggle -eq $true) {
                Invoke-Sqlcmd -Query "TRUNCATE TABLE onedrive" -ServerInstance $Server -database $Database   
                $global:truncateToggle = $false
            } 
            Write-SqlTableData -serverInstance $Server -database $Database -TableName $Table -SchemaName dbo -InputData $obj -PassThru 
        }
    }
    
   Export-Csv -InputObject $obj -Path $CSVPath -Append -Force
   }

    $ctx.Dispose()
}










# Paths to SDK. Please verify location on your computer.
try {
    Add-Type -Path "c:\Program Files\Common Files\microsoft shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll" 
    Add-Type -Path "c:\Program Files\Common Files\microsoft shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll" 
} catch {
    Write-Host "is the SharePoint Online Management Shell installed?" -ForegroundColor Yellow -BackgroundColor Red
    break
}


$adminCenter=$mysiteHost.Replace("-my","-admin")
##$spocred = New-Object -TypeName System.Management.Automation.PSCredential -argumentlist $admin, $pass
Connect-SPOService -Url $adminCenter -Credential $spoCred


#Get all the users will take looong time
#$users=(Get-SPOUser -Site $mysiteHost -Limit ALL).LoginName 
#to test 
$users=(Get-SPOUser -Site $mysiteHost).LoginName 

foreach($uss in $users)
{
    # Transforming users to personal urls. 
    # There are better ways to retrieve personal urls, but somehow this always turns out to work best for me, so it's a personal choice

    if ($uss.contains("urn:spo") -eq $false) {        
        $uss=$uss.Replace(".","_").Replace("@","_")
        $sitey=$mysiteHost+"/personal/"+$uss
        if($sitey.Contains("ylo00")){continue;}
        Write-Host "Processing "$sitey
        Get-SPOWeb -Username $admin -Url $sitey -AdminPassword $securepass
    }
}