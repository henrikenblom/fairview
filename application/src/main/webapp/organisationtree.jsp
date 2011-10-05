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
    <script type="text/javascript" src="js/jquery.curvycorners.source.js"></script>
    <script type="text/javascript" src="js/jquery.qtip.min.js"></script>
    <script type="text/javascript" src="js/jquery-plugins/jquery.multiselect2side.js"></script>
    <script type="text/javascript" src="js/jquery.validate.js"></script>
    <script type="text/javascript">
        $(document).ready(function() {
            $('.imageonly-button').qtip({
                style: {
                    classes: 'ui-tooltip-blue ui-tooltip-shadow ui-tooltip-rounded'
                }
            });
            var unitId = <%= organization.getId()%>;

            adjustViewPort();
            fadeOutModalizer();
            bindTabs();

            $('#unitsettings-general-tablink[name=unitsettings-general-tablink' + unitId + ']').click(function() {
                generateMainOrganizationPopup(unitId);
                openPopupTab(0);
            });


            $('#imageonly-buttonAddSubUnit').click(function() {
                generateMainOrganizationPopup(unitId);
                openPopupTab(1);
            });

            if (<%=organization.getProperty("name", "").equals("")%>) {
                var data = getUnitData(unitId);
                generateMainOrganizationEditForm(data);
                $('#popup-tabs li a[href="#unitsettings-subunits"]').hide();
                openPopupTab(0);
            }
        });

        function generateMainOrganizationPopup(unitId) {
            var data = getUnitData(unitId);
            generateMainOrganizationEditForm(data);
            generateSubunitCreationTab(data);
        }

        function generateSubunitPopup(unitId) {
            var data = getUnitData(unitId);
            generateSubunitEditForm(data);
            generateSubunitCreationTab(data);
        }

        function generateSubunitCreationTab(data) {
            var unitId = data.node.id;
            $('#unitsettings-subunits').empty().append(generateSubunitCreationForm('name-field' + unitId, unitId));
            var submitButton = $('<button>');
            submitButton.addClass('addsubunit-button')
            submitButton.attr('disabled', 'disabled');
            submitButton.html('Lägg till underenhet till ' + propValue(data.node.properties.name));
            submitButton.click(function() {
                $('#subunitform').ajaxSubmit(function(data) {
                    $.getJSON("neo/ajax/create_relationship.do", {_startNodeId:unitId, _endNodeId: data.node.id,_type:"HAS_UNIT" },
                            function() {
                                reloadPage();
                            });
                });
            });
            $('#subunitform #descriptionDiv').append(addManager(getSubUnitCreationFormId()));
            submitButton.appendTo($('#unitsettings-subunits'));

            var cancelButton = generateCancelButton();
            cancelButton.appendTo($('#unitsettings-subunits'));
        }

        function reloadPage() {
            location.reload();
        }

        function generateMainOrganizationEditForm(data) {
            $('#unitsettings-general').empty().append(generateBaseUnitEditForm(data));
            var saveButton = footerButtonsComponent();
            saveButton.children('.saveButton').click(function() {
                editTreeNamesOnChange($('#name-field').val(), data.node.id);
                $('#header-organization-name').html($('#name-field').val());
            });
            $('#unitsettings-general').append(saveButton);
            generateOrgNrDiv(data).insertAfter("#descriptionDiv");
            generateImageUrlDiv(data).insertAfter("#descriptionDiv");
            generateSingleAddressComponent(data).insertAfter($('#web-field').parent());
        }

        function generateSubunitEditForm(data) {
            $('#unitsettings-general').empty().append(generateBaseUnitEditForm(data));
            var saveButton = footerButtonsComponent();

            saveButton.children('.saveButton').click(function() {
                editTreeNamesOnChange($('#name-field').val(), data.node.id);
            });
            $('#unitsettings-general').append(saveButton);
            generateSingleAddressComponent(data).insertAfter($('#web-field').parent());
            addManager(getOrganizationFormId(), data.node.id).appendTo("#descriptionDiv");
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
                        underenhet<br/></div>
                    <div class="helpbox-listentry"><img src="images/delete.png" class="helpbox-image">Ta bort enhet
                    </div>
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
        </ul>
        <div class="unitsettings" id="unitsettings-general"></div>
        <div class="unitsettings" id="unitsettings-subunits">
        </div>
    </div>
</div>
</body>
</html>