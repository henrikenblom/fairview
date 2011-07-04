<%@ page import="org.neo4j.kernel.EmbeddedGraphDatabase" %>
<%@ page import="org.springframework.web.context.support.WebApplicationContextUtils" %>
<%@ page import="org.neo4j.graphdb.Node" %>
<%@ page import="org.neo4j.graphdb.Relationship" %>
<%@ page import="se.codemate.neo4j.SimpleRelationshipType" %>
<%@ page import="org.neo4j.graphdb.Direction" %>
<%

    String parentNodeName = request.getParameter("parentName");
    Long parentId = Long.parseLong(request.getParameter("parentId"));
    Long unitId = Long.parseLong(request.getParameter("unitId"));
    Integer treeLevel = Integer.parseInt(request.getParameter("level"));

    EmbeddedGraphDatabase neo = (EmbeddedGraphDatabase) WebApplicationContextUtils.getWebApplicationContext(application).getBean("neo");
    Node unitNode = neo.getNodeById(unitId);
    Node organization = ((Iterable<Relationship>) neo.getReferenceNode().getRelationships(SimpleRelationshipType.withName("HAS_ORGANIZATION"), Direction.OUTGOING)).iterator().next().getEndNode();

    String unitName = (String) unitNode.getProperty("name", "Namnl&ouml;s enhet");

    String referenceId = "";

    String description = (String) unitNode.getProperty("description", "-");

    if (description.length() > 40) {

        description = description.substring(0, 40) + "...";

    }

    if (parentId != organization.getId()) {

        referenceId = String.valueOf(parentId);

    }

%>

<div class="unit-list-entry">

    <div class="unit-list-cell list-entry"><a href="javascript: changeView('organisationdetails.jsp?unitId=<%=referenceId%>')"><%= parentNodeName%></a></div>
    <div class="unit-list-cell"><a href="javascript: changeView('organisationdetails.jsp?unitId=<%=unitId%>')"><%=unitName%></a></div>
    <div class="unit-list-cell"><%=description%></div>
</div>
<%
                        for (Relationship entry : unitNode.getRelationships(SimpleRelationshipType.withName("HAS_UNIT"))) {

                            try {

                                if (entry.getEndNode().getId() != unitId) {
                                //String unitName = NodeFieldHelper.safeGetProperty(entry.getEndNode(), "name", "Namnlös enhet");
    %>
                        <jsp:include page="unitlistentry.jsp">
                            <jsp:param name="parentName" value="<%=unitName%>"></jsp:param>
                            <jsp:param name="parentId" value="<%=unitId%>"></jsp:param>
                            <jsp:param name="unitId" value="<%=entry.getEndNode().getId()%>"></jsp:param>
                            <jsp:param name="level" value="<%=treeLevel%>"></jsp:param>
                        </jsp:include>
    <%
                }
        } catch (Exception ex) {
                    //ex.printStackTrace();
        }
        }
    %>