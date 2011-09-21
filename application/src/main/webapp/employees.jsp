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
                    { "mDataProp": "phone" },
                    { "mDataProp": "email" },
                    { "mDataProp": "unit_name" },
                    { "mDataProp": "function_name" }
                ],
                "fnDrawCallback" : function() {
                    var datatable = this;
                    var trNodes = this.fnGetNodes();
                    var tdNodes = $(trNodes).children();
                    $.each(tdNodes, function() {
                        var data = datatable.fnGetData(this.parentElement);
                        if (this.cellIndex == '5') {  //function-cell
                            initFunctionCell(data.function_id, this);
                        }
                        else if (this.cellIndex == '4') { //unit-cell
                            initUnitCell(data.unit_id, this, datatable);
                        }
                        else if (isEmployeeDataColumn(this.cellIndex)) {
                            initEmployeeCell(data.node_id, this, datatable);
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

        function clearProfileForm(){
            $('#profile-general').empty();
            $('#profile-education').empty();
        }

        function generateProfileForm(unitId) {
            var data = getNodeData(unitId);
            clearProfileForm();

            $('#profile-general').append(generateProfileGeneralForm(data, oTable));
            $('#profile-general').append(footerButtonsComponent(updateTableCallback(oTable)));

            addPreexistingLanguages(unitId);
            addPreexistingEducations(unitId);

            $('#profile-education').append(addLanguageButton(unitId));
            $('#profile-education').append(addEducationButton(unitId));
            $('#profile-education').append(footerButtonsComponent(updateTableCallback(oTable)));
        }
        function openEmployeeForm(nodeId) {
            var linkData = [
                ['profile-general', 'Allmänt'],
                ['profile-education', 'Utbildning'],
                ['profile-experience', 'Erfarenhet']
            ];
            $('#popup-dialog').empty().append(generateTabs(linkData));
            bindTabs();
            generateProfileForm(nodeId)
            openPopupTab(0);
        }
        function openUnitForm(unitId) {
            var linkData = [
                ['unitsettings-general', 'Avdelningsinställningar'],
                ['unitsettings-subunits', 'Lägg till Underavdelning'],
                ['unitsettings-functions', 'Funktioner']
            ];
            $('#popup-dialog').empty().append(generateTabs(linkData));
            bindTabs();
            var data = getNodeData(unitId);
            $('#unitsettings-general').empty().append(generateBaseUnitEditForm(data, oTable));
            generateSingleAddressComponent(data).insertAfter('#web-field');
            $('#unitsettings-general').append(footerButtonsComponent(updateTableCallback(oTable)));
            openPopupTab(0);
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
                    <th>Telefon</th>
                    <th>E-post</th>
                    <th>Enhet</th>
                    <th>Funktion</th>
                </tr>
                </thead>
                <tbody>

                </tbody>
                <tfoot>
                <tr>
                    <th>Förnamn</th>
                    <th>Efternamn</th>
                    <th>Telefon</th>
                    <th>E-post</th>
                    <th>Enhet</th>
                    <th>Funktion</th>
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