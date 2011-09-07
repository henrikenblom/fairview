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
    <script type="text/javascript">
        var oTable;
        $(document).ready(function() {
            oTable = $('#datatable').dataTable({
                "bProcessing": true,
                "sAjaxSource": "fairview/ajax/datatables/get_employee_data.do",
                "aoColumns": [
                    { "mDataProp": "firstname"},
                    { "mDataProp": "lastname" },
                    { "mDataProp": "phone" },
                    { "mDataProp": "email" },
                    { "mDataProp": "unit_name" },
                    { "mDataProp": "function_name" }
                ]
            });

            $('#datatable tbody tr td').live('click', function () {
                var data = oTable.fnGetData(this.parentElement);
                if (this.cellIndex == '5') {
                    alert(data.function_id);
                }
                else if (this.cellIndex == '4') {
                    alert(data.unit_id);
                }
                else if (this.cellIndex == '0' || this.cellIndex == '1') {
                    openEmployeeForm(data);
                }
            });

            fadeOutModalizer();
            setupModalizerClickEvents();

        });
        function generateProfileForm(unitId) {
            var data = getNodeData(unitId);
            $('#profile-employmentinfo').empty().append(generateProfileEmploymentInfoForm(data));
        }
         function openEmployeeForm(data) {
            var linkData = [
                ['profile-employmentinfo', 'Anställningsuppgifter'],
                ['profile-responsibility', 'Arbetsbeskrivning'],
                ['profile-competence', 'Kompetens'],
                ['profile-experience', 'Erfarenhet']
            ];
            $('#popup-dialog').append(generateTabs(linkData));
            bindTabs();
            generateProfileForm(data.node_id)
            openPopupTab(0);
        }
    </script>
</head>
<%@include file="WEB-INF/jspf/iqpageheader.jsp" %>
<body>
<div id="main">
    <div style="width: 1000px">
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
</div>
<div id="modalizer">&nbsp;</div>
<div id="popup-dialog" style="display: none;">
</div>
</body>
</html>