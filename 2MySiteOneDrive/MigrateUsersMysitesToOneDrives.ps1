<#  
    .SYNOPSIS
    Usinf ShareGet Powershell addin we migrate users based upon a mapping file from source to destination
    Must be run on a server that has ShareGate, SharePoint online cmdlets, cannot be run on a SharePoint 2010 web front end
    .DESCRIPTION
    you need to supply these parameters, examples in quote
        -onPremiseMysiteURIPart "http://mysite.dev.brighton.ac.uk" `
        -o365OnedriveURIPart "https://liveateduevalbrightonac-my.sharepoint.com/personal" `
        -sourcePasswordPlain "Tibhec3v" `
        -destinationPasswordPlain "In2theCl0ud$" `
        -onPremiseAdministratorAdminAccount "UNIDEV\sad6" `
        -o365AdminAccount "migadmin@liveateduevalbrightonac.onmicrosoft.com" `
        -destinationListName "Documents" `
        -sourceListName "Personal Documents" `
        -iterations 1 `
        -check "PreCheckAndMigrate" `
        -domain "UNIDEV"
    .EXAMPLE
    MigrateUsersMysitesToOneDrives.ps1 -onPremiseMysiteURIPart "https://mysite.brighton.ac.uk/user" -o365OnedriveURIPart "https://brightondev-my.sharepoint.com/personal" -sourcePasswordPlain "Farum/Pr0dd/Adminnn" -destinationPasswordPlain "RutlesBeatles6" -onPremiseAdministratorAdminAccount  "UNIVERSITY\sap9" -o365AdminAccount "admin@brightondev.onmicrosoft.com" -destinationListName "Documents" -sourceListName "MyFiles"
    .NOTES
    Author : Tristian O'Brien - t.obrien2@brighton.ac.uk
    Version:        1.0
    Creation Date:  20th October 2017
    Purpose/Change: University of Brighton OneDrive migrations
    .LINK
    https://itwiki.brighton.ac.uk/migration

#>
[CmdLetBinding()]
Param(
    [Parameter(Mandatory=$True,Position=1)]
    [string]$onPremiseMysiteURIPart,#https://mysite.brighton.ac.uk
    [Parameter(Mandatory=$True)]
    [string]$o365OnedriveURIPart, #https://brightondev-my.sharepoint.com/personal
    [Parameter(Mandatory=$True)]
    [string]$sourcePasswordPlain, #Farum/Pr0dd/Adminnn
    [Parameter(Mandatory=$True)]
    [string]$destinationPasswordPlain, #RutlesBeatles6
    [Parameter(Mandatory=$True)]
    [string]$onPremiseAdministratorAdminAccount, #UNIVERSITY\sap9
    [Parameter(Mandatory=$True)]
    [string]$o365AdminAccount, #admin@brightondev.onmicrosoft.com
    [Parameter(Mandatory=$True)]
    [string]$destinationListName, #Documents or perhaps MyFiles
    [Parameter(Mandatory=$True)]
    [string]$sourceListName, #MyFiles
    [Parameter(Mandatory=$True)]
    [int]$iterations=1,
    [Parameter(Mandatory = $True)]
    [ValidateNotNullOrEmpty()]
    [ValidateSet('PreCheckOnly', 'PreCheckAndMigrate', 'Migrate', 'PreserveTimeStamps')]
    [String]$check,
    [Parameter(Mandatory=$True)]
    [string]$domain #"UNIVERSITY" or "UNIDEV"
)

Import-Module Sharegate
Clear-Host  

function new-SPOnlineList ($user) {
    #$userName = $user.o365login
    $o365urlpart = $user.o365urlpart
    $mysitewebUrl = "$o365OnedriveURIPart/$o365urlpart";
    $listTitle = "$destinationListName"
    $listDescription = "xxx for now xxx"
    $listTemplate = 101 ##document library

    # Let the user fill in their password in the PowerShell window
    $password = ConvertTo-SecureString "$destinationPasswordPlain" -AsPlainText -Force

    # set SharePoint Online credentials
    $SPOCredentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($adminusername, $password)

    # Creating client context object
    $context = New-Object Microsoft.SharePoint.Client.ClientContext($mysitewebUrl)
    $context.credentials = $SPOCredentials

    #create list using ListCreationInformation object (lci)
    $lci = New-Object Microsoft.SharePoint.Client.ListCreationInformation
    $lci.title = $listTitle
    $lci.description = $listDescription
    $lci.TemplateType = $listTemplate
    $list = $context.web.lists.add($lci)
    $context.load($list)
    #send the request containing all operations to the server
    try{
        $context.executeQuery()
        write-host "info: Created $($listTitle)" -foregroundcolor green
    }
    catch{
        write-host "info: $($_.Exception.Message)" -foregroundcolor red
    }  
}

