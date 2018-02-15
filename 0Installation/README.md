# UoB Migration scripts #

> Some things to run after installing the timerjob.  To configure its parameters.
> Consider, if time permitting to integrate this *into* the timer job installation process

### Setup configuration ###
for instance setting the property bags that the timer job uses for

| propertybag                   | Value                                | Prod. Value                         |
| ------------------------------|--------------------------------------|-------------------------------------|
| rootsiteuri                   | http://server:51015                 | http://server:61218                 |
| mysiteuri                     | http://mysitepp.xxxxxxxx.ac.uk       | http://mysitepp.xxxxxxxx.ac.uk      |
| uobmigrationperiodcheckweeks  | 6                                    | 6      |
| uobmigrationarmed             | false                                 | true      |
| recycleordelete               | delete                              | recycle      |

### Installation ###
copy the files to a SharePoint 2010 web front end, amend the parameter values 
```powershell
.\SetPropertyBags.ps1 -centralAdminUri "http://server:51015" `
    -mysiteuri "http://mysitepp.xxxxxxxx.ac.uk" `
    -uobmigrationperiodcheckweeks "6" `
    -uobmigrationarmed "true" `
    -recycleordelete "recycle"
```

![successful execution](/assets/propbagssuccess.png)
![unsuccessful execution](/assets/propbagsfail.png)

[README.md markup guide](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet)




