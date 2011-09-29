<%--
  Created by IntelliJ IDEA.
  User: henrik
  Date: 2011-09-07
  Time: 10:39
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@include file="WEB-INF/jspf/beanMapper.jsp" %>

<html>
<head>
    <title>Infero Quest - Funktioner</title>
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
                "sAjaxSource": "fairview/ajax/datatables/get_employment_data.do",
                "aoColumns": [
                    { "mDataProp": "unit_name"},
                    { "mDataProp": "employment_title" },
                    { "mDataProp": "firstname" },
                    { "mDataProp": "lastname" }
                ],
                "fnDrawCallback" : function() {
                    var datatable = this;
                    var trNodes = this.fnGetNodes();
                    var tdNodes = $(trNodes).children();
                    $.each(tdNodes, function() {
                        var data = datatable.fnGetData(this.parentElement);
                        if (this.cellIndex == '2' || this.cellIndex == '3') {  //employee-cell
                            //initEmployeeCell(data.employee_id, data.employment_id, data.unit_id, this);
                            initEmployeeCell(data, this);
                        }
                        else if (this.cellIndex == '1') { //employment-cell
                            //initEmploymentCell(data.employment_id, data.employee_id, data.unit_id, this);
                            initEmploymentCell(data, this);
                        }
                        else if (this.cellIndex == '0') { // unit-cell
                            initUnitCell(data.unit_id, this);
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

        function createEmployeeTab(data) {
            var linkData = [
                ['employment-general', 'Anställningsvillkor'],
                ['profile-general', 'Personuppgifter'],
                ['profile-education', 'Utbildning'],
                ['profile-experience', 'Erfarenhet']
            ];
            $('#popup-dialog').empty().append(generateTabs(linkData));
            bindTabs();
            generateProfileForm(data.employee_id);
            generateEmploymentForm(data);
        }

        function openEmploymentForm() {
            openPopupTab(0);
        }

        function openEmployeeForm() {
            openPopupTab(1);
        }
        function openUnitForm(unitId) {
            var linkData = [
                ['unitsettings-general', 'Avdelningsinställningar'],
            ];
            $('#popup-dialog').empty().append(generateTabs(linkData));
            bindTabs();
            var data = getUnitData(unitId);
            $('#unitsettings-general').empty().append(generateBaseUnitEditForm(data, oTable));
            generateSingleAddressComponent(data).insertAfter($('#web-field').parent());
            $('#unitsettings-general').append(footerButtonsComponent(unitId, updateTableCallback(oTable)));
            openPopupTab(0);
        }

    </script>
</head>
<%@include file="WEB-INF/jspf/iqpageheader.jsp" %>
<body class="ex_highlight_row">
<div id="main">
    <div id="content">
        <div class="datatable">
            <table cellpadding="0" cellspacing="0" border="0" class="display" id="datatable">
                <thead>
                <tr>
                    <th>Enhet</th>
                    <th>Titel</th>
                    <th>Förnamn</th>
                    <th>Efternamn</th>
                </tr>
                </thead>
                <tbody>

                </tbody>
                <tfoot>
                <tr>
                    <th>Enhet</th>
                    <th>Titel</th>
                    <th>Förnamn</th>
                    <th>Efternamn</th>
                </tr>
                </tfoot>
            </table>
        </div>
    </div>
</div>
<div id="modalizer">&nbsp;</div>
<div id="popup-dialog" style="display: none;"></div>
</body>
</html>