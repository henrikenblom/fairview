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

    String unitName = (String) unitNode.getProperty("name", "Namnlös enhet");

%>
<%--not unobtrusive javascript,  because this is the only place where unitId is known--%>
    <li> <span id="unitsettings-general-tablink" name="unitsettings-general-tablink<%=unitId%>" onclick="generateSubunitPopup(<%=unitId%>); openPopupTab(0);"><%=unitName%>&nbsp;</span>
        <button class="imageonly-button" title="Lägg till underenhet" onclick="javascript:generateSubunitPopup(<%=unitId%>); openPopupTab(1);"><img src="images/newunit.png" alt="Ny underenhet"></button>
        <sec:authorize ifAnyGranted="ROLE_ADMIN">
        <button class="imageonly-button" title="Ta bort enhet" onclick="javascript:generateDeleteDialog(<%=unitId%>);"><img src="images/delete.png" alt="Ny underenhet"></button>
        </sec:authorize>

<%
                    for (Relationship entry : unitNode.getRelationships(SimpleRelationshipType.withName("HAS_UNIT"))) {

                        try {

                            if (entry.getEndNode().getId() != unitId) {
%>
    <ul>
                    <jsp:include page="unittreeentry.jsp">
                        <jsp:param name="unitId" value="<%=entry.getEndNode().getId()%>"></jsp:param>
                    </jsp:include>

    </ul>
<%
            }
    } catch (Exception ex) {
                ex.printStackTrace();
    }
    }
%>

    </li>

