<%@ page import="org.neo4j.kernel.EmbeddedGraphDatabase" %>
<%@ page import="org.springframework.web.context.support.WebApplicationContextUtils" %>
<%@ page import="org.neo4j.graphdb.Node" %>
<%@ page import="org.neo4j.graphdb.Relationship" %>
<%@ page import="se.codemate.neo4j.SimpleRelationshipType" %>
<%@ page import="org.neo4j.graphdb.Direction" %>

<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%

    String parentNodeName = request.getParameter("parentName");
    //Long parentId = Long.parseLong(request.getParameter("parentId"));
    Long unitId = Long.parseLong(request.getParameter("unitId"));

    EmbeddedGraphDatabase neo = (EmbeddedGraphDatabase) WebApplicationContextUtils.getWebApplicationContext(application).getBean("neo");

    Node unitNode = neo.getNodeById(unitId);
    //Node organization = ((Iterable<Relationship>) neo.getReferenceNode().getRelationships(SimpleRelationshipType.withName("HAS_ORGANIZATION"), Direction.OUTGOING)).iterator().next().getEndNode();

    Relationship managerRelationship = null;
    String manager = "-";

    try {

        managerRelationship = ((Iterable<Relationship>) unitNode.getRelationships(SimpleRelationshipType.withName("HAS_MANAGER"), Direction.OUTGOING)).iterator().next();

    } catch (Exception ex) {

    }

    if (managerRelationship != null) {

        manager = managerRelationship.getEndNode().getProperty("firstname", "") + " " + managerRelationship.getEndNode().getProperty("lastname", "");

    }

%>

<div class="header text-header" id="subunit_header<%=unitId%>">
    Underliggande enhet till <%=parentNodeName%>
<div class="expand-contract"><img onclick="toggleExpand(event)" id="subunit<%=unitId%>-expand" src="images/contract.png"></div>
</div>
<div id="subunit<%=unitId%>-list" class="list-body profile-list">
<form id="subunit_form<%=unitId%>" action="neo/ajax/update_properties.do" method="post">
<fieldset>
<input type="hidden" name="_id" value="<%=unitId%>">
<input type="hidden" name="_type" value="node">
<input type="hidden" name="_strict" value="true">
<input type="hidden" name="_username" value="admin">
<input type="hidden" name="nodeClass" value="unit">
<div class="field-box"><b>Namn</b><br><%=unitNode.getProperty("name", "-")%></div>
<br>
    <br>
<div class="field-box"><b>Beskrivning</b><br><%=unitNode.getProperty("description", "-")%></div>
<br>
    <br>
<div class="field-box"><b>Chef</b><br><%=manager%></div>
<br>
<br>
<div class="field-box"><b>Telefonnummer</b><br><%=unitNode.getProperty("phone", "-")%></div>
<br>
    <br>
<div class="field-box"><b>Faxnummer</b><br><%=unitNode.getProperty("fax", "-")%></div>
    <br>
<br>
<div class="field-box"><b>E-post</b><br><%=unitNode.getProperty("email", "-")%></div>
    <br>
<br>
<div class="field-box"><b>Hemsida</b><br><%=unitNode.getProperty("web", "-")%></div>
    <br>
<br>
<div class="field-box"><b>Adress</b><br><%=unitNode.getProperty("streetaddress", "-")%></div>
<br>
    <br>
<div class="field-box"><b>Postnummer</b><br><%=unitNode.getProperty("postalcode", "-")%></div>
<br>
    <br>
<div class="field-box"><b>Ort</b><br><%=unitNode.getProperty("city", "-")%></div>
<br>
    <br>
<div class="field-box"><b>Land</b><br><%=unitNode.getProperty("country", "-")%></div>
<br>
    <br>
&nbsp;
</fieldset>
</form>
</div>
<div id="subunit<%=unitId%>-footer" class="list-footer">
    &nbsp;
</div>

<%
                        for (Relationship entry : unitNode.getRelationships(SimpleRelationshipType.withName("HAS_UNIT"))) {

                            try {

                                if (entry.getEndNode().getId() != unitId) {
                                //String unitName = entry.getEndNode().getProperty("name").toString();


                    %>

                        <jsp:include page="unit.jsp">
                            <jsp:param name="parentName" value="<%=unitNode.getProperty("name", "")%>"></jsp:param>
                            <jsp:param name="parentId" value="<%=unitNode.getId()%>"></jsp:param>
                            <jsp:param name="unitId" value="<%=entry.getEndNode().getId()%>"></jsp:param>
                        </jsp:include>

                    <%
                                }

                            } catch (Exception ex) {
                                   response.getWriter().write(ex.getMessage());
                            }

                        }
                    %>