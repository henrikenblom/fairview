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
    <script type="text/javascript">
        $(document).ready(function() {
            $('#example').dataTable({
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
        });
    </script>
</head>
<%@include file="WEB-INF/jspf/iqpageheader.jsp" %>
<body>
<div id="main">
    <div style="width: 1000px">
        <table cellpadding="0" cellspacing="0" border="0" class="display" id="example">
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
</body>
</html>