function enableLinkToDocumentContentType ($user) {
    #variables that needs to be set before starting the script
    ####$siteURL = $mysitewebUrl
    ####$adminUrl = $mysitewebUrl
    #$userName = $user.o365login
    $o365urlpart = $user.o365urlpart
    $mysitewebUrl = "$o365OnedriveURIPart/$o365urlpart";
    $listTitle = "$destinationListName"
    $password = ConvertTo-SecureString "$destinationPasswordPlain" -AsPlainText -Force
    $SPOCredentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($adminusername, $password)
    # Creating client context object
    $context = New-Object Microsoft.SharePoint.Client.ClientContext($mysitewebUrl)
    $context.credentials = $SPOCredentials    
    $list = $context.Web.Lists.GetByTitle("$destinationListName")   
    $contentType = $context.Web.ContentTypes.GetById("0x01010A")

    $context.load($contentType)
    $context.load($list)
    $context.load($list.ContentTypes)
    #send the request containing all operations to the server
    try{
        $context.executeQuery()
        $list.ContentTypesEnabled = "True"     
        #add content type to the list http://www.sharepointfire.com/2016/01/add-content-type-sharepoint-online-list-powershell/       
        $addct = $list.ContentTypes.AddExistingContentType($contentType)
        $list.Update()
        $context.executeQuery()
        write-host "info: Added Content Typeto $($listTitle)" -foregroundcolor green
    }
    catch{
        write-host "info: $($_.Exception.Message)" -foregroundcolor red
    }  
}

function TimeStampUserProfile {
    $proxy = New-WebServiceProxy "$onPremiseMysiteURIPart/_vti_bin/userprofileservice.asmx" -UseDefaultCredential
    $account = "{0}\{1}" -f $domain, $username
    #$userProperty = $upws.GetUserPropertyByAccountName($account,'Migrated')      
    $type = $proxy.getType().namespace
    $datatype = ($type + '.PropertyData')
    $datatype
    $NewData = New-Object ($datatype)
    $NewData.IsPrivacyChanged = $false
    $NewData.Privacy = "Public"
    $NewData.IsValueChanged = $true
    $NewData.Name = "uob-migrated"
    $NewDataValues = New-Object ($type + '.ValueData')
    $NewDataValues.Value=Get-Date
    $NewData.Values = $NewDataValues
    $NewData

    if($proxy -ne $null){            
        try{                    
            $data = $proxy.ModifyUserPropertyByAccountName($account, $NewData)             
        }            
        catch{             
            Write-Error $_ #-ErrorAction:'SilentlyContinue'            
        }            
    }

}


$username = @()
$o365login = @()
$department = @()
$o365urlpart = @()
$adminusername = "$o365AdminAccount"
$thisPath = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
$journalfile = "$thisPath\journal$(get-date -f yyyyMMdd).txt"
$timestamp = Get-Date
write-host "Started at $timestamp" -BackgroundColor Black -ForegroundColor Yellow
Out-File -FilePath $journalfile -InputObject "Started at $timestamp" -encoding ascii
write-host "Iterations set to $iterations" -BackgroundColor DarkGreen -ForegroundColor Green
Out-File -FilePath $journalfile -InputObject "Iterations set to $iterations" -encoding ascii -Append
#prime header row of output csv
$row = "username"
1..$iterations | % { 
    $row = $row + ",t$_,time$_"
}
###$row = $row +"`r`n"
#write-host $row

switch ($check)
{
    'PreCheckOnly' {                 
        $outfile = "$thisPath\precheckonlytimes$(get-date -f yyyyMMdd).txt"                                
    }
    'PreCheckAndMigrate' {                
        $outfile = "$thisPath\precheckandmigrationtimes$(get-date -f yyyyMMdd).txt"                         
    }
    default {                 
        $outfile = "$thisPath\migrationtimes$(get-date -f yyyyMMdd).txt"                
    }
}


Out-File -FilePath $outfile -InputObject $row -encoding ascii


