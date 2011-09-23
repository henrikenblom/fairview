<%@ page import="com.fairviewiq.utils.PersonListGenerator" %>
<%@ page import="org.neo4j.kernel.impl.batchinsert.SimpleRelationship" %>

<%@page contentType="text/html" pageEncoding="UTF-8" %>

<%@include file="WEB-INF/jspf/beanMapper.jsp" %>

<%

    HashMap<Long, Node> functionMap = new HashMap<Long, Node>();
    ArrayList<Node> unassigned_functions = new ArrayList<Node>();

    for (Relationship entry : organization.getRelationships(SimpleRelationshipType.withName("HAS_FUNCTION"), Direction.OUTGOING)) {

        try {

            Traverser employmentTraverser = entry.getEndNode().traverse(Traverser.Order.BREADTH_FIRST, StopEvaluator.END_OF_GRAPH,
                    ReturnableEvaluator.ALL_BUT_START_NODE, SimpleRelationshipType.withName("PERFORMS_FUNCTION"), Direction.INCOMING);

            if (employmentTraverser.iterator().hasNext()) {
                Traverser employeeTraverser = employmentTraverser.iterator().next().traverse(Traverser.Order.BREADTH_FIRST, StopEvaluator.END_OF_GRAPH, ReturnableEvaluator.ALL_BUT_START_NODE, SimpleRelationshipType.withName("HAS_EMPLOYMENT"), Direction.INCOMING);

                while (employeeTraverser.iterator().hasNext()) {

                    functionMap.put(employeeTraverser.iterator().next().getId(), entry.getEndNode());

                }
            } else {
                unassigned_functions.add(entry.getEndNode());
            }


        } catch (Exception ex) {

            // noop

        }

    }

%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
"http://www.w3.org/TR/html4/loose.dtd">

<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>Infero Quest - Personer</title>
    <link rel="stylesheet" href="css/newlook.css" type="text/css" media="screen" charset="utf-8"/>
    <link type="text/css" href="css/flick/jquery-ui-1.8.13.custom.css" rel="stylesheet"/>
    <script type="text/javascript" src="js/jquery-1.4.4.min.js"></script>
    <script type="text/javascript" src="js/jquery-ui-1.8.13.custom.min.js"></script>
    <script type="text/javascript" src="iq.js"></script>
    <script type="text/javascript" src="popupControls.js"></script>
    <script type="text/javascript" src="formgenerator.js"></script>
    <script type="text/javascript" src="js/jquery-plugins/jquery.form.js"></script>
    <script type="text/javascript">
        var reloadPage = 'false';

        function addCoworker(event) {

            $.getJSON("neo/ajax/create_relationship.do", {_startNodeId:<%= neo.getReferenceNode().getId() %>, _type:"HAS_USER" }, function(dataUser) {
                $.getJSON("neo/ajax/create_relationship.do", {_startNodeId:<%= organization.getId()%>, _endNodeId:dataUser.relationship.endNode, _type:"HAS_EMPLOYEE" }, function(dataEmployee) {


                    changeView('coworkerprofile.jsp?id=' + dataEmployee.relationship.endNode);
                    //$.getJSON("neo/ajax/update_node.do", {_nodeId:dataEmployee.relationship.endNode, nodeClass:"employee", _preserve:"password" }, function(data) {

                    //$('#newUserId').val(data.node.id);
                    //$('#newUserDialog').show();
                    //$('#username-field').focus();


                    //});
                });
            });
        }

        function abortNewUser(event) {

            $('#newUserDialog').hide();
            $.getJSON("neo/ajax/delete_node.do", {_nodeId:$('#newUserId').val()});

        }

        function validateNewUserForm() {

            if ($('#username-field').val().length > 0
                    && $('#password_confirm_1-field').val().length > 0
                    && $('#password_confirm_2-field').val().length > 0
                    && $('#password_confirm_1-field').val() == $('#password_confirm_2-field').val()) {

                $('#credentials-footer').html('<a href="#" onclick="$(\'#credentials_form\').ajaxSubmit(function() { document.location = \'coworkerprofile.jsp?id=\' + $(\'#newUserId\').val(); })">Spara</a>');

            } else {

                $('#credentials-footer').html("&nbsp;");

            }

        }

        function alternateRowColors() {
            var rows = [];
            $(".unit-list-entry").each(function() {
                rows.push(this);
            });
            $.each(rows, function(i, obj) {
                if (i % 2 == 0)
                    $(obj).addClass('list-entry-alternating');
            });
        }
        function duplicateFunction(nodeId) {
            $.getJSON("fairview/ajax/duplicate_function.do", {_nodeId:nodeId}, function(data) {
                location.reload();
            });
        }

        function generateProfileForm(unitId) {
            var data = getNodeData(unitId);
            $('#profile-employmentinfo').empty().append(generateProfileGeneralForm(data));
        }

        $(document).ready(function() {

            adjustViewPort();
            fadeOutModalizer();

            alternateRowColors();
            bindTabs();

            $('.profilelink-manager').click(function() {
                openPopupTab(0);
            });

        });

    </script>
