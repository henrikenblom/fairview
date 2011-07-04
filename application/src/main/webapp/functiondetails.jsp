<%@ page import="org.neo4j.graphdb.*" %>
<%@ page import="org.neo4j.graphdb.Traverser" %>
<%@ page import="se.codemate.neo4j.NeoUtils" %>
<%--
    Document   : functiondetails
    Created on : 2010-nov-16, 10:42:34
    Author     : henrik
--%>

<%@page contentType="text/html" pageEncoding="UTF-8" %>

<%@include file="WEB-INF/jspf/beanMapper.jsp" %>
<%
    Node function = null;
    Node assignedEmployee = null;
    Long assignedEmployeeRelationshipId = null;
    Long assignedEmploymentRelationshipId = null;

    if (request.getParameter("id") != null && Long.decode((String) request.getParameter("id")) > 0) {

        function = neo.getNodeById(Long.decode((String) request.getParameter("id")));

        try {

            Traverser employmentTraverser = function.traverse(Traverser.Order.BREADTH_FIRST, StopEvaluator.END_OF_GRAPH, ReturnableEvaluator.ALL_BUT_START_NODE, SimpleRelationshipType.withName("PERFORMS_FUNCTION"), Direction.INCOMING);

            Node assignedEmploymentNode = employmentTraverser.iterator().next();

            assignedEmploymentRelationshipId = ((Iterable<Relationship>) assignedEmploymentNode.getRelationships(SimpleRelationshipType.withName("PERFORMS_FUNCTION"), Direction.OUTGOING)).iterator().next().getId();

            Traverser employeeTraverser = assignedEmploymentNode.traverse(Traverser.Order.BREADTH_FIRST, StopEvaluator.END_OF_GRAPH, ReturnableEvaluator.ALL_BUT_START_NODE, SimpleRelationshipType.withName("HAS_EMPLOYMENT"), Direction.INCOMING);

            assignedEmployee = employeeTraverser.iterator().next();

            assignedEmployeeRelationshipId = ((Iterable<Relationship>) assignedEmployee.getRelationships(SimpleRelationshipType.withName("HAS_EMPLOYMENT"), Direction.OUTGOING)).iterator().next().getId();

        } catch (Exception ex) {

        }

    } else {

        Transaction tx = neo.beginTx();

        try {

            function = neo.createNode();
            function.setProperty("nodeClass", "function");

            organization.createRelationshipTo(function, SimpleRelationshipType.withName("HAS_FUNCTION"));

            tx.success();

        } catch (Exception e) {

        } finally {

            tx.finish();
            tx = null;
        }

    }

    HashMap<Long, Long> belongsToUnits = new HashMap<Long, Long>();

    for (Relationship entry : function.getRelationships(SimpleRelationshipType.withName("BELONGS_TO"), Direction.OUTGOING)) {

        belongsToUnits.put(entry.getEndNode().getId(), entry.getId());

    }

%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
"http://www.w3.org/TR/html4/loose.dtd">

