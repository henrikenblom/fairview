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
    <li> <span id="unitsettings-general-tablink" name="unitsettings-general-tablink<%=unitId%>" onclick="generateSubUnitForm(<%=unitId%>); openUnitSettingsOnTab(0);"><%=unitName%></span>
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

