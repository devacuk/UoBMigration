﻿<%@ Assembly Name="$SharePoint.Project.AssemblyFullName$" %>
<%@ Assembly Name="Microsoft.Web.CommandUI, Version=14.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Register Tagprefix="SharePoint" Namespace="Microsoft.SharePoint.WebControls" Assembly="Microsoft.SharePoint, Version=14.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Register Tagprefix="Utilities" Namespace="Microsoft.SharePoint.Utilities" Assembly="Microsoft.SharePoint, Version=14.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Register Tagprefix="asp" Namespace="System.Web.UI" Assembly="System.Web.Extensions, Version=3.5.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35" %>
<%@ Import Namespace="Microsoft.SharePoint" %> 
<%@ Register Tagprefix="WebPartPages" Namespace="Microsoft.SharePoint.WebPartPages" Assembly="Microsoft.SharePoint, Version=14.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="DepartmentResults.ascx.cs" Inherits="DataModels.SharePointList.PartsMgmnt.PartsMgmntControls.DepartmentResults" %>
<asp:updatepanel runat="server" id="DepartmentResultUpdatePanel" childrenastriggers="false"
    updatemode="Conditional">
    <contenttemplate>
        <asp:gridview runat="server" ID="DepartmentResultsGridView" 
            AutoGenerateColumns="False" EnableModelValidation="True" 
            DataKeyNames="DepartmentId">
            <Columns>
            <asp:BoundField DataField="DepartmentId" Visible="False"></asp:BoundField>
                <asp:TemplateField HeaderText="Department Name">
                    <ItemTemplate>
                        <asp:HyperLink ID="DepartmentNameHyperLink" runat="server" NavigateUrl="" 
                            Text='<%# Eval("DepartmentName") %>'></asp:HyperLink>
                    </ItemTemplate>
                </asp:TemplateField>
                <asp:ButtonField CommandName="Select" HeaderText="Machines" Text="Machines">
                </asp:ButtonField>
            </Columns>
             <HeaderStyle Wrap="False" />
            <RowStyle Wrap="False" />
        </asp:gridview>
    </contenttemplate>
</asp:updatepanel>