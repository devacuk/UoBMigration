# UoB Migration scripts #

> ASP.NET artefacts.

### Dependencies ###

Microsoft.Practices.SharePoint.sln is the Developing Applications for SharePoint 2010, located in \Migration\c#\SharePointPatterns\Source\SharePoint 2010\Microsoft.Practices.SharePoint.sln
recommeded compiling using Visual studio 2010 or you have a whole load of curating 

copy the resultant dll from \Migration\c#\SharePointPatterns\Source\SharePoint 2010\Microsoft.Practices.SharePoint.Common\Source\bin\Release\Microsoft.Practices.SharePoint.Common.dll
to the GAC on the servers that will host the timer job, usually only the WFE is important.  

background: https://msdn.microsoft.com/en-us/library/ff770300.aspx




### Timer Jobs ###

UoBDelMySiteLibsTimerJob is the timer job that is part of migrating users onedrives, for logging, it depends upon Microsoft.Practices.SharePoint.Common.dll


this is a farm scoped VS solution, but a web application scoped timer job, 
build the \Migration\c#\UoBDelMySiteLibsTimerJob\UoBDelMySiteLibsTimerJob.sln, i suggest using VS2015, not supported in VS2017.

install the solution from Migration\c#\UoBDelMySiteLibsTimerJob\DelMySiteLibsTimerJob\bin\Release\UoBDelMySiteLibsTimerJob.wsp using Central Admin or your preferred method.

Activate the "UoB DelMySiteLibsTimerJob" Feature, say by managing features for the mysite web application.  This will now enable you to either run now or schedule the new "UoB Delete Old MySite DocLibs" job definition, say once every weekend.

