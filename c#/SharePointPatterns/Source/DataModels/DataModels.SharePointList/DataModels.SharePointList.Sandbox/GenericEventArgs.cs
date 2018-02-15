//===============================================================================
// Microsoft patterns & practices
// Developing Applications for SharePoint 2010
//===============================================================================
// Copyright Microsoft Corporation.  All rights reserved.
// This code released under the terms of the 
// Microsoft patterns & practices license (http://msdn.microsoft.com/en-us/library/ee663037.aspx)
//===============================================================================


using System;
namespace DataModels.SharePointList.Sandbox
{
    public class GenericEventArgs<T> : EventArgs
    {
        public T PayLoad { get; set; }
    }
}