# UoB Migration scripts #

> SharePoint 2010 mysite freeze
> Deploys master page to the users mysite, set read only and add notification.  
> In the future could look at placing artefacts in a site collection feature and 
> deploying that to each mysite in the mapping file.  

n.b. All steps based upon users in the [mapping file](../usermapping/).

### Setup configuration ###
parameters

| propertybag                 | Value                     | Prod. Value        |
| ----------------------------|---------------------------|--------------------|
| onPremiseMysiteURIPart      | http://server:51015      | http://server:61218|
| sourcePasswordPlain         | ???                       | ???                |
| migrationfolder             |\\sp-mig-dev01\c$\migration|c:\migration\ |
| sourceListName              | MyFiles        | MyFiles |
| domain                      | UNIVERSITY                | UNIVERSITY         |

### Installation ###
copy the files including Migration.master to a __SharePoint 2010 web front end__, amend the parameter values 
```powershell
.\prerequisites.ps1 -onPremiseMysiteURIPart "http://xxx.xxxxxxx.ac.uk/user" `
    -sourcePasswordPlain "???" `
    -sourceListName "MyFiles" `
    -domain "UNIVERSITY" `
    -migrationfolder  "c:\migration\"   
#PROD

```

so for

| environment | run on    |
| ------------|-----------|
| UNIDEV      | devserver      |
| preprod     | ppserver    |
| production  | prod    |


the result for user unidev\tswo10 when they login to their mysite myfiles:
![mysite read-only](./assets/myfilesreadonly.png)

[README.md markup guide](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet)




