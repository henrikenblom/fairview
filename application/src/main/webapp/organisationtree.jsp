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
    <link type="text/css" href="css/jquery.qtip.css" rel="stylesheet"/>
    <script type="text/javascript" src="js/jquery-1.4.4.min.js"></script>
    <script type="text/javascript" src="js/jquery-ui-1.8.13.custom.min.js"></script>
    <script type="text/javascript" src="js/jquery-plugins/jquery.form.js"></script>
    <script type="text/javascript" src="iq.js"></script>
    <script type="text/javascript" src="popupControls.js"></script>
    <script type="text/javascript" src="formgenerator.js"></script>
    <script type="text/javascript" src="formSaving.js"></script>
    <script type="text/javascript" src="multiSelectGenerator.js"></script>
    <script type="text/javascript" src="js/jquery.curvycorners.source.js"></script>
    <script type="text/javascript" src="js/jquery.qtip.min.js"></script>
    <script type="text/javascript" src="js/jquery-plugins/jquery.multiselect2side.js"></script>
    <script type="text/javascript">
        $(document).ready(function() {
            $('.imageonly-button').qtip({
                style: {
                    classes: 'ui-tooltip-blue ui-tooltip-shadow ui-tooltip-rounded'
                }
            });
            var unitId = <%= organization.getId()%>;
            bindTabs();

            adjustViewPort();
            fadeOutModalizer();
            setupModalizerClickEvents();

            $('#unitsettings-general-tablink[name=unitsettings-general-tablink' + unitId + ']').click(function() {
                generateMainOrganizationPopup(unitId);
                openPopupTab(0);
            });


            $('#imageonly-buttonAddSubUnit').click(function() {
                generateMainOrganizationPopup(unitId);
                openPopupTab(1);
            });

            $('#imageonly-buttonAddFunction').click(function() {
                generateMainOrganizationPopup(unitId);
                openPopupTab(2);
            });


        });

        function generateMainOrganizationPopup(unitId) {
            var data = getNodeData(unitId);
            generateMainOrganizationEditForm(data);
            generateSubunitCreationTab(data);
            generateFunctionTab(data);
        }

        function generateSubunitPopup(unitId) {
            var data = getNodeData(unitId);
            generateSubunitEditForm(data);
            generateSubunitCreationTab(data);
            generateFunctionTab(data);
        }

        function generateSubunitCreationTab(data) {
            var unitId = data.node.id;
            $('#unitsettings-subunits').empty().append(generateSubunitCreationForm('name-field' + unitId, unitId));
            var submitButton = $('<button>');
            submitButton.addClass('addsubunit-button')
            submitButton.html('Lägg till underenhet till ' + data.node.properties.name.value);
            submitButton.click(function() {
                var createdSubunit = getRelationshipData(getNodeData(unitId).node.id);
                var createdSubunitId = createdSubunit.relationship.endNode;
                $('#subunitform').children().children('input[name="_id"]').val(createdSubunitId);
                $('#subunitform').ajaxSubmit(function() {
                    location.reload();  //reloads the page to make the newly created subunit to be visible in the organization tree
                });
            });
            submitButton.appendTo($('#unitsettings-subunits'));
        }

        function generateMainOrganizationEditForm(data) {
            $('#unitsettings-general').empty().append(generateBaseUnitEditForm(data));
            var saveButton = saveButtonComponent(getOrganizationFormId());
            saveButton.click(function() {
                editTreeNamesOnChange($('#name-field').val(), data.node.id);
                $('#header-organization-name').html($('#name-field').val());
                $('#popup-header').html($('#name-field').val());
            });
            $('#unitsettings-general').append(saveButton);
            generateOrgNrDiv(data).insertAfter("#descriptionDiv");
            generateSingleAddressComponent(data).insertAfter('#web-field');
            generateTabHeader(data.node.properties.name.value);
        }

        function generateSubunitEditForm(data) {
            $('#unitsettings-general').empty().append(generateBaseUnitEditForm(data));
            var saveButton = saveButtonComponent(getOrganizationFormId());
            saveButton.click(function() {
                editTreeNamesOnChange($('#name-field').val(), data.node.id);
                assignManager(data.node.id, $('#manager-selection'));
                $('#popup-header').html($('#name-field').val());
            });
            $('#unitsettings-general').append(saveButton);
            generateSingleAddressComponent(data).insertAfter('#web-field');
            generateBossSelector(data.node.id).insertAfter("#descriptionDiv");
            generateTabHeader(data.node.properties.name.value);
        }

        function generateFunctionTab(data) {
            var _unitId = data.node.id;
            $('#unitsettings-functions').empty().append(generateFunctionMultiSelectForm(_unitId));
            initDoubleBoxes();
            getDataUpdateDatabase(_unitId);
        }

        function generateAdresses() {
        <%for (Relationship addressEntry : organization.getRelationships(SimpleRelationshipType.withName("HAS_ADDRESS"))) {%>

            var unitId = <%=addressEntry.getEndNode().getId()%>;
            var updateForm = generateUpdateForm('organization_address_form' + unitId);
            var data = getNodeData(unitId);
            var properties = data.node.properties;

            var hiddenField_id = hiddenField('_id', unitId);
            var hiddenField_type = hiddenField('_type', 'node');
            var hiddenField_strict = hiddenField('_strict', 'true');
            var hiddenField_username = hiddenField('_username', 'admin');

            var addressDiv = generateMainOrganizationAddressComponent('Adress', unitId, 'address', propValue(properties.address));
            var postalCodeDiv = generateMainOrganizationAddressComponent('Postnummer', unitId, 'postalcode', propValue(properties.postalcode));
            var cityDiv = generateMainOrganizationAddressComponent('Ort', unitId, 'city', propValue(properties.city));
            var countryDiv = generateMainOrganizationAddressComponent('Land', unitId, 'country', propValue(properties.country));

            updateForm.append(hiddenField_id, hiddenField_type, hiddenField_strict, hiddenField_username, addressDiv, '<br/>', postalCodeDiv, '<br/>', cityDiv, '<br/>', countryDiv);
            $('#unitsettings-general').append(updateForm);
        <% } %>
        }
        function assignManager(unitId, bossSelector) {
            $.getJSON("fairview/ajax/assign_manager.do", {_startNodeId:unitId, _endNodeId:bossSelector.val()});
        }
        function generateBossSelector(unitId) {
            bossSelectorDiv = fieldBox();
            bossSelectorLabel = fieldLabelBox();
            bossSelectorLabel.append("Chef");

            bossSelector = $('<select>');
            bossSelector.attr("id", "manager-selection");
            bossOption = $('<option>');
            bossOption.val(-1);
            bossOption.append('Ingen chef vald');
            bossSelector.append(bossOption);
        <%
         for (Node entry : personListGenerator.getSortedList(PersonListGenerator.ALPHABETICAL, false)) {

          try {

          if (!entry.getProperty("firstname", "").equals("") || !entry.getProperty("lastname", "").equals("")) { %>
            var entryId = <%=entry.getId()%>;
            bossOption = $('<option>');
            bossOption.val(entryId);
            bossOption.append('<%=entry.getProperty("lastname", "")%>' + ", " + '<%=entry.getProperty("firstname", "")%>');
            bossSelector.append(bossOption);
        <% }
                     } catch (Exception ex) {
                             }
                     }
                     %>
            $.getJSON("fairview/ajax/get_manager.do", {_unitId: unitId}, function(data) {
                bossSelector.val(data.long);
            })

            bossSelectorDiv.append(bossSelectorLabel, bossSelector);
            return bossSelectorDiv;
        }
    </script>
