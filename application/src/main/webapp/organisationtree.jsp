<%--
  Created by IntelliJ IDEA.
  User: henrik
  Date: 2011-06-10
  Time: 10.34
  To change this template use File | Settings | File Templates.
--%>
<%@page contentType="text/html" pageEncoding="UTF-8" %>

<%@include file="WEB-INF/jspf/beanMapper.jsp" %>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
"http://www.w3.org/TR/html4/loose.dtd">
<%
    Node mainAddressNode = null;

    try {

        mainAddressNode = ((Iterable<Relationship>) organization.getRelationships(SimpleRelationshipType.withName("HAS_ADDRESS"))).iterator().next().getEndNode();

    } catch (Exception ex) {

        Transaction tx = neo.beginTx();

        try {

            mainAddressNode = neo.createNode();

            mainAddressNode.setProperty("mainAddress", "true");

            organization.createRelationshipTo(mainAddressNode, SimpleRelationshipType.withName("HAS_ADDRESS"));

            tx.success();

        } catch (Exception e) {

        } finally {

            tx.finish();

        }

    }

%>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>Infero Quest - Enheter</title>
    <link rel="stylesheet" href="css/newlook.css" type="text/css" media="screen" charset="utf-8"/>
    <link type="text/css" href="css/flick/jquery-ui-1.8.13.custom.css" rel="stylesheet"/>
    <script type="text/javascript" src="js/jquery-1.4.4.min.js"></script>
    <script type="text/javascript" src="js/jquery-ui-1.8.13.custom.min.js"></script>
    <script type="text/javascript" src="js/jquery-plugins/jquery.form.js"></script>
    <script type="text/javascript" src="iq.js"></script>
    <script type="text/javascript" src="orgunitsettings.js"></script>
    <script type="text/javascript">
        $(document).ready(function() {
            var unitId = <%= organization.getId()%>;

            $("#unitsettings-tabs").tabs();

            adjustViewPort();
            $('#modalizer').fadeOut(500);

            $('#unitsettings-general-tablink').click(function() {
                generateMainOrganizationForm(unitId);
                openUnitSettingsOnTab(0);
            });

            $('#modalizer').click(function() {
                $('#unitsettings-dialog').hide(0);
                $('#modalizer').fadeOut(500);
            });


            $('#imageonly-buttonAddSubUnit').click(function() {
                generateMainOrganizationForm(unitId);
                openUnitSettingsOnTab(1);
            });
            $('#imageonly-buttonAddFunction').click(function() {
                generateMainOrganizationForm(unitId);
                openUnitSettingsOnTab(3);
            });
            $('#imageonly-buttonAddGoal').click(function() {
                generateMainOrganizationForm(unitId);
                openUnitSettingsOnTab(2);
            });

        });

        function openUnitSettingsOnTab(tabnumber) {
            $('#unitsettings-dialog').show(0, function() {
                $("#unitsettings-tabs").tabs('select', tabnumber);
            });
            $('#modalizer').fadeTo(400, 0.8);
        }

        function generateCommonForm(unitId) {
            $('#unitsettings-general').empty().append(generateBaseForm(unitId));
        }
        function generateAdresses() {
        <%for (Relationship addressEntry : organization.getRelationships(SimpleRelationshipType.withName("HAS_ADDRESS"))) {%>

            var unitId = <%=addressEntry.getEndNode().getId()%>;
            var updateForm = generateUpdateForm('organization_address_form' + unitId);
            var data = getData(unitId);
            var properties = data.node.properties;

            var hiddenField_id = hiddenField('_id', unitId);
            var hiddenField_type = hiddenField('_type', 'node');
            var hiddenField_strict = hiddenField('_strict', 'true');
            var hiddenField_username = hiddenField('_username', 'admin');

            var addressDescriptionDiv = generateMainOrganizationAddressComponent('Adressbenämning', unitId, 'description', propValue(properties.description));
            var addressDiv = generateMainOrganizationAddressComponent('Adress', unitId, 'address', propValue(properties.address));
            var postalCodeDiv = generateMainOrganizationAddressComponent('Postnummer', unitId, 'postalcode', propValue(properties.postalcode));
            var cityDiv = generateMainOrganizationAddressComponent('Ort', unitId, 'city', propValue(properties.city));
            var countryDiv = generateMainOrganizationAddressComponent('Land', unitId, 'country', propValue(properties.country));

            updateForm.append(hiddenField_id, hiddenField_type, hiddenField_strict, hiddenField_username, '<br/>', addressDescriptionDiv, '<br/>', addressDiv, '<br/>', postalCodeDiv, '<br/>', cityDiv, '<br/>', countryDiv);
            $('#unitsettings-general').append(updateForm);
        <% } %>
        }
        function generateMainOrganizationForm(unitId) {
            $('#unitsettings-general').empty().append(generateBaseForm(unitId));
            generateOrgNrDiv(unitId).insertAfter("#descriptionDiv");
            generateAdresses();
        }

        function generateBossSelector() {
            bossSelectorDiv = fieldBox();
            bossSelectorLabel = fieldLabelBox();
            bossSelectorLabel.append("Chef");

            bossSelector = $('<select>');
            bossSelector.attr("id", "manager-selection");

        <%
         for (Node entry : personListGenerator.getSortedList(PersonListGenerator.ALPHABETICAL, false)) {

          try {

          if (!entry.getProperty("firstname", "").equals("") || !entry.getProperty("lastname", "").equals("")) { %>
            bossOption = $('<option>');
            bossOption.val(<%=entry.getId()%>);
            bossOption.append('<%=entry.getProperty("lastname", "")%>' + ", " + '<%=entry.getProperty("firstname", "")%>');
            bossSelector.append(bossOption);
        <% }
                     } catch (Exception ex) {
                             }
                     }
                     %>
            bossSelectorDiv.append(bossSelectorLabel, bossSelector);
            return bossSelectorDiv;
        }
        function generateSubUnitForm(unitId) {
            $('#unitsettings-general').empty().append(generateBaseForm(unitId));
            generateSubUnitAddressComponent(unitId).insertAfter('#web-field');
            generateBossSelector().insertAfter("#descriptionDiv");
        }
    </script>
