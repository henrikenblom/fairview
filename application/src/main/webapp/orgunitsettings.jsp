<%--
  Created by IntelliJ IDEA.
  User: fairview
  Date: 7/6/11
  Time: 4:33 PM
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@include file="WEB-INF/jspf/beanMapper.jsp" %>
<%
    StringBuilder managerSnippet = new StringBuilder();

    for (Node entry : personListGenerator.getSortedList(PersonListGenerator.ALPHABETICAL, false)) {

        try {

            if (!entry.getProperty("firstname", "").equals("") || !entry.getProperty("lastname", "").equals("")) {


                managerSnippet.append("<option value=\"");
                managerSnippet.append(entry.getId());
                managerSnippet.append("\">");
                managerSnippet.append(entry.getProperty("lastname", ""));
                managerSnippet.append(", ");
                managerSnippet.append(entry.getProperty("firstname", ""));
                managerSnippet.append("</option>\\\n");

            }
        } catch (Exception ex) {

        }

    }
%>
<link rel="stylesheet" href="css/newlook.css" type="text/css" media="screen" charset="utf-8"/>
<script type="text/javascript" src="js/jquery-1.4.4.min.js"></script>
<script type="text/javascript" src="orgunitsettings.js"></script>
<script type="text/javascript">
    $(document).ready(function() {
        generateOrgUnitForm();
    });
</script>

<div id="content">
</div>