<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>Infero Quest - Funktion</title>
    <link rel="stylesheet" href="css/newlook.css" type="text/css" media="screen" charset="utf-8"/>
    <script type="text/javascript" src="js/jquery-1.4.4.min.js"></script>
    <script type="text/javascript" src="js/jquery-plugins/jquery.form.js"></script>
    <script type="text/javascript" src="iq.js"></script>
    <script type="text/javascript">

        var assignedEmployeeRelationshipId;
        var assignedEmploymentRelationshipId;
        var belongsToUnits = {};

        <%

    for (Long key : belongsToUnits.keySet()) {

        %>

        belongsToUnits[<%=key%>] = <%=belongsToUnits.get(key)%>;

        <%

            }

        %>

        <%if (assignedEmployeeRelationshipId != null) { %>

        assignedEmployeeRelationshipId = <%=assignedEmployeeRelationshipId%>;
        assignedEmploymentRelationshipId = <%= assignedEmploymentRelationshipId%>;

        <% }%>

        function showDeleteFunctionConfirmationDialog() {

            $('#deleteFunctionConfirmationDialog').center();

            setTimeout(function() {
                $('#deleteFunctionConfirmationDialog').fadeIn(200)
            }, 100);
            $('#modalizer').fadeTo(400, 0.8);

        }

        function hideDeleteFunctionConfirmationDialog() {

            setTimeout(function() {
                $('#modalizer').fadeOut(400);
            }, 100);
            $('#deleteFunctionConfirmationDialog').fadeOut(100);

        }

        function duplicateFunction() {

            $.getJSON("fairview/ajax/duplicate_function.do", {_nodeId:<%=function.getId()%>}, function(data) {
                changeView('functiondetails.jsp?id=' + data['org.neo4j.kernel.impl.core.NodeProxy'].id);
            });

        }

        function deleteFunction(node, parentNode) {

            if (assignedEmployeeRelationshipId) {

                $.getJSON("neo/ajax/delete_relationship.do", {_relationshipId:assignedEmploymentRelationshipId}, function() {
                    $.ajax({url: "neo/ajax/delete_relationship.do", dataType: 'json', data: {_relationshipId:assignedEmployeeRelationshipId}, async: false});
                });

            }

            $.getJSON("neo/ajax/delete_node.do", {_nodeId:node}, function() {
                changeView('functions.jsp');
            });

        }

        function assignToUnit() {

            $('#unit > option').each(function() {

                var unitId = $(this).val();

                if (!this.selected && belongsToUnits[unitId] > 0) {

                    $.getJSON("neo/ajax/delete_relationship.do", {_relationshipId:belongsToUnits[unitId]});

                } else if (this.selected && !belongsToUnits[unitId] > 0) {

                    $.getJSON("neo/ajax/create_relationship.do", {_startNodeId:<%=function.getId()%>, _type:"BELONGS_TO", _endNodeId:unitId }, function(data) {

                        belongsToUnits[unitId] = data.relationship.id;

                    });

                }

            });

        }

        $(document).ready(function() {

            adjustViewPort();
            $('#name-field').focus();
            $('#modalizer').fadeOut(500);

        });

        function addResponsibility() {

            $.getJSON("neo/ajax/create_relationship.do", {_startNodeId:<%= function.getId()%>, _type:"HAS_RESPONSIBILITY" }, function(data) {

                $('<div class="responsibility-list-entry">\
                                    <div class="responsibility">\
                                        <form id="responsibilityForm' + data.relationship.endNode + '" action="neo/ajax/update_properties.do" method="post">\
                                            <fieldset>\
                                                <input type="hidden" name="_id" value="' + data.relationship.endNode + '">\
                                                <input type="hidden" name="_type" value="node">\
                                                <input type="hidden" name="_strict" value="true">\
                                                <input type="hidden" name="_username" value="admin">\
                                                <input id="name-input-field' + data.relationship.endNode + '" name="name" class="text-field" onchange="$(\'#responsibilityForm' + data.relationship.endNode + '\').ajaxSubmit()"> <input name="percentage" onchange="$(\'#responsibilityForm' + data.relationship.endNode + '\').ajaxSubmit()" class="text-field digits-3"> %\
                                            </fieldset>\
                                        </form>\
                                    </div>\
                                </div>').appendTo($('#responsibilities'));

                $('#name-input-field' + data.relationship.endNode + '').focus();

            });

        }

        function employeeAssignedToFunction(event, functionId) {

            var employeeId = $('#employee-selection').val();

            if (assignedEmployeeRelationshipId) {

                $.getJSON("neo/ajax/delete_relationship.do", {_relationshipId:assignedEmploymentRelationshipId}, function() {
                    $.ajax({url: "neo/ajax/delete_relationship.do", dataType: 'json', data: {_relationshipId:assignedEmployeeRelationshipId}, async: false});
                });

            }

            if (employeeId > 0) {

                $.getJSON("neo/ajax/create_relationship.do", {_startNodeId:employeeId, _type:"HAS_EMPLOYMENT" }, function(dataEmployment) {
                    $.getJSON("fairview/ajax/assign_function.do", {employment:dataEmployment.relationship.endNode, "function:relationship":functionId, percent:100}, function(data) {
                        assignedEmploymentRelationshipId = data['org.neo4j.kernel.impl.core.RelationshipProxy'].id;
                    });
                    assignedEmployeeRelationshipId = dataEmployment.relationship.id;
                });

            }

        }

    </script>
</head>
<body onload="onload(<%= organization.getId()%>)" onresize="adjustViewPort()">
<%@include file="WEB-INF/jspf/iqpageheader.jsp" %>
<div id="main">
<div id="content">
<div class="header text-header">Funktion
    <div class="expand-contract"><img onclick="toggleExpand(event)" id="responsibility-expand"
                                      src="images/contract.png"></div>