</head>
<body onload="onload(<%= organization.getId()%>)" onresize="adjustViewPort()">
<%@include file="WEB-INF/jspf/iqpageheader.jsp" %>
<div id="main">
<div id="content">
<div class="header"><input type="text" class="text-field filter-field" onkeyup="coworkerTextFilter(event)"
                           placeholder="Person/Funktion/Enhet/Telefon/E-post" id="coworker-text-filter"></div>
<div class="coworker-list-attribute-header">
    <div class="coworker-list-attribute-header-entry unit-list-cell list-entry">Funktion</div>
    <div class="coworker-list-attribute-header-entry unit-list-cell list-entry">Beskrivning</div>
    <div class="unit-list-image unit-list-cell"></div>
    <div class="coworker-list-attribute-header-entry unit-list-cell list-entry">Enhet</div>
    <div class="coworker-list-attribute-header-entry unit-list-cell list-entry">Person</div>
</div>
<div class="helpbox" id="helpbox-unitlist-addunit">
    <div class="helpbox-header">Lägg till</div>
    <div class="helpbox-content">
        <img src="images/newperson.png" class="helpbox-image">
        <a href="#" onclick="addCoworker(event)">Lägg till person</a>
    </div>
</div>
<div class="helpbox" id="helpbox-unitlist-help">
    <div class="helpbox-header">Hjälpruta</div>
    <div class="helpbox-content">Här kan du få hjälp med allt mellan himmel och jord.</div>
</div>
<div id="coworker-list" class="list-body">
    <%
        int count = 0;
        for (Node entry : personListGenerator.getSortedList(PersonListGenerator.ALPHABETICAL, false)) {

            StringBuilder unitList = new StringBuilder();

            boolean currentUserManages = false;
            boolean firstInList = true;

            for (Relationship unitRelationship : entry.getRelationships(SimpleRelationshipType.withName("BELONGS_TO"), Direction.OUTGOING)) {

                if (!firstInList) {

                    unitList.append(", ");

                }

                firstInList = false;

                Relationship managerRelationShip = null;

                try {

                    managerRelationShip = unitRelationship.getEndNode().getRelationships(SimpleRelationshipType.withName("HAS_MANAGER"), Direction.OUTGOING).iterator().next();

                } catch (NoSuchElementException ex) {

                }

                if (managerRelationShip != null
                        && managerRelationShip.getEndNode().getId() == currentUserNode.getId()) {

                    currentUserManages = true;

                }

    %>

    <sec:authorize ifAnyGranted="ROLE_MANAGER">

        <%
            unitList.append("<a href=\"organisationdetails.jsp?unitId=");
            unitList.append(unitRelationship.getEndNode().getId());
            unitList.append("\">");
        %>
    </sec:authorize>
    <%
        unitList.append(unitRelationship.getEndNode().getProperty("name", "Namnlös enhet"));
    %>
    <sec:authorize ifAnyGranted="ROLE_MANAGER">
        <%
            unitList.append("</a>");
        %>
    </sec:authorize>
    <%
        }

        if (firstInList) {

            unitList.append("-");

        }

        try {


    %>

    <div class="list-entry coworker-list-entry unit-list-entry">
        <div class="unit-list-cell"><%=(functionMap.get(entry.getId()) == null) ? "-" : "<a href=\"functiondetails.jsp?id=" + functionMap.get(entry.getId()).getId() + "\">" + functionMap.get(entry.getId()).getProperty("name", "Namnlös funktion") + "</a>"%>
        </div>
        <div class="unit-list-cell"><%=(functionMap.get(entry.getId()) == null) ? "-" : functionMap.get(entry.getId()).getProperty("description", "")%>
        </div>
        <div class="unit-list-image unit-list-cell">
            <%if (!(functionMap.get(entry.getId()) == null)) {%>
            <img src="images/copyfunction.png" onclick="duplicateFunction(<%=functionMap.get(entry.getId()).getId()%>)">
            <%}%>
        </div>
        <div class="unit-list-cell"><%=unitList.toString()%>
        </div>
        <div class="unit-list-cell list-entry">
            <sec:authorize ifAnyGranted="ROLE_MANAGER">
                <div class="link profilelink-manager" onclick="generateProfileForm(<%=entry.getId()%>);">
                    <%= entry.getProperty("lastname", "")%>, <%= entry.getProperty("firstname", "")%>
                </div>
            </sec:authorize>
            <sec:authorize ifNotGranted="ROLE_MANAGER">
                <% if (currentUserManages) { %>
                <div class="link profilelink-manager"
                     onclick="generateProfileForm(<%=entry.getId()%>);"><%= entry.getProperty("lastname", "")%>
                    , <%= entry.getProperty("firstname", "")%>
                </div>
                <% } else { %>
                <div><%= entry.getProperty("lastname", "")%>, <%= entry.getProperty("firstname", "")%>
                </div>
                <% } %>
            </sec:authorize>
        </div>
        <div class="unit-list-cell"><%= entry.getProperty("phone", "-")%>
        </div>
        <div class="unit-list-cell"><a
                href="mailto:<%= entry.getProperty("email", "")%>"><%= entry.getProperty("email", "-")%>
        </a></div>
    </div>

    <%
            } catch (Exception ex) {

            }
        }
        for (Node unassfunction : unassigned_functions) {
    %>
    <div class="list-entry coworker-list-entry unit-list-entry">
        <div class="unit-list-cell list-entry">
            <a href="functiondetails.jsp?id=<%=unassfunction.getId()%>"><%=unassfunction.getProperty("name", "Namnlös funktion")%>
            </a>
        </div>
        <div class="unit-list-cell list-entry"><%=unassfunction.getProperty("description", "")%>
        </div>
        <div class="unit-list-image unit-list-cell"><img src="images/copyfunction.png"
                                                         onclick="duplicateFunction(<%=unassfunction.getId()%>)"></div>
        <div class="unit-list-cell list-entry">-</div>
        <div class="unit-list-cell list-entry">Vakant</div>
        <div class="unit-list-cell list-entry">-</div>
        <div class="unit-list-cell list-entry">-</div>
    </div>
    <%
        }
    %>
