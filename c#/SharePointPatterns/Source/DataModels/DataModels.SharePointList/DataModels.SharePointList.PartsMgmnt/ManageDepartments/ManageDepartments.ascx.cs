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
using System.Web.UI;
using System.Web.UI.WebControls;
using DataModels.SharePointList.Model;
using Microsoft.SharePoint;

namespace DataModels.SharePointList.PartsMgmnt.PartsMgmntControls
{
    using System.Linq;
    using DTOs;
    using Microsoft.Practices.SharePoint.Common.ServiceLocation;

    public partial class ManageDepartments : UserControl
    {
        protected override void OnInit(EventArgs e)
        {
            base.OnInit(e);
            GoButton.Click += GoButton_Click;
            DepartmentResultsGridView.RowDataBound += DepartmentResultsGridView_RowDataBound;
            DepartmentResultsGridView.SelectedIndexChanged += DepartmentResultsGridView_SelectedIndexChanged;
            MachineResultsGridView.RowDeleting += MachineResultsGridView_RowDeleting;

            AddNewHyperlink.NavigateUrl = string.Concat("javascript: ShowModalDialog('",
                                                        SPContext.Current.Site.RootWeb.Url,
                                                        "/", SharePointList.Model.Constants.ListUrls.Departments,
                                                        "/NewForm.aspx?IsDlg=1');");
        }

        protected void Page_Load(object sender, EventArgs e)
        {
        }

        private void GoButton_Click(object sender, EventArgs eventArgs)
        {
            using (var partManagementRepository = SharePointServiceLocator.GetCurrent().GetInstance<IPartManagementRepository>())
            {
                IEnumerable<Department> departments =
                    partManagementRepository.GetDepartmentsByPartialName(DepartmentSearchTextBox.Text);

                var departmentDtos = departments.Select(department => new DepartmentDTO
                                                                                       {
                                                                                           DepartmentId =
                                                                                               department.Id.HasValue
                                                                                                   ? department.Id.Value
                                                                                                   : 0,
                                                                                           DepartmentName = department.Title,
                                                                                       });
                ShowDepartmentResults(departmentDtos);
            }
        }
        protected void DepartmentResultsGridView_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                HyperLink DepartmentNameLink = (HyperLink)e.Row.FindControl("DepartmentNameHyperLink");
                string DepartmentId = DepartmentResultsGridView.DataKeys[e.Row.RowIndex].Value.ToString();
                DepartmentNameLink.NavigateUrl = string.Concat("javascript: ShowModalDialog('",
                                                        SPContext.Current.Site.RootWeb.Url,
                                                        "/", SharePointList.Model.Constants.ListUrls.Departments, "/EditForm.aspx?ID=" + DepartmentId + "&IsDlg=1');");
            }
        }

        protected void DepartmentResultsGridView_SelectedIndexChanged(object sender, EventArgs e)
        {
            int selectedDepartmentId = int.Parse(DepartmentResultsGridView.DataKeys[DepartmentResultsGridView.SelectedRow.RowIndex].Value.ToString());
            BindMachineParts(selectedDepartmentId);
        }

        private void BindMachineParts(int departmentId)
        {
            using (var partManagementRepository = SharePointServiceLocator.GetCurrent().GetInstance<IPartManagementRepository>())
            {
                IEnumerable<MachineDepartment> machineDepartments = partManagementRepository.
                    GetMachineDepartmentsByDepartment(departmentId);
                var machineDepartmentDtos =
            machineDepartments.Select(machineDepartment => new MachineDepartmentDTO()
                                                               {
                                                                   Id =
                                                                       machineDepartment.Id.HasValue
                                                                           ? machineDepartment.Id.Value
                                                                           : 0,
                                                                   MachineName = machineDepartment.Machine.Title,
                                                                   LocationDescription =
                                                                       machineDepartment.Description,
                                                                   Model = machineDepartment.Machine.ModelNumber
                                                               });
                ShowMachineDepartments(machineDepartmentDtos);
            }

        }

        protected void MachineResultsGridView_RowDeleting(object sender, GridViewDeleteEventArgs e)
        {
            var selectedMachineDepartmentId = int.Parse(MachineResultsGridView.DataKeys[e.RowIndex].Value.ToString());
            var selectedDepartmentId = int.Parse(DepartmentResultsGridView.DataKeys[DepartmentResultsGridView.SelectedRow.RowIndex].Value.ToString());
            using (var partManagementRepository = SharePointServiceLocator.GetCurrent().GetInstance<IPartManagementRepository>())
            {
                partManagementRepository.DeleteMachineDepartment(selectedMachineDepartmentId);
            }

            BindMachineParts(selectedDepartmentId);
        }

        public void ShowDepartmentResults(IEnumerable<DepartmentDTO> departmentDtos)
        {
            DepartmentResultsGridView.DataSource = departmentDtos;
            DepartmentResultsGridView.EmptyDataText = Constants.EmptyData.DepartmentResults;
            DepartmentResultsGridView.DataBind();
            DepartmentResultUpdatePanel.Update();
        }

        public void ShowMachineDepartments(IEnumerable<MachineDepartmentDTO> machineDepartmentDtos)
        {
            MachineResultsGridView.DataSource = machineDepartmentDtos;
            MachineResultsGridView.EmptyDataText = Constants.EmptyData.MachineDepartmentResults;
            MachineResultsGridView.DataBind();
            MachineResultsUpdatePanel.Update();
            MachineResultsGridView.EmptyDataText = string.Empty;
        }
    }
}
