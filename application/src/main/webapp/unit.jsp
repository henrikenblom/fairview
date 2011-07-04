<%@ page import="org.neo4j.kernel.EmbeddedGraphDatabase" %>
<%@ page import="org.springframework.web.context.support.WebApplicationContextUtils" %>
<%@ page import="org.neo4j.graphdb.Node" %>
<%@ page import="org.neo4j.graphdb.Relationship" %>
<%@ page import="se.codemate.neo4j.SimpleRelationshipType" %>
<%@ page import="org.neo4j.graphdb.Direction" %>
<%@ page import="com.fairviewiq.utils.PersonListGenerator" %>

<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%

    String parentNodeName = request.getParameter("parentName");
    //Long parentId = Long.parseLong(request.getParameter("parentId"));
    Long unitId = Long.parseLong(request.getParameter("unitId"));

    EmbeddedGraphDatabase neo = (EmbeddedGraphDatabase) WebApplicationContextUtils.getWebApplicationContext(application).getBean("neo");

    Node unitNode = neo.getNodeById(unitId);
    //Node organization = ((Iterable<Relationship>) neo.getReferenceNode().getRelationships(SimpleRelationshipType.withName("HAS_ORGANIZATION"), Direction.OUTGOING)).iterator().next().getEndNode();

    Relationship managerRelationship = null;

    try {

        managerRelationship = ((Iterable<Relationship>) unitNode.getRelationships(SimpleRelationshipType.withName("HAS_MANAGER"), Direction.OUTGOING)).iterator().next();

    } catch (Exception ex) {

    }

%>

<script type="text/javascript">

    function assignManager<%=unitId%>() {

        <% if (managerRelationship != null) { %>

        $.getJSON("neo/ajax/delete_relationship.do", {_relationshipId:<%=managerRelationship.getId()%>}, function() {

            <% } %>

            $.getJSON("neo/ajax/create_relationship.do", {_startNodeId:<%=unitId%>, _type:"HAS_MANAGER", _endNodeId:$('#manager-selection<%=unitId%>').val()});

        <% if (managerRelationship != null) { %>

            });

        <% } %>

    }

</script>

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
<div class="field-box"><div class="field-label-box">Namn</div><div><input type="text" name="name" onchange="$('#subunit_form<%=unitId%>').ajaxSubmit()" class="text-field" id="name-field<%=unitId%>" value="<%=unitNode.getProperty("name", "")%>"></div></div>
<br>
<div class="field-box"><div class="field-label-box">Beskrivning</div><div><textarea name="description" onchange="$('#subunit_form<%=unitId%>').ajaxSubmit()" id="description-field<%=unitId%>"><%=unitNode.getProperty("description", "")%></textarea></div></div>
<br>
<div class="field-box">
<div class="field-label-box">Chef</div>
    <div>
        <select id="manager-selection<%=unitId%>" name="manager" onchange="assignManager<%=unitId%>()">
            <option>Välj...</option>
        <%
            PersonListGenerator personListGenerator = new PersonListGenerator(neo);

            for (Node entry : personListGenerator.getSortedList(PersonListGenerator.ALPHABETICAL, false)) {

                try {

                if (!entry.getProperty("firstname", "").equals("") || !entry.getProperty("lastname", "").equals("")) {

        %>

            <option value="<%= entry.getId()%>" <% if (managerRelationship != null && managerRelationship.getEndNode().getId() == entry.getId()) {%> selected="true"<% } %>><%= entry.getProperty("lastname", "")%>, <%= entry.getProperty("firstname", "")%></option>

        <%
                        }
                    } catch (Exception ex) {

                }

            }%>
        </select>
    </div>
</div>
<br>
<div class="field-box"><div class="field-label-box">Telefonnummer</div><div><input type="text" name="phone" onchange="$('#subunit_form<%=unitId%>').ajaxSubmit()" class="text-field" id="phone-field<%=unitId%>" value="<%=unitNode.getProperty("phone", "")%>"></div></div>
<br>
<div class="field-box"><div class="field-label-box">Faxnummer</div><div><input type="text" name="fax" onchange="$('#subunit_form<%=unitId%>').ajaxSubmit()" class="text-field" id="fax-field<%=unitId%>" value="<%=unitNode.getProperty("fax", "")%>"></div></div>
<br>
<div class="field-box"><div class="field-label-box">E-post</div><div><input type="text" name="email" onchange="$('#subunit_form<%=unitId%>').ajaxSubmit()" class="text-field" id="email-field<%=unitId%>" value="<%=unitNode.getProperty("email", "")%>"></div></div>
<br>
<div class="field-box"><div class="field-label-box">Hemsida</div><div><input type="text" name="web" onchange="$('#subunit_form<%=unitId%>').ajaxSubmit()" class="text-field" id="web-field<%=unitId%>" value="<%=unitNode.getProperty("web", "")%>"></div></div>
<br>
<div class="field-box"><div class="field-label-box">Adress</div><div><input type="text" name="address" onchange="$('#subunit_form<%=unitId%>').ajaxSubmit()" class="text-field" id="streetaddress-field<%=unitId%>" value="<%=unitNode.getProperty("streetaddress", "")%>"></div></div>
<br>
<div class="field-box"><div class="field-label-box">Postnummer</div><div><input type="text" name="postalcode" onchange="$('#subunit_form<%=unitId%>').ajaxSubmit()" class="text-field" id="postalcode-field<%=unitId%>" value="<%=unitNode.getProperty("postalcode", "")%>"></div></div>
<br>
<div class="field-box"><div class="field-label-box">Ort</div><div><input type="text" name="city" onchange="$('#subunit_form<%=unitId%>').ajaxSubmit()" class="text-field" id="city-field<%=unitId%>" value="<%=unitNode.getProperty("city", "")%>"></div></div>
<br>
<div class="field-box"><div class="field-label-box">Land</div><div><input type="text" name="country" onchange="$('#subunit_form<%=unitId%>').ajaxSubmit()" class="text-field" id="country-field<%=unitId%>" value="<%=unitNode.getProperty("country", "")%>"></div></div>
<br>
&nbsp;
</fieldset>
</form>
</div>
<div id="subunit<%=unitId%>-footer" class="list-footer">
    <a href="javascript: addOrganisationSubUnit('name-field<%=unitId%>', <%=unitId%>)">Lägg till underliggande enhet</a>
    &nbsp;
    <a href="javascript: deleteOrganisationSubUnit(<%=unitId%>)">Ta bort enhet</a>
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