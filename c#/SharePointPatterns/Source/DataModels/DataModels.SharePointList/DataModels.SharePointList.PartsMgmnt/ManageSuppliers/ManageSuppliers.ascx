﻿<%@ Assembly Name="$SharePoint.Project.AssemblyFullName$" %>
<%@ Assembly Name="Microsoft.Web.CommandUI, Version=14.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Register Tagprefix="SharePoint" Namespace="Microsoft.SharePoint.WebControls" Assembly="Microsoft.SharePoint, Version=14.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Register Tagprefix="Utilities" Namespace="Microsoft.SharePoint.Utilities" Assembly="Microsoft.SharePoint, Version=14.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>

<%@ Import Namespace="Microsoft.SharePoint" %> 
<%@ Register Tagprefix="WebPartPages" Namespace="Microsoft.SharePoint.WebPartPages" Assembly="Microsoft.SharePoint, Version=14.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="ManageSuppliers.ascx.cs" Inherits="DataModels.SharePointList.PartsMgmnt.PartsMgmntControls.ManageSuppliers" %>
<%@ Register Tagprefix="asp" Namespace="System.Web.UI" Assembly="System.Web.Extensions, Version=3.5.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35" %>
<table width="100%">
    <tr>
        <td valign="top"  style="width:200px">                                
            <table width="100%">
    <tr>
        <td colspan="2">
            <asp:label runat="server" id="PartSearchLabel" text="Search By Supplier Name"></asp:label>
            <br />
            <asp:regularexpressionvalidator runat="server" errormessage="RegularExpressionValidator"
                id="SupplierRegExValidator" controltovalidate="SupplierSearchTextBox" 
                validationexpression="^[a-zA-Z0-9]{3,255}$" Display="Dynamic" 
                SetFocusOnError="True">Supplier Name must contain at least three (3) alpha-numeric characters !</asp:regularexpressionvalidator>
        </td>
    </tr>
    <tr>
        <td>
            <asp:textbox id="SupplierSearchTextBox" runat="server"></asp:textbox>
        </td>
        <td>
            <asp:button id="GoButton" runat="server" text="Go" />
        </td>
    </tr>
          <tr>
            <td colspan="2" align="right">
                <asp:hyperlink runat="server" id="AddNewHyperlink">Add New Supplier</asp:hyperlink>
            </td>
        </tr>
</table>                 
        </td>
        <td valign="top" >                                   
            <asp:updatepanel runat="server" id="SupplierResultUpdatePanel" childrenastriggers="false"
    updatemode="Conditional">
    <contenttemplate>
        <asp:gridview runat="server" ID="SupplierResultsGridView" 
            AutoGenerateColumns="False" EnableModelValidation="True" 
            DataKeyNames="Id" >
            <Columns>
            <asp:BoundField DataField="Id" Visible="False"></asp:BoundField>
                <asp:TemplateField>
                    <ItemTemplate>
                        <asp:HyperLink ID="SupplierNameHyperLink" runat="server" NavigateUrl="" 
                            Text='Edit / Delete'></asp:HyperLink>
                    </ItemTemplate>
                </asp:TemplateField>
                <asp:BoundField DataField="SupplierName" HeaderText="Supplier Name"></asp:BoundField>
                <asp:BoundField DataField="DUNS" HeaderText="DUNS">
                </asp:BoundField>
                <asp:ButtonField CommandName="ViewParts" HeaderText="Parts" Text="Parts">
                </asp:ButtonField>
            </Columns>
            <HeaderStyle Wrap="False" />
            <RowStyle Wrap="False" />
        </asp:gridview>
    </contenttemplate>
</asp:updatepanel>                     
        </td>
    </tr>
    <tr>
    <td></td>
        <td valign="top">            
          <asp:updatepanel runat="server" id="PartResultUpdatePanel" childrenastriggers="False"
    updatemode="Conditional">
    <contenttemplate>
        <asp:gridview runat="server" ID="PartResultsGridView" 
            AutoGenerateColumns="False" EnableModelValidation="True" 
            DataKeyNames="PartId,Sku"
            >
            <Columns>
            <asp:BoundField DataField="PartId" Visible="False"></asp:BoundField>
                <asp:TemplateField HeaderText="">
                    <ItemTemplate>
                        <asp:HyperLink ID="PartNameHyperLink" runat="server" NavigateUrl="" 
                            Text='Edit / Delete'></asp:HyperLink>
                    </ItemTemplate>
                </asp:TemplateField>
                <asp:BoundField DataField="PartName" HeaderText="Part Name"></asp:BoundField>
                <asp:BoundField DataField="Sku" HeaderText="SKU"></asp:BoundField>
                <asp:BoundField DataField="LocationBin" HeaderText="Bin #"></asp:BoundField>
                <asp:BoundField DataField="InventoryQuantity" HeaderText="Quantity">
                </asp:BoundField>
                <asp:TemplateField HeaderText="">
                    <ItemTemplate>
                        <asp:HyperLink ID="MachineHyperLink" runat="server" NavigateUrl="" 
                            Text='Machines'></asp:HyperLink>
                    </ItemTemplate>
                </asp:TemplateField>
                <asp:TemplateField HeaderText="">
                    <ItemTemplate>
                        <asp:HyperLink ID="SupplierHyperLink" runat="server" NavigateUrl="" 
                            Text='Suppliers'></asp:HyperLink>
                    </ItemTemplate>
                </asp:TemplateField>
                <asp:TemplateField HeaderText="">
                    <ItemTemplate>
                        <asp:HyperLink ID="LocationHyperLink" runat="server" NavigateUrl="" 
                            Text='Locations'></asp:HyperLink>
                    </ItemTemplate>
                </asp:TemplateField>

            </Columns>
             <HeaderStyle Wrap="False" />
            <RowStyle Wrap="False" />
        </asp:gridview>
    </contenttemplate>
    <triggers>
        <asp:AsyncPostBackTrigger ControlID="PartResultsGridView" 
            EventName="PageIndexChanging" />
    </triggers>
</asp:updatepanel>
          
            </td>       
    </tr>
</table>