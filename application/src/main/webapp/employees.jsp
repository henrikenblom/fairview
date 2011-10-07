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
    <link type="text/css" href="css/jquery-ui/jquery-ui-1.8.13.custom.css" rel="stylesheet"/>
    <script type="text/javascript" src="js/plugins/jquery-1.4.4.min.js"></script>
    <script type="text/javascript" src="js/plugins/jquery.dataTables.js"></script>
    <script type="text/javascript" src="js/popupControls.js"></script>
    <script type="text/javascript" src="js/plugins/jquery-ui-1.8.13.custom.min.js"></script>
    <script type="text/javascript" src="js/formgenerator.js"></script>
    <script type="text/javascript" src="js/plugins/jquery.form.js"></script>
    <script type="text/javascript" src="js/datatables_util.js"></script>
    <script type="text/javascript" src="js/plugins/jquery.validate.js"></script>
    <script type="text/javascript">
        var oTable;
        $(document).ready(function() {
            $('.newperson').click(function() {
                var data = new Array;
                createEmployeeTab(data);
                openEmployeeForm();
            });

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
                    { "mDataProp": "employment_title" },
                    { "mDataProp": null,  "sWidth": 10, fnRender: getEmployeeDeleteButton, "bSortable": false, "bSearchable": false  }

                ],
                "fnDrawCallback" : function() {
                    var datatable = this;
                    var trNodes = this.fnGetNodes();
                    var tdNodes = $(trNodes).children();
                    $.each(tdNodes, function() {
                        var data = datatable.fnGetData(this.parentNode);
                        if (this.cellIndex == '3') {  //employee-cell
                            initEmploymentCell(data, this);
                        }
                        else if (this.cellIndex == '2') { //unit-cell
                            initUnitCell(data.unit_id, this);
                        }
                        else if (isEmployeeDataColumn(this.cellIndex)) {
                            initEmployeeCell(data, this);
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
            if (cellIndex == '0' || cellIndex == '1' || cellIndex == '3')
                return true;
            else
                return false;
        }

        function createEmployeeTab(data) {

            var linkData = [
                ['profile-general', 'Personuppgifter'],
                ['profile-education', 'Utbildning'],
                ['profile-experience', 'Erfarenhet'],
                ['employment-general', 'Anställningsvillkor']
            ];
            $('#popup-dialog').empty().append(generateTabs(linkData));
            bindTabs();
            generateProfileForm(data.employee_id);
            generateEmploymentForm(data);
        }

        function openEmployeeForm() {
            openPopupTab(0);
        }
        function openUnitForm(unitId) {
            var linkData = [
                ['unitsettings-general', 'Avdelningsinställningar']];
            $('#popup-dialog').empty().append(generateTabs(linkData));
            bindTabs();
            var data = getUnitData(unitId);
            $('#unitsettings-general').empty().append(generateBaseUnitEditForm(data, oTable));
            generateSingleAddressComponent(data).insertAfter($('#web-field').parent());
            $('#unitsettings-general').append(footerButtonsComponent(unitId, updateTableCallback(oTable)));
            openPopupTab(0);
        }
        function openEmploymentForm() {
            openPopupTab(3);
        }
    </script>
</head>
<%@include file="WEB-INF/jspf/iqpageheader.jsp" %>
<body class="ex_highlight_row">
<div id="main">
    <div id="content">
        <div class="newperson newpersontop"><img src="images/newperson.png"
                                                 class="helpbox-image"><span>Lägg till person</span>
        </div>
        <div class="datatable">
            <table cellpadding="0" cellspacing="0" border="0" class="display" id="datatable">
                <thead>
                <tr>
                    <th>Förnamn</th>
                    <th>Efternamn</th>
                    <th>Enhet</th>
                    <th>Titel</th>
                    <th></th>
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
                    <th></th>
                </tr>
                </tfoot>
            </table>
        </div>
        <div class="newperson newpersonbottom"><img src="images/newperson.png" class="helpbox-image"><span>Lägg till person</span>
        </div>
    </div>
</div>
<div id="modalizer">&nbsp;</div>
<div id="popup-dialog" style="display: none;"></div>
</body>
</html>