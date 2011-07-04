<%--
  Created by IntelliJ IDEA.
  User: henrik
  Date: 2011-03-18
  Time: 09.10
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%@include file="WEB-INF/jspf/beanMapper.jsp" %>

<%

    Node employee = neo.getNodeById(Long.decode((String) request.getParameter("id")));
    HashMap<Long, Long> belongsToUnits = new HashMap<Long, Long>();
    HashMap<Long, Node> functionMap = new HashMap<Long, Node>();
    boolean hasAuthority = (employee.getProperty("executive", "").equals("true")
            || employee.getProperty("budget-responsibility", "").equals("true")
            || employee.getProperty("own-result-responsibility", "").equals("true")
            || employee.getProperty("authorization", "").equals("true"));

    for (Relationship entry : organization.getRelationships(SimpleRelationshipType.withName("HAS_FUNCTION"), Direction.OUTGOING)) {

        try {

        Traverser employmentTraverser = entry.getEndNode().traverse(Traverser.Order.BREADTH_FIRST, StopEvaluator.END_OF_GRAPH, ReturnableEvaluator.ALL_BUT_START_NODE, SimpleRelationshipType.withName("PERFORMS_FUNCTION"), Direction.INCOMING);
        Traverser employeeTraverser = employmentTraverser.iterator().next().traverse(Traverser.Order.BREADTH_FIRST, StopEvaluator.END_OF_GRAPH, ReturnableEvaluator.ALL_BUT_START_NODE, SimpleRelationshipType.withName("HAS_EMPLOYMENT"), Direction.INCOMING);

        while (employeeTraverser.iterator().hasNext()) {

            functionMap.put(employeeTraverser.iterator().next().getId(), entry.getEndNode());

        }

        } catch (Exception ex) {

            // noop

        }

    }

    for (Relationship entry : employee.getRelationships(SimpleRelationshipType.withName("BELONGS_TO"), Direction.OUTGOING)) {

        belongsToUnits.put(entry.getEndNode().getId(),entry.getId());

    }

%>
<html>
    <head>
        <title>Infero Quest - Medarbetare</title>
        <link rel="stylesheet" href="css/newlook.css" type="text/css" media="screen" charset="utf-8" />
        <script type="text/javascript" src="js/jquery-1.4.4.min.js"></script>
        <script type="text/javascript" src="iq.js"></script>
        <script type="text/javascript">
            $(document).ready(function() {

                $('#modalizer').fadeOut(500);
                adjustViewPort();

            });
        </script>
    </head>
    <body onresize="adjustViewPort()">
        <%@include file="WEB-INF/jspf/iqpageheader.jsp" %>
        <div id="main">
            <div id="content">
                <div class="header text-header">
                    Anställningsuppgifter - <% if (!employee.getProperty("civic", "").equals("")) { %><%=employee.getProperty("civic", "")%> - <%}%><%=employee.getProperty("lastname", "")%>, <%=employee.getProperty("firstname", "")%> <% if (employee.getProperty("gender", "").equals("M")) { %> (Man)<% } %><% if (employee.getProperty("gender", "").equals("F")) { %> (Kvinna)<% } %><div class="expand-contract"><img onclick="toggleExpand(event)" id="profile-expand" src="images/contract.png"></div>
                </div>
                <div class="list-body profile-list" id="profile-list">
                    <br>
                    <div class="field-box"><b>Nationalitet</b><br><%= employee.getProperty("nationality", "Svensk")%></div>
                    <br>
                    <br>
                    <div class="field-box"><b>Anställningsnummer</b><br><%= employee.getProperty("employmentid", "-")%></div>
                    <br>
                    <br>
                    <div class="field-box"><b>Adress</b><br><%= employee.getProperty("address", "")%>
                        <br>
                        <%= employee.getProperty("zip", "")%> <%= employee.getProperty("city", "")%>
                        <br>
                        <%=employee.getProperty("country", "Sverige")%>
                    </div>
                    <br>
                    <br>
                    <div class="field-box"><b>Telefon</b><br><%= employee.getProperty("phone", "-")%></div>
                    <br>
                    <br>
                    <div class="field-box"><b>Mobiltelefon</b><br><%= employee.getProperty("cell", "-")%></div>
                    <br>
                    <br>
                    <div class="field-box"><b>E-post</b><br><%= employee.getProperty("email", "-")%></div>
                    <br>
                    <br>
                    <div class="field-box"><b>Funktion</b><br>
                    <%
                        if (functionMap.get(employee.getId()) != null) {
                            %>
                                <%=functionMap.get(employee.getId()).getProperty("name")%>
                            <%
                        }
                    %>
                    </div>
                    <br>
                    <br>
                    <div class="field-box"><b>Enhet<%=belongsToUnits.size() > 1 ? "er" : ""%></b><br>
                        <%
                            int c = 1;
                            for (Long unitId : belongsToUnits.keySet()) {

                                %>
                                    <%=neo.getNodeById(unitId).getProperty("name", "Namnlös enhet")%><%=c != belongsToUnits.size() ? "," : ""%>
                                <%

                                c++;

                            }
                        %>
                    </div>
                    <br>
                    <br>
                </div>
                <div id="profile-footer" class="list-footer">&nbsp;</div>
            </div>
        </div>

        <div id="modalizer">&nbsp;</div>
        </div>
    </body>
</html>