</head>
<body onload="onload(<%= organization.getId()%>)" onresize="adjustViewPort()">
<%@include file="WEB-INF/jspf/iqpageheader.jsp" %>
<div id="main">
    <div id="content">
        <div class="header"></div>
        <div id="unit-list" class="list-body">
            <div class="tree-view">
                <div id="unit-tree" class="tree-column">
                    <h3 id="unitsettings-general-tablink"
                        name="unitsettings-general-tablink<%=organization.getId()%>"><%=organization.getProperty("name", "")%>
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
                <div class="tree-column" id="unit-tree-icons">
                    <h3>
                        <button class="imageonly-button" title="Lägg till underenhet"
                                id="imageonly-buttonAddSubUnit"><img
                                src="images/newunit.png" alt="Ny underenhet"></button>
                        <button class="imageonly-button" title="Lägg till funktion" id="imageonly-buttonAddFunction">
                            <img
                                    src="images/newfunction.png" alt="Ny funktion"></button>
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
            <div class="helpbox">
                <div class="helpbox-header">Hjälpruta</div>
                <div class="helpbox-content">Beskrivning av ikonernas funktion: <br/> <br/>

                    <div class="helpbox-listentry"><img src="images/newunit.png" class="helpbox-image">Lägg till
                        underenhet
                        <br/></div>
                    <div class="helpbox-listentry"><img src="images/newfunction.png" class="helpbox-image">Lägg till
                        funktion <br/></div>
                </div>
            </div>
        </div>
        <div class="list-footer">
            &nbsp;
        </div>
    </div>
</div>
<div id="modalizer">&nbsp;</div>
<div id="popup-dialog" style="display: none;">
    <div id="popup-tabs">
        <ul>
            <li><a href="#unitsettings-general">Avdelningsinställningar</a></li>
            <li><a href="#unitsettings-subunits">Lägg till Underavdelning</a></li>
            <li><a href="#unitsettings-functions">Funktioner</a></li>
        </ul>
        <div id="popup-header"></div>
        <div class="unitsettings" id="unitsettings-general"></div>
        <div class="unitsettings" id="unitsettings-subunits">
        </div>
        <div id="unitsettings-functions">
        </div>
    </div>
</div>
</body>
</html>