</div>

<div id="newUserDialog" class="popup" style="display: none">
    <div class="popup-header">
        <div class="popup-header-text">Ny person</div>
        <div class="popup-header-close-box"><a href="#" onclick="abortNewUser(event)" class="close"><img
                src="images/close.gif"></a></div>
    </div>
    <div class="list-body profile-list" id="credentials-list">
        <form id="credentials_form" action="neo/ajax/update_credentials.do" method="post">
            <input name="_id" type="hidden" id="newUserId"/>
            <fieldset>
                <div class="field-box">
                    <div class="field-label-box">Användarnamn</div>
                    <div id="username-field-box" class="field-input-box"><input type="text" value=""
                                                                                autocomplete="off"
                                                                                onkeyup="validateNewUserForm()"
                                                                                name="username"
                                                                                class="text-field"
                                                                                id="username-field"></div>
                </div>
                <br>

                <div class="field-box">
                    <div class="field-label-box">Lösenord</div>
                    <div id="password_confirm_1-field-box" class="field-input-box"><input type="password"
                                                                                          value=""
                                                                                          autocomplete="off"
                                                                                          onkeyup="validateNewUserForm()"
                                                                                          name="password_confirm_1"
                                                                                          class="text-field"
                                                                                          id="password_confirm_1-field">
                    </div>
                </div>
                <br>

                <div class="field-box">
                    <div class="field-label-box">Lösenord (bekräfta)</div>
                    <div id="password_confirm_2-field-box" class="field-input-box"><input type="password"
                                                                                          value=""
                                                                                          autocomplete="off"
                                                                                          onkeyup="validateNewUserForm()"
                                                                                          name="password_confirm_2"
                                                                                          class="text-field"
                                                                                          id="password_confirm_2-field">
                    </div>
                </div>
                <br>

                <div class="field-box">
                    <div class="field-label-box">Funktion</div>
                    <input type="checkbox" onchange="validateNewUserForm()" name="role:checkbox"
                           value="ROLE_MANAGER"/> A
                    <input type="checkbox" onchange="validateNewUserForm()" name="role:checkbox"
                           value="ROLE_HR"/> B
                    <input type="checkbox" onchange="validateNewUserForm()" name="role:checkbox"
                           value="ROLE_EMPLOYEE" checked="true"/> C
                </div>
            </fieldset>
        </form>
    </div>
    <div id="credentials-footer" class="list-footer">&nbsp;</div>
</div>
</div>
</div>
<div id="modalizer">&nbsp;</div>
<div id="popup-dialog" style="display: none;">
    <div id="popup-tabs">
        <ul>
            <li><a href="#profile-employmentinfo">Anställningsuppgifter</a></li>
            <li><a href="#profile-responsibility">Arbetsbeskrivning</a></li>
            <li><a href="#profile-competence">Kompetens</a></li>
            <li><a href="#profile-experience">Erfarenhet</a></li>
        </ul>
        <div id="popup-header"></div>
        <div class="unitsettings" id="profile-employmentinfo">Anställningsuppgifter</div>
        <div class="unitsettings" id="profile-responsibility">Ännu ej implementerat.</div>
        <div class="unitsettings" id="profile-competence">Ännu ej implementerat.</div>
        <div class="unitsettings" id="profile-experience">Ännu ej implementerat.</div>
    </div>
</div>
</body>
</html>
