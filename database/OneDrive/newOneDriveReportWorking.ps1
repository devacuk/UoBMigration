# this was useful http://www.nubo.eu/en/blog/2017/03/Retrieving-SPO-Sites-With-Powershell/
<#  
    .SYNOPSIS
    script to generate the Onedrive usage table for a tenant. needs to run on migration server
    .DESCRIPTION
    as it needs powershell > 2 wont run on a SharePoint 2010 WFE   
    this replaces a older script that used an older more fiddly API 
    you need to supply these parameters, examples in quotes    
    -Server "SP-MIG-xxxx\xxxxxx" `
    -Database  "SPMigration" `
    -uid "university\xxxxxx" `
    -pwd "xxx" `
    -force $TRUE `
    -setCredential $false `
    -truncate $true `
    -LDAPPassword "xx" `
    -admin "xxxxxxx@xxxxxxx.onmicrosoft.com" `
    -pass "xxx$" `
    -mysiteHost "https://xxxxxx-my.sharepoint.com" 
    .EXAMPLE
    .\uobonedriveusagereport.ps1 -Server "SP-MIG-xxxxxx\xxxxxxx" `
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
    Version:        1.0
    Creation Date:  14/2/2018
    Change Date: 
    Purpose/Change: 
    .LINK
    https://itwiki.xxxxxx.ac.uk/migration

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

Import-Module Microsoft.Online.SharePoint.Powershell
$tenantName = "xxxxxx"
Import-Module dbatools
Clear-Host
$securePass = $(convertto-securestring $pass -asplaintext -force)
$CSVPath="C:\migration\database\OneDrive\test.csv"
$Table = "OneDrive"
$dbcred = New-Object -TypeName System.Management.Automation.PSCredential -argumentlist $uid, $(convertto-securestring $pwd -asplaintext -force)
$spocred = New-Object -TypeName System.Management.Automation.PSCredential -argumentlist $admin, $securePass
$adminCenter=$mysiteHost.Replace("-my","-admin")
Connect-SPOService -Url $adminCenter -Credential $spoCred
$sites = Get-SPOSite -Filter { Url -like '*-my.sharepoint.com*' }  -Limit All -IncludePersonalSite $true
foreach ($site in $sites) {

    Write-Host $site.Url
    write-host $site.StorageUsageCurrent
    write-host $site.StorageQuota


    $obj = New-Object PSObject
    $obj | Add-Member NoteProperty Url($site.Url)
    $obj | Add-Member NoteProperty StorageAvailable($site.StorageQuota)
    $obj | Add-Member NoteProperty Storage($site.StorageUsageCurrent)
  

    if ($setCredential -eq $true) {      

     
            if ($force -eq $true) {             
                Write-SqlTableData -serverInstance $Server -database $Database -TableName $Table -SchemaName dbo -InputData $obj -force -Credential $cred 
                $force = $false
            } else {
                if ($truncate -eq $true) {
                    Invoke-Sqlcmd -Query "TRUNCATE TABLE onedrive" -ServerInstance $Server -database $Database -Credential $cred 
                    $truncate = $false
                } 
                Write-SqlTableData -serverInstance $Server -database $Database -TableName $Table -SchemaName dbo -InputData $obj -PassThru -Credential $cred
            }                
        } else {

            if ($force -eq $true) {             
                Write-SqlTableData -serverInstance $Server -database $Database -TableName $Table -SchemaName dbo -InputData $obj -force  
                $force = $false
            } else {
                if ($truncate -eq $true) {
                Invoke-Sqlcmd -Query "TRUNCATE TABLE onedrive" -ServerInstance $Server -database $Database   
                $truncate = $false
            } 
            Write-SqlTableData -serverInstance $Server -database $Database -TableName $Table -SchemaName dbo -InputData $obj -PassThru 
        }
    }
    
    Export-Csv -InputObject $obj -Path $CSVPath -Append -Force
}


