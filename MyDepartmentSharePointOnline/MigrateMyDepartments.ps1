Import-Module Sharegate
clear 

$lanid = @()
$o365login = @()
$department = @()
$o365urlpart = @()
$iterations = 1
$adminusername = "xxxx@bxxxxxx.onmicrosoft.com"
$thisPath = Split-Path -Parent $PSCommandPath 


$outfile = "$thisPath\migrationtimes$(get-date -f yyyyMMdd).txt"
$timestamp = Get-Date
write-host "Started at $timestamp" -BackgroundColor Black -ForegroundColor Yellow
write-host "Iterations set to $iterations" -BackgroundColor DarkGreen -ForegroundColor Green
#prime header row of output csv
$row = "lanid"
1..$iterations | % { 
    $row = $row + ",t$_,time$_"
}
###$row = $row +"`r`n"
#write-host $row

Out-File -FilePath $outfile -InputObject $row -encoding ascii

Import-Csv $thisPath\SitesToMigrate.csv -Delimiter "|" | ForEach-Object {
    $sourceSiteCollection=$_.sourceSiteCollection
    $destinationSiteUri=$_.destinationSiteUri
    $destinationSiteTitle=$_.destinationSiteTitle
    $destinationSiteQuota=$_.destinationSiteQuota
    $destinationSiteOwner=$_.destinationSiteOwner
    $destinationSiteTemplate=$_.destinationSiteTemplate
    $desinationSiteDescription=$_.desinationSiteDescription
    Write-Host "sourceSiteCollection: $sourceSiteCollection"
    $srcsiteurl = "https://mydepartment.brighton.ac.uk$sourceSiteCollection"
    $destsiteurl = "https://brightondev.sharepoint.com$destinationSiteUri"
    write-host "Connecting to sites..." -BackgroundColor Black -ForegroundColor Green
    $securesrcpassword = ConvertTo-SecureString "xxxxxxxx" -AsPlainText -Force
    $securedestpassword = ConvertTo-SecureString "xxxxxxxxxx" -AsPlainText -Force
    
    $srcsite = Connect-Site -url $srcsiteurl -UserName "UNIVERSITY\xxxxxxxx" -Password $securesrcpassword
    $destsite = Connect-Site -url $destsiteurl -UserName $adminusername -Password $securedestpassword
    
    write-host "Connecting to lists..." -BackgroundColor Black -ForegroundColor Green


    ###$row = $row + "$lanid" 
    out-file -FilePath $outfile -InputObject $lanid -Append -NoNewline -encoding ascii
    #run migration n times to collect time    
    1..$iterations | % { 
        write-host "lanid $lanid and iteration $_" -BackgroundColor Black -ForegroundColor Cyan
        $measurement = Measure-Command { 
     
            Copy-Site -Site $srcsite -DestinationSite $destsite  
            #copy-list -Name "MyFiles" -SourceSite $srcsite -DestinationSite $destsite 
    
        }  
        $timestamp = Get-Date #-Format o | foreach {$_ -replace ":", "."}
        $seconds = $measurement.Seconds
        ####$row = $row + "," + $seconds + "," + $timestamp   
        $row = "," + $seconds + ",'" + $timestamp    + "'"
        out-file -FilePath $outfile -InputObject $row -Append -NoNewline -encoding ascii
        write-host "Update at $timestamp  took $seconds " -BackgroundColor Black -ForegroundColor Yellow        
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












 