</div>
<div class="list-body profile-list" id="responsibility-list">
    <form id="functionForm" action="neo/ajax/update_properties.do" method="post">
        <fieldset>
            <input type="hidden" name="_id" value="<%= function.getId()%>">
            <input type="hidden" name="_type" value="node">
            <input type="hidden" name="_strict" value="true">
            <input type="hidden" name="_username" value="admin">

            <div class="field-box">
                <div class="field-label-box">Titel</div>
                <div><input type="text" onchange="$('#functionForm').ajaxSubmit()"
                            value="<%= function.getProperty("name", "") %>" class="text-field" id="name-field"
                            name="name"></div>
            </div>
            <br>
            <br>

            <div class="field-box">
                <div class="field-label-box">Medarbetare</div>
                <div class="field-preview">
                    <select id="employee-selection" name="employee"
                            onchange="employeeAssignedToFunction(event, <%= function.getId()%>)">
                        <option><%=(assignedEmployee == null) ? "Välj..." : "- Vakant -"%>
                        </option>
                        <%
                            for (Node entry : personListGenerator.getSortedList(PersonListGenerator.ALPHABETICAL, false)) {

                                try {
                                    if (!entry.getProperty("firstname", "").equals("") && !entry.getProperty("lastname", "").equals("")) {

                        %>
                        <option value="<%= entry.getId()%>"<% if (assignedEmployee != null && assignedEmployee.getId() == entry.getId()) {%>
                                selected="true"<% } %>><%= entry.getProperty("lastname", "")%>
                            , <%= entry.getProperty("firstname", "")%>
                        </option>

                        <%
                                    }
                                } catch (Exception ex) {

                                }

                            }%>
                    </select>
                </div>
            </div>
            <br>
            <br>

            <div class="field-box">
                <div class="field-label-box">Enhet</div>
                <div class="field-input-box">
                    <div id="unit-field-box" class="field-input-box">
                        <select multiple="true" id="unit" onchange="assignToUnit()">
                            <option value="<%=organization.getId()%>" <%=(belongsToUnits.containsKey(organization.getId())) ? "selected=\"true\"" : ""%>>
                                Huvudorganisation (<%=organization.getProperty("name", "Namnlös")%>)
                            </option>
                            <% for (Relationship entry : organization.getRelationships(SimpleRelationshipType.withName("HAS_UNIT"))) { %>

                            <option value="<%=entry.getEndNode().getId()%>" <%=(belongsToUnits.containsKey(entry.getEndNode().getId())) ? "selected=\"true\"" : ""%>><%=entry.getEndNode().getProperty("name", "")%>
                            </option>

                            <% for (Relationship subEntry : entry.getEndNode().getRelationships(SimpleRelationshipType.withName("HAS_UNIT"))) {

                                if (subEntry.getEndNode().getId() != entry.getEndNode().getId()) {%>

                            <option value="<%=subEntry.getEndNode().getId()%>" <%=(belongsToUnits.containsKey(subEntry.getEndNode().getId())) ? "selected=\"true\"" : ""%>><%=subEntry.getEndNode().getProperty("name", "")%>
                            </option>

                            <% }

                            }

                            } %>
                        </select>
                    </div>
                </div>
            </div>
            <br>
            <br>

            <div class="field-box">
                <div class="field-label-box">Sammanfattning</div>
                <div><textarea onchange="$('#functionForm').ajaxSubmit()" id="description-field"
                               name="description"><%= function.getProperty("description", "") %>
                </textarea></div>
            </div>
            <br>
            <br>
            <br>
        </fieldset>
    </form>

    <%



    %>

 <!--   <div class="field-box">
        <div id="responsibility-share-list">
            <div class="responsibility-list-entry">
                <div class="responsibility responsibility-list-header">Prioriterade ansvarsområden</div>
            </div>
            <div id="responsibilities">
                <%

                    NeoUtils neoUtils = new NeoUtils(neo);

                    int rest = 100;
                    int responsibilityCount = 0;
                    for (Relationship entry : function.getRelationships(SimpleRelationshipType.withName("HAS_RESPONSIBILITY"), Direction.OUTGOING)) {

                        if (entry.getEndNode().getProperty("name", "").equals("")) {

                            Transaction tx = neo.beginTx();

                            try {

                                neoUtils.deleteNode(entry.getEndNode());

                                tx.success();

                            } catch (Exception ex) {

                            } finally {

                                tx.finish();
                                tx = null;

                            }

                        } else {

                            responsibilityCount++;

                            rest -= Integer.parseInt((String) entry.getEndNode().getProperty("percentage", "0"));

                %>
                <div class="responsibility-list-entry">
                    <div class="responsibility">
                        <form id="responsibilityForm<%= entry.getEndNode().getId()%>"
                              action="neo/ajax/update_properties.do" method="post">
                            <fieldset>
                                <input type="hidden" name="_id" value="<%= entry.getEndNode().getId()%>">
                                <input type="hidden" name="_type" value="node">
                                <input type="hidden" name="_strict" value="true">
                                <input type="hidden" name="_username" value="admin">
                                <input name="name" id="name-input-field<%= entry.getEndNode().getId()%>"
                                       class="text-field"
                                       onchange="$('#responsibilityForm<%= entry.getEndNode().getId()%>').ajaxSubmit()"
                                       value="<%=entry.getEndNode().getProperty("name", "")%>"> <input name="percentage"
                                                                                                       onchange="$('#responsibilityForm<%= entry.getEndNode().getId()%>').ajaxSubmit()"
                                                                                                       class="text-field digits-3"
                                                                                                       value="<%=entry.getEndNode().getProperty("percentage", "0")%>">
                                %
                            </fieldset>
                        </form>
                    </div>
                </div>

                <%

                        }
                    }


                    if (responsibilityCount < 10) {

                        Transaction tx = neo.beginTx();
                        Node responsibility = null;

                        try {

                            responsibility = neo.createNode();
                            responsibility.setProperty("nodeClass", "responsibility");

                            function.createRelationshipTo(responsibility, SimpleRelationshipType.withName("HAS_RESPONSIBILITY"));

                            tx.success();


                %>
            </div>
            <a href="#" onclick="addResponsibility()"><img src="images/plus.png"></a>

            <div class="responsibility-list-entry">
                <div class="responsibility">
                    <form id="responsibilityForm<%= responsibility.getId()%>" action="neo/ajax/update_properties.do"
                          method="post">
                        <fieldset>
                            <input type="hidden" name="_id" value="<%= responsibility.getId()%>">
                            <input type="hidden" name="_type" value="node">
                            <input type="hidden" name="_strict" value="true">
                            <input type="hidden" name="_username" value="admin">
                            <input name="name" id="name-input-field<%= responsibility.getId()%>" class="text-field"
                                   onchange="$('#responsibilityForm<%= responsibility.getId()%>').ajaxSubmit()"
                                   value="<%= (responsibilityCount > 0) ? "Övrigt" : ""%>"> <input name="percentage"
                                                                                                   class="text-field digits-3"
                                                                                                   value="<%=rest%>"> %
                        </fieldset>
                    </form>
                </div>
            </div>
            <%

                    } catch (Exception e) {

                    } finally {

                        tx.finish();
                        tx = null;
                        responsibility = null;

                    }

                }

            %>

        </div>
    </div>  -->
    <br>
    <br>

