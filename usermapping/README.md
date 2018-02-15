# UoB Migration scripts #

> Mapping file, used to orchestrate the migration of a set of users

![](/assets/venndiag.png)


n.b. All steps based upon users in the [mapping file](UsersToMigrate.csv).

### Structure ###

|username |o365login                         |department|o365urlpart                    |
|------|----------------------------------|----------|-------------------------------|
|user1  |c.xxxxx@dev.xxxxxxx.ac.uk    |IS        |c_xxxx_dev_xxxxxx_ac_uk |
|user2 |l.xxxx@dev.xxxxxx.ac.uk       |IS        |l_xxxx_dev_xxxxxx_ac_uk    |
|user3 |t.xxxx@dev.xxxxxxx.ac.uk      |IS        |t_xxxxx_dev_xxxxxx_ac_uk   |


  * username from LDAP, but available from SharePoint user profiles
  * O365 login from AzureAD
  * Department – no longer needed, but will keep as we don’t want to have to modify already written and tested PowerShell
  * Powershell function to escape special characters such as ‘@’ and ‘.’ with underscore of the o365 login

Key takeaway; the producer of the mapping file needs to be able to join o365 logins with LDAP or SharePoint user profiles to produce a reliable mapping file.

[Azure AD Connect sync: Attributes synchronized to Azure Active Directory](https://docs.microsoft.com/en-us/azure/active-directory/connect/active-directory-aadconnectsync-attributes-synchronized)

[Active directory (on prem attributes) into AzureAD e.g. cn](https://blogs.technet.microsoft.com/askpfeplat/2015/01/05/azure-active-directory-for-the-old-school-ad-admin/)

[README.md markup guide](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet)




