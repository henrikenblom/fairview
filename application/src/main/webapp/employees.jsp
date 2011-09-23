<%--
  Created by IntelliJ IDEA.
  User: fairview
  Date: 9/1/11
  Time: 10:15 AM
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@include file="WEB-INF/jspf/beanMapper.jsp" %>

<html>
<head>
    <title>Infero Quest - Personer</title>
    <link rel="stylesheet" href="css/newlook.css" type="text/css" media="screen" charset="utf-8"/>
    <link rel="stylesheet" href="css/demo_table.css" type="text/css" media="screen" charset="utf-8"/>
    <link type="text/css" href="css/flick/jquery-ui-1.8.13.custom.css" rel="stylesheet"/>
    <script type="text/javascript" src="js/jquery-1.4.4.min.js"></script>
    <script type="text/javascript" src="js/jquery.dataTables.js"></script>
    <script type="text/javascript" src="popupControls.js"></script>
    <script type="text/javascript" src="js/jquery-ui-1.8.13.custom.min.js"></script>
    <script type="text/javascript" src="formgenerator.js"></script>
    <script type="text/javascript" src="js/jquery-plugins/jquery.form.js"></script>
    <script type="text/javascript" src="js/datatables_util.js"></script>
    <script type="text/javascript" src="js/jquery.validate.js"></script>
    <script type="text/javascript">
        var oTable;
        $(document).ready(function() {

           oTable = $('#datatable').dataTable({
                "bProcessing": true,
                "bSortClasses": false,
                "bStateSave": true,
                "oLanguage": {
                    "sSearch": "Sök:",
                    "sInfo": "Visar _START_ - _END_ av totalt _TOTAL_ rader",
                    "sLengthMenu": "Visa _MENU_ rader"
                },
                "sAjaxSource": "fairview/ajax/datatables/get_employee_data.do",
                "aoColumns": [
                    { "mDataProp": "firstname"},
                    { "mDataProp": "lastname" },
                    { "mDataProp": "unit_name" },
                    { "mDataProp": "employment_title" }
                ],
                "fnDrawCallback" : function() {
                    var datatable = this;
                    var trNodes = this.fnGetNodes();
                    var tdNodes = $(trNodes).children();
                    $.each(tdNodes, function() {
                        var data = datatable.fnGetData(this.parentElement);
                        if (this.cellIndex == '3') {  //employee-cell
                            initEmploymentCell(data.employment_id, data.node_id, this);
                        }
                        else if (this.cellIndex == '2') { //unit-cell
                            initUnitCell(data.unit_id, this, datatable);
                        }
                        else if (isEmployeeDataColumn(this.cellIndex)) {
                            initEmployeeCell(data.node_id, data.employment_id, this, datatable);
                        }
                    });
                    $('td', datatable.fnGetNodes()).hover(function() {
                        $('td').removeClass('cell_highlight');
                        $(this).addClass('cell_highlight');
                    });
                }
            });

            fadeOutModalizer();
        });

        function isEmployeeDataColumn(cellIndex) {
            if (cellIndex == '0' || cellIndex == '1' || cellIndex == '2' || cellIndex == '3')
                return true;
            else
                return false;
        }

        function generateProfileForm(unitId) {
            var data = getNodeData(unitId);
            $('#profile-employmentinfo').empty().append(generateProfileEmploymentInfoForm(data, oTable));
            //$('#profile-employmentinfo').append(footerButtonsComponent('profile_form', assignFunctionCallback(unitId, oTable)));
        }

        function generateEmploymentForm(unitId, employmentId){
            var data = getNodeData(unitId);
//            var employmentId = data.employment_id;
            $('#employment-general').empty().append(generateEmploymentCreationForm(employmentId, unitId));
            $('#employment-general').append(footerButtonsComponent('employment_form', assignFunctionCallback(employmentId, oTable)));
        }

        function createEmployeeTab(nodeId, employmentId){
            var linkData = [
                ['profile-employmentinfo', 'Anställningsuppgifter'],
                ['profile-responsibility', 'Arbetsbeskrivning'],
                ['profile-competence', 'Kompetens'],
                ['profile-experience', 'Erfarenhet'],
                ['employment-general', 'Anställningsvillkor']
            ];
            $('#popup-dialog').empty().append(generateTabs(linkData));
            bindTabs();
            generateProfileForm(nodeId);
            generateEmploymentForm(nodeId, employmentId);
        }

        function openEmployeeForm() {

//            generateProfileForm(nodeId);
            openPopupTab(0);
        }

        function openUnitForm(unitId) {
            var linkData = [
                                ['unitsettings-general', 'Avdelningsinställningar'],
                                ['unitsettings-subunits', 'Lägg till Underavdelning'],
                            ];
            $('#popup-dialog').empty().append(generateTabs(linkData));
            bindTabs();
            var data = getNodeData(unitId);
            $('#unitsettings-general').empty().append(generateBaseUnitEditForm(data, oTable));
            generateSingleAddressComponent(data).insertAfter('#web-field');
            openPopupTab(0);
        }
        function openEmploymentForm(employmentId, nodeId){

//            $('#employment-general').empty().append(generateEmploymentCreationForm(employmentId, nodeId));
//            $('#employment-general').append(footerButtonsComponent('employment_form', assignFunctionCallback(employmentId, oTable)));
            openPopupTab(4);
        }
    </script>
</head>
<%@include file="WEB-INF/jspf/iqpageheader.jsp" %>
<body class="ex_highlight_row">
<div id="main">
    <div id="content">
        <div class="newpersontop"><img src="images/newperson.png" class="helpbox-image"><span>Lägg till person</span></div>
        <div class="datatable">
            <table cellpadding="0" cellspacing="0" border="0" class="display" id="datatable">
                <thead>
                <tr>
                    <th>Förnamn</th>
                    <th>Efternamn</th>
                    <th>Enhet</th>
                    <th>Titel</th>
                </tr>
                </thead>
                <tbody>

                </tbody>
                <tfoot>
                <tr>
                    <th>Förnamn</th>
                    <th>Efternamn</th>
                    <th>Enhet</th>
                    <th>Titel</th>
                </tr>
                </tfoot>
            </table>
        </div>
        <div class="newpersonbottom"><img src="images/newperson.png" class="helpbox-image"><span>Lägg till person</span></div>
    </div>
</div>
<div id="modalizer">&nbsp;</div>
<div id="popup-dialog" style="display: none;"></div>
</body>
</html>