</div>
<div id="responsibility-footer" class="list-footer">
    <a href="javascript: showDeleteFunctionConfirmationDialog()">Ta bort funktion</a>
    <a href="javascript: duplicateFunction()">Kopiera funktion</a>
</div>

<div class="header text-header">
    Profil
    <div class="expand-contract"><img onclick="toggleExpand(event)" id="competence-expand" src="images/contract.png">
    </div>
</div>
<div class="list-body profile-list" id="competence-list">
    <form id="driversLicenseForm" action="neo/ajax/update_properties.do" method="post">
        <fieldset>
            <input type="hidden" name="_id" value="<%=function.getId()%>">
            <input type="hidden" name="_type" value="node">
            <input type="hidden" name="_strict" value="false">
            <input type="hidden" name="_username" value="admin">
            <input type="hidden" id="dl_a1-field" name="dl_a1" value="<%=function.getProperty("dl_a1", "false")%>">
            <input type="hidden" id="dl_a-field" name="dl_a" value="<%=function.getProperty("dl_a", "false")%>">
            <input type="hidden" id="dl_b-field" name="dl_b" value="<%=function.getProperty("dl_b", "false")%>">
            <input type="hidden" id="dl_c-field" name="dl_c" value="<%=function.getProperty("dl_c", "false")%>">
            <input type="hidden" id="dl_d-field" name="dl_d" value="<%=function.getProperty("dl_d", "false")%>">
            <input type="hidden" id="dl_be-field" name="dl_be" value="<%=function.getProperty("dl_be", "false")%>">
            <input type="hidden" id="dl_ce-field" name="dl_ce" value="<%=function.getProperty("dl_ce", "false")%>">
            <input type="hidden" id="dl_de-field" name="dl_de" value="<%=function.getProperty("dl_de", "false")%>">
            <br>

            <div class="field-box">
                <div class="field-label-box">Körkortsbehörighet</div>
                <div class="field-input-box"><input
                        type="checkbox" <%=(function.getProperty("dl_a1", "").equals("true")) ? "checked=\"true\"" : ""%>
                        id="pseudo-dl_a1" onchange="translatePseudoCheckbox(event, 'driversLicenseForm')"> A1
                </div>
                <div class="field-input-box"><input
                        type="checkbox" <%=(function.getProperty("dl_a", "").equals("true")) ? "checked=\"true\"" : ""%>
                        id="pseudo-dl_a" onchange="translatePseudoCheckbox(event,'driversLicenseForm')"> A
                </div>
                <div class="field-input-box"><input
                        type="checkbox" <%=(function.getProperty("dl_b", "").equals("true")) ? "checked=\"true\"" : ""%>
                        id="pseudo-dl_b" onchange="translatePseudoCheckbox(event, 'driversLicenseForm')"> B
                </div>
                <div class="field-input-box"><input
                        type="checkbox" <%=(function.getProperty("dl_c", "").equals("true")) ? "checked=\"true\"" : ""%>
                        id="pseudo-dl_c" onchange="translatePseudoCheckbox(event, 'driversLicenseForm')"> C
                </div>
                <div class="field-input-box"><input
                        type="checkbox" <%=(function.getProperty("dl_d", "").equals("true")) ? "checked=\"true\"" : ""%>
                        id="pseudo-dl_d" onchange="translatePseudoCheckbox(event, 'driversLicenseForm')"> D
                </div>
                <div class="field-input-box"><input
                        type="checkbox" <%=(function.getProperty("dl_be", "").equals("true")) ? "checked=\"true\"" : ""%>
                        id="pseudo-dl_be" onchange="translatePseudoCheckbox(event, 'driversLicenseForm')"> BE
                </div>
                <div class="field-input-box"><input
                        type="checkbox" <%=(function.getProperty("dl_ce", "").equals("true")) ? "checked=\"true\"" : ""%>
                        id="pseudo-dl_ce" onchange="translatePseudoCheckbox(event, 'driversLicenseForm')"> CE
                </div>
                <div class="field-input-box"><input
                        type="checkbox" <%=(function.getProperty("dl_de", "").equals("true")) ? "checked=\"true\"" : ""%>
                        id="pseudo-dl_de" onchange="translatePseudoCheckbox(event, 'driversLicenseForm')"> DE
                </div>
            </div>
            <br>
            <div class="field-box">
                <div class="field-label-box">Språkkunskap</div>
                <div><input type="text" value="<%= function.getProperty("languages", "") %>" class="text-field" id="languages-field" name="languages"></div>
            </div>
            <br>
            <div class="field-box">
                <div class="field-label-box">Bostadsort</div>
                <div><input type="text" value="<%= function.getProperty("residential_area", "") %>" class="text-field" id="residential_area-field" name="residential_area"></div>
            </div>
            <br>
            <div class="field-box"><div class="field-label-box">Kön</div><div id="gender-field-box" class="field-input-box">
                <select name="gender">
                <% if (function.getProperty("gender", "").equals("")) {%><option>Välj...</option> <% } %>
                    <option value="M" <% if (function.getProperty("gender", "").equals("M")) { %>selected="true"<% } %>>Man</option>
                    <option value="F" <% if (function.getProperty("gender", "").equals("F")) { %>selected="true"<% } %>>Kvinna</option>
                </select>
            </div>
            </div>
            <br>
            <div class="field-box">
                <div class="field-label-box">Ålder</div>
                <div><input type="text" value="<%= function.getProperty("age", "") %>" class="text-field" id="age-field" name="age"></div>
            </div>
            <br>
            <div>
                            <form id="educationForm" action="neo/ajax/update_properties.do" method="post">
                                <fieldset>
                                    <input type="hidden" name="_id" value="">
                                    <input type="hidden" name="_type" value="node">
                                    <input type="hidden" name="_strict" value="false">
                                    <input type="hidden" name="_username" value="admin">
                                    <div class="field-label-box">Utbildning</div>
                                    <div class="field-input-box"><input type="text" name="name" id="education-field"></div>
                                    <div class="field-label-box">Utbildningsnivå</div>
                                    <select name="level">
                                        <option>Gymnasieskola eller motsvarande</option>
                                        <option>Certifierad</option>
                                        <option>Yrkesutbildad</option>
                                        <option>Enstaka kurser</option>
                                        <option>Övriga eftergymnasiala kurser</option>
                                        <option>Kandidatexamen</option>
                                        <option>Magister eller civilingenjörexamen</option>
                                        <option>Licentiat eller doktorsexamen</option>
                                        <option>Yrkeslicens</option>
                                    </select>
                                    <div class="field-label-box">Inriktning</div>
                                    <div class="field-input-box"><input type="text" name="direction" id="education-direction-field"></div>
                                    <div class="field-label-box">Omfattning</div>
                                    <div class="field-input-box"><input type="text" name="scope" id="education-scope-field"></div>
                                    <div class="field-label-box">Från och med</div>
                                    <div class="field-input-box"><input type="text" name="from" id="education-from-field"></div>
                                    <div class="field-label-box">Till och med</div>
                                    <div class="field-input-box"><input type="text" name="to" id="education-to-field"></div>
                                    <div class="field-label-box">Land</div>
                                    <div class="field-input-box"><input type="text" onchange="$('#educationForm').ajaxSubmit()" name="country" id="education-country-field"></div>
                                    <div class="field-label-box">Beskrivning</div>
                                    <div class="field-input-box"><input type="text" onchange="$('#educationForm').ajaxSubmit()" name="description" id="education-description-field"></div>
                                    <br>
                                </fieldset>
                            </form>
                        </div>
                        <br>
                        <div>
                            <form id="workexperienceForm" action="neo/ajax/update_properties.do" method="post">
                                <fieldset>
                                    <input type="hidden" name="_id" value="">
                                    <input type="hidden" name="_type" value="node">
                                    <input type="hidden" name="_strict" value="false">
                                    <input type="hidden" name="_username" value="admin">
                                    <div class="field-label-box">Tidigare befattning</div>
                                    <div class="field-input-box"><input type="text" name="name"></div>
                                    <div class="field-label-box">Företag</div>
                                    <div class="field-input-box"><input type="text" name="company"></div>
                                    <div class="field-label-box">Bransch</div>
                                    <div class="field-input-box"><input type="text" name="trade" id="trade-field"></div>
                                    <div class="field-label-box">Land</div>
                                    <div class="field-input-box"><input type="text" name="country" id="country-field"></div>
                                    <div class="field-label-box">Från och med</div>
                                    <div class="field-input-box"><input type="text" name="from" id="from-field"></div>
                                    <div class="field-label-box">Till och med</div>
                                    <div class="field-input-box"><input type="text" name="to" id="to-field"></div>
                                    <div class="field-label-box">Uppgifter</div>
                                    <div class="field-input-box"><input type="text" name="task" id="task-field"></div>
                                    <br>
                                </fieldset>
                            </form>
                        </div>
                        <br>
            <br>
        </fieldset>
    </form>
</div>
<div id="competence-footer" class="list-footer">
    &nbsp;
</div>

</div>
</div>
<div id="modalizer">&nbsp;</div>
<%@include file="WEB-INF/jspf/goaldialog.jsp" %>
<div id="deleteFunctionConfirmationDialog" class="popup" style="display: none">
    <div class="popup-header">
        <div class="popup-header-text">Ta bort funktion?</div>
        <div class="popup-header-close-box"><a href="javascript: hideDeleteFunctionConfirmationDialog()"
                                               class="close"><img src="images/close.gif"></a></div>
    </div>
    <div class="list-body profile-list" id="credentials-list">

        <h3>Vill du verkligen ta bort funktionen?</h3>
        <br>
        <button class="dialog-button" onclick="deleteFunction(<%=function.getId()%>, <%=organization.getId()%>)">Ja
        </button>
        <button class="dialog-button" onclick="hideDeleteFunctionConfirmationDialog()">Nej</button>
    </div>
    <div id="credentials-footer" class="list-footer">&nbsp;</div>
</div>
</body>
</html>
