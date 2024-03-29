<%--
  Created by IntelliJ IDEA.
  User: henrik
  Date: 2011-06-10
  Time: 10.34
  To change this template use File | Settings | File Templates.
--%>
<%@page contentType="text/html" pageEncoding="UTF-8" %>

<%@include file="WEB-INF/jspf/beanMapper.jsp" %>

<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>Infero Quest - Enheter</title>
    <link rel="stylesheet" href="css/newlook.css" type="text/css" media="screen" charset="utf-8"/>
    <link type="text/css" href="css/jquery-ui/jquery-ui-1.8.13.custom.css" rel="stylesheet"/>
    <link type="text/css" href="css/jquery.qtip.css" rel="stylesheet"/>
    <script type="text/javascript" src="js/plugins/jquery-1.4.4.min.js"></script>
    <script type="text/javascript" src="js/plugins/jquery-ui-1.8.13.custom.min.js"></script>
    <script type="text/javascript" src="js/plugins/jquery.form.js"></script>
    <script type="text/javascript" src="js/iq.js"></script>
    <script type="text/javascript" src="js/popupControls.js"></script>
    <script type="text/javascript" src="js/formgenerator.js"></script>
    <script type="text/javascript" src="js/plugins/jquery.curvycorners.source.js"></script>
    <script type="text/javascript" src="js/plugins/jquery.qtip.min.js"></script>
    <script type="text/javascript" src="js/plugins/jquery.validate.js"></script>
    <script type="text/javascript" src="js/plugins/jquery.dataSelector.js"></script>
    <script type="text/javascript" src="js/plugins/spin.min.js"></script>
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
            bindEmployeeTabs();

            $('#unitsettings-general-tablink[name=unitsettings-general-tablink' + unitId + ']').click(function() {
                generateMainOrganizationTabs();
                generateMainOrganizationPopup(unitId);
                openPopupTab(0);
            });


            $('#imageonly-buttonAddSubUnit').click(function() {
                generateMainOrganizationPopup(unitId);
                openPopupTab(1);
            });

            if (<%=organization.getProperty("name", "").equals("")%>) {
                var data = getUnitData(unitId);
                $('#modalizer').fadeIn(100);
                generateMainOrganizationTabs();
                generateMainOrganizationEditForm(data);
                $('#popup-tabs li a[href="#unitsettings-subunits"]').hide();
                $('#popup-tabs li a[href="#unitsettings-image"]').hide();
                openPopupTab(0);
            }
        });

        function generateMainOrganizationTabs(){
            var linkData = [
                        ['unitsettings-general', 'Avdelningsinställningar'],
                        ['unitsettings-subunits', 'Lägg till Underavdelning'],
                        ['unitsettings-image', 'Logotyp']
                ];
                $('#popup-dialog').empty().append(generateTabs(linkData));
                $('#popup-tabs').tabs();
        }

        function generateMainOrganizationPopup(unitId) {
            var data = getUnitData(unitId);
            generateMainOrganizationEditForm(data);
            generateSubunitCreationTab(data);
        }

        function generateSubunitPopup(unitId) {
            var data = getUnitData(unitId);
            var linkData = [
                        ['unitsettings-general', 'Avdelningsinställningar'],
                        ['unitsettings-subunits', 'Lägg till Underavdelning']
                ];
                $('#popup-dialog').empty().append(generateTabs(linkData));
                $('#popup-tabs').tabs();
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
                    <div>
                    <h3 id="unitsettings-general-tablink"
                        name="unitsettings-general-tablink<%=organization.getId()%>"><%=organization.getProperty("name", "")%>
                        &nbsp;

                    </h3>
                    <button class="imageonly-button" title="Lägg till underenhet"
                                id="imageonly-buttonAddSubUnit" onclick="javascript:generateMainOrganizationTabs()"><img
                                src="images/newunit.png" alt="Ny underenhet" /></button>
                    </div>
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
</div>
</body>
</html>