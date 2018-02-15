<#  
    .SYNOPSIS
    Carries out pre tasks. run this for a mapping file before running the migration cmdlet
    .DESCRIPTION
    for a mapping file of users, this will swap the v4.master for migration master for the users mysite.  
    users mysite then set to read only
    the migration.master file needs to be in the same directory as this script
    you need to supply these parameters, examples in quote
    -onPremiseMysiteURIPart "https://mysite.brighton.ac.uk/user"     
    -sourcePasswordPlain "opensesame"
    -onPremiseAdministratorAdminAccount "UNIVERSITY\sap9" 
    -sourceListName "MyFiles"
    -domain "UNIVERSITY"
    .EXAMPLE
    .\prerequisites.ps1 -onPremiseMysiteURIPart "http://mysitepp.brighton.ac.uk/user" `
    -sourcePasswordPlain "Sherpoint/Fahm/Pree" `
    -sourceListName "Personal Documents" `
    -domain "UNIVERSITY" `
    -csvPath "\usermapping\UsersToMigrate.csv" `
    -migrationfolder  "\\sp-mig-dev01\c$\migration" 
    .NOTES
    Author : Tristian O'Brien - t.obrien2@brighton.ac.uk
    Version:        2.3
    Creation Date:  20th October 2017
    Change Date: 18th December 2017
    Purpose/Change: Added domain paramater, caught exception if run from the wrong type of server fixed some errors and missing documentation
    .LINK
    https://itwiki.brighton.ac.uk/migration

#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory=$True,Position=1)]
    [string]$onPremiseMysiteURIPart,  #https://mysite.brighton.ac.uk/user    "http://mysite.dev.brighton.ac.uk/user"
    [Parameter(Mandatory=$True)]
    [string]$sourcePasswordPlain, #Farum/Pr0dd/Adminnn    "Tibhec3v"
    [Parameter(Mandatory=$True)]
    [string]$migrationFolder  , #"\\sp-mig-dev01\c$\migration\"
    [Parameter(Mandatory=$True)]
    [string]$sourceListName, #"Personal Documents",
    [Parameter(Mandatory=$True)]
    [string]$domain #"UNIVERSITY" or "UNIDEV"
)
Add-PSSnapin microsoft.sharepoint.powershell -ErrorAction SilentlyContinue #needed for local SharePoint cmdlets
clear 
$username = @()
$o365login = @()
$department = @()
$o365urlpart = @()
$adminusername = "$o365AdminAccount"
$csvPath = $migrationFolder+"usermapping\UsersToMigrate.csv"

Import-Csv $csvPath -Delimiter "|" | ForEach-Object {
    
    
    $username = $_.username
    $securesrcpassword = ConvertTo-SecureString "$sourcePasswordPlain" -AsPlainText -Force
    write-host "username $username" -BackgroundColor Black -ForegroundColor Cyan
    #upload migration.master
    $WebURL = "$onPremiseMysiteURIPart/$username"
    $MasterPage = "Migration.master"
    $SourcePath =$migrationFolder+"1PreRequisites\Migration.master"    
    try {
        
  
        #Get the Web
        try {
            $web = Get-SPWeb $WebURL     
        } catch {
            Write-Host  -foregroundcolor red -backgroundcolor yellow "Are you sure you are running this on a server joined to a SharePoint 2010 farm and not the migration server!?!"
            Exit 999999
        }
        $web.Site.ReadOnly = $false
        #Get the Target folder - Master page Gallery
        $MasterPageList = $web.GetFolder("Master Page Gallery")     
        #Set the Target file for Master page
        $MasterPagePath = "/_catalogs/masterpage/Migration.master"
        $MasterPageURL = $Web.Url + $MasterPagePath     
        #Get the Master page from local disk
        $MasterPageFile = (Get-ChildItem $SourcePath).OpenRead()    

        $web.masterurl = "/user/$username/_catalogs/masterpage/v4.master"
        $web.Update()
             
        #Check if file exist already
        if ($Web.GetFile($MasterPageURL).Exists)
        {
            try {
                $Web.GetFile($MasterPageURL).recycle() 
            } catch {
                #ignore error
            }
        }     

        #upload master page using powershell
        try {
            $MasterPage = $MasterPageList.Files.Add($MasterPageURL,$MasterPageFile,$false)      
            $web.Update()
        } catch {
            #ignore error
        }
        #Set Default and Custom Master pages
        #####$web.MasterUrl = "/_catalogs/masterpage/v4.master" #$MasterPagePath
        $web.masterurl = "/user/$username/_catalogs/masterpage/Migration.master"
        #not relevant since we're not using publishing? $web.CustomMasterUrl = $MasterPagePath
        $web.Site.ReadOnly = $true
        #Apply Changes
        $web.Update()
        $web.Dispose()
    } catch {
        Write-Host "perhaps there is no site there for $username"
    }
}




function Get-ScriptDirectory
{
    Split-Path $script:MyInvocation.MyCommand.Path
}