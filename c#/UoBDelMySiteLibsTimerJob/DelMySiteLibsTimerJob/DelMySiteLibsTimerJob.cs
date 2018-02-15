using System;
using Microsoft.Office.Server.UserProfiles;
using Microsoft.Practices.ServiceLocation;
using Microsoft.Practices.SharePoint.Common.Logging;
using Microsoft.Practices.SharePoint.Common.ServiceLocation;
using Microsoft.SharePoint;
using Microsoft.SharePoint.Administration;


namespace UoBDelMySiteLibsTimerJob
{

    /// <summary>
    /// class containing various UoB methods for a timer job
    /// Goes through the sharepoint user profile properties and deletes or ecycles some content based upon user profile attribute migration date.  
    /// various paramaters can be set using property bags to govern the timer job behaviour.
    ///This is intended for use with the SharePoint to Ofrfice365 upgrade project.
    /// </summary>
    class UoBMySiteJob : SPJobDefinition
    {
        public const string JobName = "UoBDeleteMySiteLibsJob";

        public String RecyleOrDelete
        {
            get
            {

                String recycleOrDelete = String.Empty;
                try
                {
                    using (SPSite RootSite = new SPSite(CASiteUri))
                    {
                        using (SPWeb rootWeb = RootSite.OpenWeb())
                        {
                            rootWeb.AllowUnsafeUpdates = true;
                            recycleOrDelete = Convert.ToString(rootWeb.AllProperties["recycleordelete"].ToString());
                            //Console.WriteLine(recycleOrDelete);
                        }
                    }
                }
                catch (Exception ex)
                {
                    IServiceLocator serviceLocator = SharePointServiceLocator.GetCurrent();
                    ILogger logger = serviceLocator.GetInstance<ILogger>();
                    // Log an event with a message.
                    string msg = "recycleordelete propertybag not set default to recycle " + ex.Message;
                    logger.LogToOperations(msg);
                    recycleOrDelete = "recycle";
                }
                return recycleOrDelete;
            }
        }

        /// <summary>
        /// assumed that you have run some powershell to set the property bag value
        /// </summary>
        /// <returns></returns>
        private int UoBMigrationDeletePeriod
        {
            get
            {
                int myValue = 0;
                try
                {
                    using (SPSite RootSite = new SPSite(CASiteUri))
                    {
                        using (SPWeb rootWeb = RootSite.OpenWeb())
                        {
                            rootWeb.AllowUnsafeUpdates = true;
                            myValue = Convert.ToInt16(rootWeb.AllProperties["uobmigrationperiodcheckweeks"].ToString());
                        }

                    }
                }
                catch (Exception ex)
                {
                    myValue = 6;
                    IServiceLocator serviceLocator = SharePointServiceLocator.GetCurrent();
                    ILogger logger = serviceLocator.GetInstance<ILogger>();
                    // Log an event with a message.
                    string msg = "uobmigrationperiodcheckweeks not found set to 6 weeks " + ex.Message;
                    logger.LogToOperations(msg);
                }
                return myValue;
            }
        }

        private string RootSiteUri
        {
            get
            {
                String uri = String.Empty;
                try
                {
                    using (SPSite RootSite = new SPSite(CASiteUri))
                    {
                        using (SPWeb rootWeb = RootSite.OpenWeb())
                        {
                            rootWeb.AllowUnsafeUpdates = true;
                            uri = Convert.ToString(rootWeb.AllProperties["rootsiteuri"].ToString());
                        }

                    }
                }
                catch (Exception ex)
                {
                    IServiceLocator serviceLocator = SharePointServiceLocator.GetCurrent();
                    ILogger logger = serviceLocator.GetInstance<ILogger>();
                    // Log an event with a message.
                    string msg = "rootsiteuri propertybag not set " + ex.Message;
                    logger.LogToOperations(msg);
                    Environment.Exit(-1);
                }
                return uri;
            }
        }

        private string MySiteUri
        {
            get
            {
                String uri = String.Empty;
                try
                {
                    using (SPSite RootSite = new SPSite(RootSiteUri))
                    {
                        using (SPWeb rootWeb = RootSite.OpenWeb())
                        {
                            rootWeb.AllowUnsafeUpdates = true;
                            uri = Convert.ToString(rootWeb.AllProperties["mysiteuri"].ToString());
                        }
                    }
                }
                catch (Exception ex)
                {
                    IServiceLocator serviceLocator = SharePointServiceLocator.GetCurrent();
                    ILogger logger = serviceLocator.GetInstance<ILogger>();
                    string msg = "mysiteuri propertybag not set " + ex.Message;
                    logger.LogToOperations(msg);
                    Environment.Exit(-1);
                }
                return uri;
            }
        }

        private string CASiteUri
        {
            get
            {
                String uri = String.Empty;
                try
                {
                    Microsoft.SharePoint.Administration.SPAdministrationWebApplication centralWeb = SPAdministrationWebApplication.Local;
                    uri = centralWeb.Sites[0].Url;
                }
                catch (Exception ex)
                {
                    IServiceLocator serviceLocator = SharePointServiceLocator.GetCurrent();
                    ILogger logger = serviceLocator.GetInstance<ILogger>();
                    string msg = "CASiteUri not set" + ex.Message;
                    logger.LogToOperations(msg, EventSeverity.ErrorCritical);
                    Environment.Exit(-1);
                }
                return uri;
            }
        }

