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
        <title>Infero Quest - Funktioner</title>
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
                <div class="header"><input type="text" class="text-field filter-field" onkeyup="functionTextFilter(event)" placeholder="Funktion/Medarbetare/Beskrivning" id="function-text-filter"></div>
                <div id="function-list" class="list-body">
                    <%

                        for (Node function : functionListGenerator.getSortedList(FunctionListGenerator.ALPHABETICAL, false)) {

                            Node employee = null;

                            try {

                                Traverser employmentTraverser = function.traverse(Traverser.Order.BREADTH_FIRST, StopEvaluator.END_OF_GRAPH, ReturnableEvaluator.ALL_BUT_START_NODE, SimpleRelationshipType.withName("PERFORMS_FUNCTION"), Direction.INCOMING);
                                Traverser employeeTraverser = employmentTraverser.iterator().next().traverse(Traverser.Order.BREADTH_FIRST, StopEvaluator.END_OF_GRAPH, ReturnableEvaluator.ALL_BUT_START_NODE, SimpleRelationshipType.withName("HAS_EMPLOYMENT"), Direction.INCOMING);

                                employee = employeeTraverser.iterator().next();

                                } catch (Exception ex) {

                                }

                                try {

                                    String name = (String) function.getProperty("name", "Namnlös");

                                    if (name.length() > 32) {

                                        name = name.substring(0, 29).trim() + "…" + name.substring(name.length() - 2, name.length());

                                    }

                    %>

                            <div class="function-list-entry">
                                <div class="function-list-cell list-entry"><a href="functiondetails.jsp?id=<%= function.getId()%>"><%=name%></a></div>
                                <div class="function-list-cell"><% if (employee != null && !employee.getProperty("lastname", "").equals("")) { %><a href="coworkerprofile.jsp?id=<%= employee.getId()%>"><%= employee.getProperty("lastname")%>, <%= employee.getProperty("firstname")%></a><% } else {%><b>Vakant</b><% } %></div>
                                <div class="function-list-cell"><%=function.getProperty("description", "-")%></div>
                            </div>

                    <%
                            } catch (Exception ex) {
                            }
                        }
                    %>
                </div>

                <div class="list-footer">
                    <a href="functiondetails.jsp">Lägg till funktion</a>
                </div>
            </div>
            <div id="modalizer">&nbsp;</div>
        </div>
    </body>
</html>
