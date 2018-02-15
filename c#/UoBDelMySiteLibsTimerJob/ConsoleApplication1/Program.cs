using System;
using Microsoft.Office.Server.UserProfiles;
using Microsoft.SharePoint;
using Microsoft.SharePoint.Administration;
//need pnp servicelocator / logger
using Microsoft.Practices.ServiceLocation;
using Microsoft.Practices.SharePoint.Common.ServiceLocation;
using Microsoft.Practices.SharePoint.Common.Logging;

namespace ConsoleApplication1
{
    class Program
    {
        //property bag rootsiteuri is http://toliman:51015
        //property bag mysiteuri is http://mysitepp.brighton.ac.uk
        //property bag uobmigrationperiodcheckweeks is 6
        //property bag recycleordelete is recycle | delete

        public String RecyleOrDelete {
            get {

                String recycleOrDelete = String.Empty;
                try
                {
                    using (SPSite RootSite = new SPSite(CASiteUri))
                    {
                        using (SPWeb rootWeb = RootSite.OpenWeb())
                        {
                            rootWeb.AllowUnsafeUpdates = true;
                            recycleOrDelete = Convert.ToString(rootWeb.AllProperties["recycleordelete"].ToString());
                            Console.WriteLine(recycleOrDelete);
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
        /// assumed that you have run some powershell to set the prperty bag value
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
                            Console.WriteLine(myValue);
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
                            Console.WriteLine(uri);
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
                            Console.WriteLine(uri);
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
                            Console.WriteLine("armed " + armed.ToString());
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

        public Program()
        {
            Console.WriteLine("In constructor...");
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
                        Console.WriteLine(username);
                        Console.WriteLine(u.ID);
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
                                        Console.ForegroundColor = ConsoleColor.Green;
                                        Console.WriteLine(logEntry + " " + weeks.ToString() + " old");
                                        Console.ResetColor();

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
                            Console.BackgroundColor = ConsoleColor.DarkRed;
                            Console.ForegroundColor = ConsoleColor.White;
                            Console.WriteLine(logEntry);
                            Console.ResetColor();
                            IServiceLocator serviceLocator = SharePointServiceLocator.GetCurrent();
                            ILogger logger = serviceLocator.GetInstance<ILogger>();
                            logger.LogToOperations(logEntry, EventSeverity.Error);
                        }
                    }
                    catch (Exception ex)
                    {
                        //mysite has no user profile, so we cant check migrated, just add a warning in the log
                        string logEntry = "MYSITE HAS NO PROFILE: " + siteCollection.RootWeb.Site.Owner.LoginName;
                        Console.BackgroundColor = ConsoleColor.Red;
                        Console.ForegroundColor = ConsoleColor.Yellow;
                        Console.WriteLine(logEntry);
                        Console.ResetColor();
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
            }
        }
        static void Main(string[] args)
        {
            Program p = new Program();

        }
    }
}
