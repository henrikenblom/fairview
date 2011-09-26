<%@page contentType="text/html" pageEncoding="UTF-8" %>
<%@ page import="org.neo4j.kernel.EmbeddedGraphDatabase" %>
<%@ page import="org.springframework.web.context.support.WebApplicationContextUtils" %>
<%@ page import="org.neo4j.graphdb.Node" %>
<%@ page import="org.neo4j.graphdb.Relationship" %>
<%@ page import="se.codemate.neo4j.SimpleRelationshipType" %>

<%

    Long unitId = Long.parseLong(request.getParameter("unitId"));

    EmbeddedGraphDatabase neo = (EmbeddedGraphDatabase) WebApplicationContextUtils.getWebApplicationContext(application).getBean("neo");
    Node unitNode = neo.getNodeById(unitId);

%>

<button class="imageonly-button" title="Lägg till underenhet" onclick="javascript:generateSubunitPopup(<%=unitId%>); openPopupTab(1);"><img src="images/newunit.png" alt="Ny underenhet"></button>
<button class="imageonly-button" title="Ta bort enhet" onclick="javascript:generateDeleteDialog(<%=unitId%>);"><img src="images/delete.png" alt="Ny underenhet"></button>

<%
    for (Relationship entry : unitNode.getRelationships(SimpleRelationshipType.withName("HAS_UNIT"))) {

        try {

            if (entry.getEndNode().getId() != unitId) {
%>
<br>
<jsp:include page="unittreecontrol.jsp">
    <jsp:param name="unitId" value="<%=entry.getEndNode().getId()%>"></jsp:param>
</jsp:include>

<%
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
    }
%>

