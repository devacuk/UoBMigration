# UoB Migration scripts #

> Using ShareGate to migrate users MyFile document library files


n.b. All steps based upon users in the [mapping file](../usermapping/).

### ShareGate ###
use copy-content powershell cmdlet to copy from SharePoint 2010 MyFiles to a tenancy's OneDrive Document library

### post steps ###
mark the users' profile as migrated by wrting todays date to it, using the built in SharePoint 2010 web service method




```powershell
function TimeStampUserProfile {
    $proxy = New-WebServiceProxy "$onPremiseMysiteURIPart/_vti_bin/userprofileservice.asmx" -UseDefaultCredential
    #$account = "{0}\{1}" -f $env:USERDOMAIN, $lanid
    $account = "{0}\{1}" -f $domain, $lanid
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
```

#### How to connect to the service on a web page ####

```javascript
var jq = document.createElement('script');
jq.src = "https://code.jquery.com/jquery-latest.min.js";
document.getElementsByTagName('head')[0].appendChild(jq);
jQuery.noConflict();



jQuery(document).ready(function() {
	var soapEnv = `<?xml version='1.0' encoding='utf-8'?> 
    <soap:Envelope xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:soap='http://schemas.xmlsoap.org/soap/envelope/'> 
		<soap:Body> 
			<GetUserProfileByName xmlns='http://microsoft.com/webservices/SharePointPortalServer/UserProfileService'> 
				<AccountName>UNIVERSITY\\fredbloggs</AccountName> 
			</GetUserProfileByName> 
		</soap:Body> 	
	</soap:Envelope>
    `;
 
    jQuery.ajax({
        url: "https://mydepartment.uniuni.ac.uk/_vti_bin/userprofileservice.asmx",
        type: "POST",
        dataType: "xml",
        data: soapEnv,
        complete: processResult,
        contentType: "text/xml; charset=\"utf-8\""
    });
});

function processResult(xData, status) {
        var newResults = $(xData.responseXML);
        jQuery("s4-mainarea").replaceWith('<div id="somedata">' + newResults.text() + '</div>');    
} 
```


[README.md markup guide](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet)




