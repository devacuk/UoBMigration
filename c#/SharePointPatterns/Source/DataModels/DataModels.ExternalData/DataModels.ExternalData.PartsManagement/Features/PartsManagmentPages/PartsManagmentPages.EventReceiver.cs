//===============================================================================
// Microsoft patterns & practices
// Developing Applications for SharePoint 2010
//===============================================================================
// Copyright Microsoft Corporation.  All rights reserved.
// This code released under the terms of the 
// Microsoft patterns & practices license (http://msdn.microsoft.com/en-us/library/ee663037.aspx)
//===============================================================================


using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using System.Security.Permissions;
using Microsoft.SharePoint;
using Microsoft.SharePoint.Navigation;
using Microsoft.SharePoint.Security;

namespace DataModels.ExternalData.PartsManagement.Features.PartsManagmentPages
{
    /// <summary>
    /// This class handles events raised during feature activation, deactivation, installation, uninstallation, and upgrade.
    /// </summary>
    /// <remarks>
    /// The GUID attached to this class may be used during packaging and should not be modified.
    /// </remarks>

    [Guid("8b7ed12c-a41f-49cd-b8df-0000e912a09d")]
    public class PartsManagmentPagesEventReceiver : SPFeatureReceiver
    {
        private const string rootNodeTitle = "Parts Management";
        // Uncomment the method below to handle the event raised after a feature has been activated.
        public override void FeatureActivated(SPFeatureReceiverProperties properties)
        {
            //Get The Quick Launch and add a new root node if it doesn't already exist               
            SPNavigationNodeCollection quickLinkNodes = ((SPWeb) (properties.Feature.Parent)).Navigation.QuickLaunch;
            SPNavigationNode rootNode = quickLinkNodes[0];
            if (rootNode.Title != rootNodeTitle)
            {
                rootNode = new SPNavigationNode(rootNodeTitle, ((SPWeb) (properties.Feature.Parent)).Url, false);
                quickLinkNodes.AddAsFirst(rootNode);
            }

            //Delete Items if they already exist
            foreach (SPNavigationNode quickLinkNode in rootNode.Children)
            {
                quickLinkNode.Delete();
            }

            //Add the Custom Links based on the Dictionary       
            foreach (KeyValuePair<string, string> kvp in GetNav())
            {
                // add security trimmed nodes, set all to external=false    
                var newNode = new SPNavigationNode(kvp.Key, kvp.Value, false);
                rootNode.Children.AddAsLast(newNode);
            }
            quickLinkNodes.Parent.Update();

        }

        private Dictionary<string, string> GetNav()
        {
            return new Dictionary<string, string>()
                       {
                           {"Manage Machines", "PartsManagementPages/ManageMachines.aspx"},
                           {"Manage Suppliers", "PartsManagementPages/ManageSuppliers.aspx"},
                           {"Machines By Part", "PartsManagementPages/PartsToMachines.aspx" },
                           {"Parts By Machine", "PartsManagementPages/MachinesToParts.aspx"}
                       };
        }



        // Uncomment the method below to handle the event raised before a feature is deactivated.

        //public override void FeatureDeactivating(SPFeatureReceiverProperties properties)
        //{
        //}


        // Uncomment the method below to handle the event raised after a feature has been installed.

        //public override void FeatureInstalled(SPFeatureReceiverProperties properties)
        //{
        //}


        // Uncomment the method below to handle the event raised before a feature is uninstalled.

        //public override void FeatureUninstalling(SPFeatureReceiverProperties properties)
        //{
        //}

        // Uncomment the method below to handle the event raised when a feature is upgrading.

        //public override void FeatureUpgrading(SPFeatureReceiverProperties properties, string upgradeActionName, System.Collections.Generic.IDictionary<string, string> parameters)
        //{
        //}
    }
}
