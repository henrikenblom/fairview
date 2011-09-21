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
    <script type="text/javascript">
        var oTable;
        $(document).ready(function() {
            oTable = $('#datatable').dataTable({
                "bProcessing": true,
                "sAjaxSource": "fairview/ajax/datatables/get_function_data.do",
                "aoColumns": [
                    { "mDataProp": "function_name"},
                    { "mDataProp": "description" },
                    { "mDataProp": "unit_name" }
                ]
            });
            <%--
   $('#datatable tbody tr td').live('click', function () {
       var data = oTable.fnGetData(this.parentElement);
       if (this.cellIndex == '5') {
           alert(data.function_id);
       }
       else if (this.cellIndex == '4') {
           alert(data.unit_id);
       }
       else if (this.cellIndex == '0' || this.cellIndex == '1') {
           generateProfileForm(data.node_id)
           openPopupTab(0);
       }
   });
            --%>

            fadeOutModalizer();
            createTabs();

        });
        function generateProfileForm(unitId) {
            var data = getNodeData(unitId);
            $('#profile-general').empty().append(generateProfileGeneralForm(data));
        }
    </script>
</head>
<%@include file="WEB-INF/jspf/iqpageheader.jsp" %>
<body>
<div id="main">
    <div id="content">
        <div class="newfunctiontop"><img src="images/newfunction.png"
                                         class="helpbox-image"><span>Lägg till funktion</span></div>
        <table cellpadding="0" cellspacing="0" border="0" class="display" id="datatable">
            <thead>
            <tr>
                <th>Benämning</th>
                <th>Beskrivning</th>
                <th>Enhet</th>
            </tr>
            </thead>
            <tbody>

            </tbody>
            <tfoot>
            <tr>
                <th>Benämning</th>
                <th>Beskrivning</th>
                <th>Enhet</th>
            </tr>
            </tfoot>
        </table>
        <div class="newfunctionbottom"><img src="images/newfunction.png"
                                            class="helpbox-image"><span>Lägg till funktion</span></div>
    </div>
</div>
<div id="modalizer">&nbsp;</div>
<div id="popup-dialog" style="display: none;">
    <div id="popup-tabs"></div>
</div>
</body>
</html>
