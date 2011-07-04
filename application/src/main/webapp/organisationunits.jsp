<%-- 
    Document   : functions.jsp
    Created on : 2010-nov-16, 08:49:16
    Author     : henrik
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%@include file="WEB-INF/jspf/beanMapper.jsp" %>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
    "http://www.w3.org/TR/html4/loose.dtd">

<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Infero Quest - Enheter</title>
        <link rel="stylesheet" href="css/newlook.css" type="text/css" media="screen" charset="utf-8" />
        <script type="text/javascript" src="js/jquery-1.4.4.min.js"></script>
        <script type="text/javascript" src="iq.js"></script>
        <script type="text/javascript">
             $(document).ready(function() {

                 adjustViewPort();
                 $('#modalizer').fadeOut(500);

            });
        </script>
    </head>
    <body onload="onload(<%= organization.getId()%>)" onresize="adjustViewPort()">
        <%@include file="WEB-INF/jspf/iqpageheader.jsp" %>
        <div id="main">
            <div id="content">
                <div class="header"><input type="text" class="text-field filter-field" onkeyup="unitTextFilter(event)" placeholder="Organisation/Enhet/Beskrivning" id="unit-text-filter"></div>
                <div id="unit-list" class="list-body">

                    <%
                        Integer treeLevel = 0;

                        String description = (((String) organization.getProperty("description", "-")).length() > 50)
                        ? ((String) organization.getProperty("description", "-")).substring(0, 49).trim() + "…"
                        : ((String) organization.getProperty("description", "-"));

                    %>

                    <div class="unit-list-entry">
                        <div class="unit-list-cell list-entry"><a href="javascript: changeView('organisationdetails.jsp')"><%=organization.getProperty("name", "-")%></a></div>
                        <div class="unit-list-cell">-</div>
                        <div class="unit-list-cell"><%=description%></div>
                    </div>

                        <%
                                        for (Relationship entry : organization.getRelationships(SimpleRelationshipType.withName("HAS_UNIT"))) {

                                            try {

                    %>
                                        <jsp:include page="unitlistentry.jsp">
                                            <jsp:param name="parentName" value="<%=organization.getProperty("name", "-")%>"></jsp:param>
                                            <jsp:param name="parentId" value="<%=organization.getId()%>"></jsp:param>
                                            <jsp:param name="unitId" value="<%=entry.getEndNode().getId()%>"></jsp:param>
                                            <jsp:param name="level" value="<%=treeLevel%>"></jsp:param>
                                        </jsp:include>
                    <%
                        } catch (Exception ex) {
                        }
                        }
                    %>
                </div>
                <div class="list-footer">
                    &nbsp;
                </div>
            </div>
            <div id="modalizer">&nbsp;</div>
        </div>
    </body>
</html>