</head>
<body onload="onload(<%= organization.getId()%>)" onresize="adjustViewPort()">
<%@include file="WEB-INF/jspf/iqpageheader.jsp" %>
<div id="main">
    <div id="content">
        <div class="header"><input type="text" class="text-field filter-field" onkeyup="unitTextFilter(event)"
                                   placeholder="Organisation/Enhet/Beskrivning" id="unit-text-filter"></div>
        <div id="unit-list" class="list-body">
            <div class="tree-view">
                <div id="unit-tree" class="tree-column">
                    <h3 id="unitsettings-general-tablink"><%=organization.getProperty("name", "")%>
                    </h3>
                    <ul>
                        <%
                            for (Relationship entry : organization.getRelationships(SimpleRelationshipType.withName("HAS_UNIT"))) {
                        %>
                        <jsp:include page="unittreeentry.jsp">
                            <jsp:param name="unitId" value="<%=entry.getEndNode().getId()%>"></jsp:param>
                            <jsp:param name="parentId" value="<%=organization.getId()%>"></jsp:param>
                        </jsp:include>
                        <br>
                        <%
                            }
                        %>
                    </ul>
                </div>
                <div class="tree-column">
                    <h3>
                        <button class="imageonly-button" id="imageonly-buttonAddSubUnit"><img
                                src="images/newunit.png" alt="Ny underenhet"></button>
                        <button class="imageonly-button" id="imageonly-buttonAddFunction"><img
                                src="images/newfunction.png" alt="Ny funktion"></button>
                        <button class="imageonly-button" id="imageonly-buttonAddGoal"><img
                                src="images/newgoal.png" alt="Nytt mål"></button>
                    </h3>
                    <%
                        for (Relationship entry : organization.getRelationships(SimpleRelationshipType.withName("HAS_UNIT"))) {
                    %>
                    <jsp:include page="unittreecontrol.jsp">
                        <jsp:param name="unitId" value="<%=entry.getEndNode().getId()%>"></jsp:param>
                        <jsp:param name="parentId" value="<%=organization.getId()%>"></jsp:param>
                    </jsp:include>
                    <br>
                    <br>
                    <%
                        }
                    %>
                </div>
            </div>
        </div>

        <div class="list-footer">
            &nbsp;
        </div>
    </div>
</div>
<div id="modalizer">&nbsp;</div>
<div id="unitsettings-dialog" style="display: none;">
    <div id="unitsettings-tabs">
        <ul>
            <li><a href="#unitsettings-general">Avdelningsinställningar</a></li>
            <li><a href="#unitsettings-subunits">Underavdelningar</a></li>
            <li><a href="#unitsettings-goals">Mål och uppgifter</a></li>
            <li><a href="#unitsettings-functions">Funktioner</a></li>
            <li><a href="#unitsettings-persons">Personer</a></li>
        </ul>
        <div class="unitsettings" id="unitsettings-general">
        </div>
        <div id="unitsettings-subunits">Phasellus mattis tincidunt nibh. Cras orci urna, blandit id, pretium vel,
            aliquet ornare, felis. Maecenas scelerisque sem non nisl. Fusce sed lorem in enim dictum bibendum.
        </div>
        <div id="unitsettings-goals">Nam dui erat, auctor a, dignissim quis, sollicitudin eu, felis. Pellentesque nisi
            urna, interdum eget, sagittis et, consequat vestibulum, lacus. Mauris porttitor ullamcorper augue.
        </div>
        <div id="unitsettings-functions">Nam dui erat, auctor a, dignissim quis, sollicitudin eu, felis. Pellentesque
            nisi urna, interdum eget, sagittis et, consequat vestibulum, lacus. Mauris porttitor ullamcorper augue.
        </div>
        <div id="unitsettings-persons">Nam dui erat, auctor a, dignissim quis, sollicitudin eu, felis. Pellentesque
            nisi urna, interdum eget, sagittis et, consequat vestibulum, lacus. Mauris porttitor ullamcorper augue.
        </div>
    </div>
</div>
</body>
</html>