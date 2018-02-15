//===============================================================================
// Microsoft patterns & practices
// Developing Applications for SharePoint 2010
//===============================================================================
// Copyright Microsoft Corporation.  All rights reserved.
// This code released under the terms of the 
// Microsoft patterns & practices license (http://msdn.microsoft.com/en-us/library/ee663037.aspx)
//===============================================================================


using System;
using System.Runtime.InteropServices;
using System.Security.Permissions;
using Microsoft.SharePoint;
using Microsoft.SharePoint.Security;
using Microsoft.SharePoint.Administration;
using System.Reflection;
using System.Globalization;
using System.Diagnostics;
using ExecutionModels.Workflow.FullTrust.Activities;

namespace ExecutionModels.Workflow.FullTrust.Activities.Features.SiteProvisioningActivity
{
    /// <summary>
    /// This class handles events raised during feature activation, deactivation, installation, uninstallation, and upgrade.
    /// </summary>
    /// <remarks>
    /// The GUID attached to this class may be used during packaging and should not be modified.
    /// </remarks>

    [Guid("b2656477-1093-45ad-a33c-ee2ee820e5e3")]
    public class SiteProvisioningActivityEventReceiver : SPFeatureReceiver
    {
        public override void FeatureActivated(SPFeatureReceiverProperties properties)
        {
            try
            {
                SPWebService contentService = SPWebService.ContentService;
                contentService.WebConfigModifications.Add(GetConfigModification());
                // Serialize the web application state and propagate changes across the farm. 
                contentService.Update();
                // Save web.config changes.
                contentService.ApplyWebConfigModifications();
            }
            catch (Exception e)
            {
                Console.WriteLine(e.ToString());
                throw;
            }
        }

        public override void FeatureDeactivating(SPFeatureReceiverProperties properties)
        {
            try
            {
                SPWebService contentService = SPWebService.ContentService;
                contentService.WebConfigModifications.Remove(GetConfigModification());
                // Serialize the web application state and propagate changes across the farm. 
                contentService.Update();
                // Save web.config changes.
                contentService.ApplyWebConfigModifications();
            }
            catch (Exception e)
            {
                Console.WriteLine(e.ToString());
                throw;
            }
        }

        public SPWebConfigModification GetConfigModification()
        {
            string assemblyValue = typeof(CreateSubSiteActivity).Assembly.FullName;
            string namespaceValue = typeof(CreateSubSiteActivity).Namespace;

            SPWebConfigModification modification = new SPWebConfigModification(
                string.Format(CultureInfo.CurrentCulture,
                    "authorizedType[@Assembly='{0}'][@Namespace='{1}'][@TypeName='*'][@Authorized='True']", assemblyValue, namespaceValue), 
                "configuration/System.Workflow.ComponentModel.WorkflowCompiler/authorizedTypes");
            
            modification.Owner = "Patterns and Practices";
            modification.Sequence = 0;
            modification.Type = SPWebConfigModification.SPWebConfigModificationType.EnsureChildNode;
            modification.Value = 
                string.Format(CultureInfo.CurrentCulture, 
                "<authorizedType Assembly=\"{0}\" Namespace=\"{1}\" TypeName=\"*\" Authorized=\"True\" />", assemblyValue, namespaceValue);

            Trace.TraceInformation("SPWebConfigModification value: {0}", modification.Value);

            return modification;
        }
    }
}
