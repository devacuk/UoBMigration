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
using Microsoft.SharePoint.UserCode;
using Microsoft.Practices.SharePoint.Common.ProxyArgs;

namespace Microsoft.Practices.SharePoint.Configuration.ConfigurationProxy.Features.Feature1
{
    /// <summary>
    /// This class handles events raised during feature activation, deactivation, installation, uninstallation, and upgrade.
    /// </summary>
    /// <remarks>
    /// The GUID attached to this class may be used during packaging and should not be modified.
    /// </remarks>

    [Guid("7e4d6269-8a73-4998-967c-a4482344d119")]
    public class Feature1EventReceiver : SPFeatureReceiver
    {
        // Uncomment the method below to handle the event raised after a feature has been activated.
        /// <summary>
        /// Registers the proxy operations with the farm.
        /// </summary>
        /// <param name="properties">the properties provided by the feature receiver</param>
        public override void FeatureActivated(SPFeatureReceiverProperties properties)
        {
            SPUserCodeService userCodeService = SPUserCodeService.Local;

            AddProxyOperation(userCodeService, ContainsKeyDataArgs.OperationAssemblyName, ContainsKeyDataArgs.OperationTypeName);
            AddProxyOperation(userCodeService, ReadConfigArgs.OperationAssemblyName, ReadConfigArgs.OperationTypeName);
            AddProxyOperation(userCodeService, ProxyInstalledArgs.OperationAssemblyName, ProxyInstalledArgs.OperationTypeName);
            userCodeService.Update();
        }

        private void AddProxyOperation(SPUserCodeService service, string assembly, string operation)
        {
            var proxyOp =new SPProxyOperationType(assembly, operation);
            service.ProxyOperationTypes.Add(proxyOp);
        }


        /// <summary>
        /// Removes the proxy operations from the farm for configuration proxies.
        /// </summary>
        /// <param name="properties">The properties provided on deactivation</param>
        public override void FeatureDeactivating(SPFeatureReceiverProperties properties)
        {
            SPUserCodeService userCodeService = SPUserCodeService.Local;

            RemoveProxyOperation(userCodeService, ContainsKeyDataArgs.OperationAssemblyName,ContainsKeyDataArgs.OperationTypeName);
            RemoveProxyOperation(userCodeService, ReadConfigArgs.OperationAssemblyName,ReadConfigArgs.OperationTypeName);
            RemoveProxyOperation(userCodeService, ProxyInstalledArgs.OperationAssemblyName, ProxyInstalledArgs.OperationTypeName);
            userCodeService.Update();
        }

        private bool RemoveProxyOperation(SPUserCodeService service, string assembly, string operation)
        {
            var proxyOp = new SPProxyOperationType(assembly, operation);
            bool removed = service.ProxyOperationTypes.Remove(proxyOp);
            return removed;
        }


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