        private bool MySiteDeleteArmed
        {
            get
            {
                bool armed = false;
                try
                {
                    using (SPSite RootSite = new SPSite(RootSiteUri))
                    {
                        using (SPWeb rootWeb = RootSite.OpenWeb())
                        {
                            rootWeb.AllowUnsafeUpdates = true;
                            armed = Convert.ToBoolean(rootWeb.AllProperties["uobmigrationarmed"].ToString());
                        }

                    }
                }
                catch (Exception ex)
                {
                    IServiceLocator serviceLocator = SharePointServiceLocator.GetCurrent();
                    ILogger logger = serviceLocator.GetInstance<ILogger>();
                    // Log an event with a message.
                    string msg = "uobmigrationarmed propertybag not set " + ex.Message;
                    logger.LogToOperations(msg, EventSeverity.ErrorCritical);
                    Environment.Exit(-1);
                }
                return armed;
            }
        }


        public UoBMySiteJob() : base() {
            IServiceLocator serviceLocator = SharePointServiceLocator.GetCurrent();
            ILogger logger = serviceLocator.GetInstance<ILogger>();
            logger.LogToOperations("Starting UoB Delete Old MySite DocLibs Timer Job" , EventSeverity.Information);
        }

        public UoBMySiteJob(SPWebApplication webApp) : base(JobName, webApp, null, SPJobLockType.Job)
        {
            Title = "UoB Delete Old MySite DocLibs";// JobName;
        }

        public override void Execute(Guid targetInstanceId)
        {
            IServiceLocator serviceLocatortest = SharePointServiceLocator.GetCurrent();
            ILogger loggertest = serviceLocatortest.GetInstance<ILogger>();
            loggertest.LogToOperations("Executing UoB Delete Old MySite DocLibs Timer Job", EventSeverity.Information);

            base.Execute(targetInstanceId);            
            SPWebApplication webApplication = SPWebApplication.Lookup(new Uri(MySiteUri));
            SPSiteCollection siteCollections = webApplication.Sites;
            bool recycle = false;
            bool armed = false;

            if (String.Compare(RecyleOrDelete, "recycle", false) == 0)
                recycle = true;
            if (MySiteDeleteArmed)
                armed = true;
                

            foreach (SPSite siteCollection in siteCollections)
            {
                try
                {
                    string username = siteCollection.RootWeb.Site.Owner.LoginName;
                    SPServiceContext serviceContext = SPServiceContext.GetContext(siteCollection);
                    UserProfileManager userProfileManager = new UserProfileManager(serviceContext);
                    UserProfile u = null;
                    try
                    {
                        u = userProfileManager.GetUserProfile(siteCollection.RootWeb.Site.Owner.LoginName);                            
                        try
                        {
                            if (u["uob-Migrated"].Count > 0)
                            {
                                DateTime dt = DateTime.Parse(u["uob-Migrated"].Value.ToString());
                                DateTime df = DateTime.Now;
                                double weeks = (df - dt).TotalDays / 7;
                                if (weeks > UoBMigrationDeletePeriod)
                                {
                                    string logEntry = string.Empty;
                                    try
                                    {
                                        if (armed)
                                        {
                                            logEntry = "DELETED MYSITE ***MyFiles*** : " + username;
                                            if (recycle)
                                                siteCollection.RootWeb.Lists["MyFiles"].Recycle();
                                            else
                                                siteCollection.RootWeb.Lists["MyFiles"].Delete();
                                        }
                                        else
                                        {
                                            logEntry = "DELETE (SOFT) MYSITE MyFiles: " + username;
                                        }

                                    }
                                    catch
                                    {
                                        //todo if deletion failed...
                                    }
                                    finally
                                    {
                                        IServiceLocator serviceLocator = SharePointServiceLocator.GetCurrent();
                                        ILogger logger = serviceLocator.GetInstance<ILogger>();
                                        logger.LogToOperations(logEntry, EventSeverity.Information);
                                    }
                                }
                            }
                        }
                        catch
                        {
                            string logEntry = "FAILED TO DELETE MYSITE: " + siteCollection.RootWeb.Site.Owner.LoginName;
                            IServiceLocator serviceLocator = SharePointServiceLocator.GetCurrent();
                            ILogger logger = serviceLocator.GetInstance<ILogger>();
                            logger.LogToOperations(logEntry, EventSeverity.Error);
                        }
                    }
                    catch (Exception ex)
                    {
                        string logEntry = "MYSITE HAS NO PROFILE: " + username;                            
                        IServiceLocator serviceLocator = SharePointServiceLocator.GetCurrent();
                        ILogger logger = serviceLocator.GetInstance<ILogger>();
                        logger.LogToOperations(logEntry, EventSeverity.Warning);                            
                    }

                }
                catch
                {
                    //ex
                }
                siteCollection.Close();
                siteCollection.Dispose();
            }
        }
    }
}