Import-Csv $thisPath\..\usermapping\UsersToMigrate.csv -Delimiter "|" | ForEach-Object {
    $username = $_.username
    $o365login = $_.o365login
    $department = $_.department
    $o365urlpart = $_.o365urlpart

    $srcsiteurl = "$onPremiseMysiteURIPart/user/$username"
    $destsiteurl = "$o365OnedriveURIPart/$o365urlpart"
    
    $securesrcpassword = ConvertTo-SecureString "$sourcePasswordPlain" -AsPlainText -Force
    $securedestpassword = ConvertTo-SecureString "$destinationPasswordPlain" -AsPlainText -Force
    write-host "username $username" -BackgroundColor Black -ForegroundColor Cyan
    out-file -FilePath $outfile -InputObject $username -Append -NoNewline -encoding ascii
    Out-File -FilePath $journalfile -InputObject "username $username" -encoding ascii -Append

    #run migration n times to collect time    
    1..$iterations | ForEach-Object { 
        write-host "Connecting to source site... $(Get-Date)" -BackgroundColor Black -ForegroundColor Green
        Out-File -FilePath $journalfile -InputObject "Connecting to source site... $(Get-Date)" -encoding ascii -Append
        $srcsite = Connect-Site -url $srcsiteurl -UserName "$onPremiseAdministratorAdminAccount" -Password $securesrcpassword
        write-host "Connected to source site... $(Get-Date)" -BackgroundColor Black -ForegroundColor Green
        Out-File -FilePath $journalfile -InputObject "Connected to source site... $(Get-Date)" -encoding ascii -Append
        write-host "Connecting to destination site... $(Get-Date)" -BackgroundColor Black -ForegroundColor Green
        Out-File -FilePath $journalfile -InputObject "Connecting to destination site... $(Get-Date)" -encoding ascii -Append 
        $destsite = Connect-Site -url $destsiteurl -UserName $adminusername -Password $securedestpassword
        write-host "Connected to destination site... $(Get-Date)" -BackgroundColor Black -ForegroundColor Green
        Out-File -FilePath $journalfile -InputObject "Connected to destination site... $(Get-Date)" -encoding ascii -Append
    
        ##first clobber the site so that admin can access it
        ####create the destination MyFiles doclib
   
        write-host "Connecting to source list... $(Get-Date)" -BackgroundColor Black -ForegroundColor Green
        Out-File -FilePath $journalfile -InputObject "Connecting to source list... $(Get-Date)" -encoding ascii -Append
        $destlist = Get-List -Name $destinationListName -Site $destsite
        write-host "Connected to source list... $(Get-Date)" -BackgroundColor Black -ForegroundColor Green
        Out-File -FilePath $journalfile -InputObject "Connected to source list... $(Get-Date)" -encoding ascii -Append
        write-host "Connecting to destination list... $(Get-Date)" -BackgroundColor Black -ForegroundColor Green
        Out-File -FilePath $journalfile -InputObject "Connecting to destination list... $(Get-Date)" -encoding ascii -Append
        $srcList = Get-List -Name $sourceListName -Site $srcsite
        write-host "Connected to source list... $(Get-Date)" -BackgroundColor Black -ForegroundColor Green
        Out-File -FilePath $journalfile -InputObject "Connected to source list... $(Get-Date)" -encoding ascii -Append
        $timestamp = Get-Date #-Format o | foreach {$_ -replace ":", "."}
        
        switch ($check)
        {
            'PreCheckOnly' { 
                write-host "ShareGate pre migration checks only username $username and iteration $_" -BackgroundColor Black -ForegroundColor Cyan
                $outfile = "$thisPath\precheckonlytimes$(get-date -f yyyyMMdd).txt"
                $measurement = Measure-Command { 
                    write-host "Copying content... $(Get-Date)" -BackgroundColor Black -ForegroundColor Green
                    Out-File -FilePath $journalfile -InputObject "Copying content... $(Get-Date)" -encoding ascii -Append
                    Copy-List -List $srcList -DestinationSite $destsite -WhatIf #carry out a prereqcheck
                    TimeStampUserProfile
                    write-host "Copied content... $(Get-Date)" -BackgroundColor Black -ForegroundColor Green
                    Out-File -FilePath $journalfile -InputObject "Copied content... $(Get-Date)" -encoding ascii -Append   
                } 
                
            }
            'PreCheckAndMigrate' {
                write-host "ShareGate pre migration checks and migration username $username and iteration $_" -BackgroundColor Black -ForegroundColor Cyan
                $outfile = "$thisPath\precheckandmigrationtimes$(get-date -f yyyyMMdd).txt"
                $measurement = Measure-Command { 
                    write-host "Copying content... $(Get-Date)" -BackgroundColor Black -ForegroundColor Green
                    Out-File -FilePath $journalfile -InputObject "Copying content... $(Get-Date)" -encoding ascii -Append
                    Copy-List -List $srcList -DestinationSite $destsite -WhatIf #carry out a prereqcheck
                    Copy-Content -SourceList $srcList -DestinationList $destlist -InsaneMode #-Verbose                            
                    TimeStampUserProfile
                    write-host "Copied content... $(Get-Date)" -BackgroundColor Black -ForegroundColor Green
                    Out-File -FilePath $journalfile -InputObject "Copied content... $(Get-Date)" -encoding ascii -Append   
                }         
            }
            'Migrate' { 
                write-host "No ShareGate pre migration checks migration only username $username and iteration $_" -BackgroundColor Black -ForegroundColor Cyan
                $outfile = "$thisPath\migrationtimes$(get-date -f yyyyMMdd).txt"
                $measurement = Measure-Command { 
                    write-host "Copying content... $(Get-Date)" -BackgroundColor Black -ForegroundColor Green
                    Out-File -FilePath $journalfile -InputObject "Copying content... $(Get-Date)" -encoding ascii -Append
                    Copy-Content -SourceList $srcList -DestinationList $destlist -InsaneMode         
                    TimeStampUserProfile
                    write-host "Copied content... $(Get-Date)" -BackgroundColor Black -ForegroundColor Green
                    Out-File -FilePath $journalfile -InputObject "Copied content... $(Get-Date)" -encoding ascii -Append
                }
            }
            'PreserveTimeStamps' { 
                write-host "No ShareGate pre migration checks migration only and preserve timestamps: username $username and iteration $_" -BackgroundColor Black -ForegroundColor Cyan
                $outfile = "$thisPath\migrationtimes$(get-date -f yyyyMMdd).txt"
                $propertyTemplate = New-PropertyTemplate -AuthorsAndTimestamps
                $measurement = Measure-Command { 
                    write-host "Copying content... $(Get-Date)" -BackgroundColor Black -ForegroundColor Green
                    Out-File -FilePath $journalfile -InputObject "Copying content... $(Get-Date)" -encoding ascii -Append
                    try {
                        Copy-Content -SourceList $srcList -DestinationList $destlist -InsaneMode -Template $propertyTemplate      
                    } 
                    Catch
                    {
                        if ($_.FullyQualifiedErrorId -eq "ParameterArgumentValidationError,a.m.e.b.a") {
                            Write-Host "$username mysite is not working" -BackgroundColor Red -ForegroundColor Yellow
                        } else {
                            $ErrorMessage = $_.Exception.Message
                            $FailedItem = $_.Exception.ItemName
                            write-host "error" -ForegroundColor red
                        }
                    }

                    TimeStampUserProfile
                    write-host "Copied content... $(Get-Date)" -BackgroundColor Black -ForegroundColor Green
                    Out-File -FilePath $journalfile -InputObject "Copied content... $(Get-Date)" -encoding ascii -Append
                }
            }
        }
        
        $seconds = $measurement.TotalSeconds
        ####$row = $row + "," + $seconds + "," + $timestamp   
        $row = "," + $seconds + ",'" + $timestamp    + "'"
        out-file -FilePath $outfile -InputObject $row -Append -NoNewline -encoding ascii
        write-host "Update at $timestamp  took $seconds " -BackgroundColor Black -ForegroundColor Yellow      
        Out-File -FilePath $journalfile -InputObject "Update at $timestamp  took $seconds " -encoding ascii -Append
    }
    
    $row = ""
    
     
    #dont use for long running command as other things cant red the file also this appends to an existing file could use set-file 
    #Add-Content -Path "$thisPath\migrationtimes.txt" -Value $row
    #out-file -FilePath "$thisPath\migrationtimes.txt" $row
    # says not to use for long running 
    #Set-Content -Path "$thisPath\migrationtimes$(get-date -f yyyyMMdd).txt" -Value $row   
    #this seems to slow things down! Add-Content -Path Get-ScriptDirectory+"\migrationtimes.txt" -Value $row
    out-file -FilePath $outfile -InputObject $row -encoding ascii -Append
}




function Get-ScriptDirectory
{
    Split-Path $script:MyInvocation.MyCommand.Path
}

