<%@ page import="org.neo4j.kernel.EmbeddedGraphDatabase" %>
<%@ page import="org.springframework.web.context.support.WebApplicationContextUtils" %>
<%@ page import="org.neo4j.graphdb.Node" %>
<%@ page import="org.neo4j.graphdb.Relationship" %>
<%@ page import="se.codemate.neo4j.SimpleRelationshipType" %>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%

    Long id = Long.parseLong(request.getParameter("id"));
    boolean calledFromGoal = request.getParameter("called_from").equals("goal");

    EmbeddedGraphDatabase neo = (EmbeddedGraphDatabase) WebApplicationContextUtils.getWebApplicationContext(application).getBean("neo");
    Node node = neo.getNodeById(id);

    boolean isGoal = false;
    Node assignedTo = null;

    if (node.getProperty("nodeClass", "").equals("goal")) {

        isGoal = true;

    } else {

        assignedTo = node.getRelationships(SimpleRelationshipType.withName("ASSIGNED_TO")).iterator().next().getEndNode();

    }

%>

<% if (isGoal) { %>

<div class="goaltask-list-entry">
    <div class="goal-list-cell">

        <%= node.getProperty("title", "")%>

        <% } else {%>

        <div class="task-list-cell">

            <%= node.getProperty("title", "")%> <%=(assignedTo == null || assignedTo.getId() > 0) ? "- inte tilldelad någon" : " - tilldelad \"" + assignedTo.getProperty("name", "-") + "\""%>

            <% } %>

        </div>
        <% if (!isGoal) { %>
    </div>
        <% } %>

        <%
                        String relationShipName = "HAS_TASK";

                        if (!isGoal) {

                            relationShipName = "HAS_GOAL";

                        }

                        for (Relationship entry : node.getRelationships(SimpleRelationshipType.withName(relationShipName))) {

                            try {

                                if (entry.getEndNode().getId() != id) {
    %>
    <jsp:include page="goaltasklistentry.jsp">
        <jsp:param name="id" value="<%=entry.getEndNode().getId()%>"></jsp:param>
        <jsp:param name="called_from" value="<%=entry.getEndNode().getProperty("nodeClass", "")%>"></jsp:param>
    </jsp:include>
<%

            }

        } catch (Exception ex) {
            //ex.printStackTrace();
        }
    }
%>