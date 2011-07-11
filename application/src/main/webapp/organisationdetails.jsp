<%@ page import="org.neo4j.graphdb.Transaction" %>
<%@ page import="com.fairviewiq.utils.PersonListGenerator" %>
<%--
   Author     : henrik
--%>

    <%@page contentType="text/html" pageEncoding="UTF-8" trimDirectiveWhitespaces="true"%>

    <%@include file="WEB-INF/jspf/beanMapper.jsp" %>

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

            }    finally {

                   tx.finish();

            }

        }

        StringBuilder managerSnippet = new StringBuilder();

        for (Node entry : personListGenerator.getSortedList(PersonListGenerator.ALPHABETICAL, false)) {

            try {

                if (!entry.getProperty("firstname", "").equals("") || !entry.getProperty("lastname", "").equals("")) {


                    managerSnippet.append("<option value=\"");
                    managerSnippet.append(entry.getId());
                    managerSnippet.append("\">");
                    managerSnippet.append(entry.getProperty("lastname", ""));
                    managerSnippet.append(", ");
                    managerSnippet.append(entry.getProperty("firstname", ""));
                    managerSnippet.append("</option>\\\n");

                }
                    } catch (Exception ex) {

                }

            }

    %>

    <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
        "http://www.w3.org/TR/html4/loose.dtd">

    <html>
        <head>
            <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
            <title>Infero Quest - Organisation</title>
            <link rel="stylesheet" href="css/newlook.css" type="text/css" media="screen" charset="utf-8" />
            <script type="text/javascript" src="js/jquery-1.4.4.min.js"></script>
            <script type="text/javascript" src="js/jquery-plugins/jquery.form.js"></script>
            <script type="text/javascript" src="js/jquery-plugins/jquery.scrollTo-min.js"></script>
            <script type="text/javascript" src="js/jquery-plugins/jquery.url.min.js"></script>
            <script type="text/javascript" src="js/jquery-plugins/jquery.easing.1.3.js"></script>
            <script type="text/javascript" src="iq.js"></script>
            <script type="text/javascript">

                function assignManager(select, unitId) {

                    $.getJSON("neo/ajax/create_relationship.do", {_startNodeId:unitId, _type:"HAS_MANAGER", _endNodeId:select.value});

                }

                function addOrganisationSubUnit(parentId, parentNode) {

                    $.getJSON("neo/ajax/create_relationship.do", {_startNodeId:parentNode, _type:"HAS_UNIT" }, function(data) {

                    $('<div class="header text-header" id="subunit_header' + data.relationship.endNode + '">\
                                    Underliggande enhet till ' + $('#' + parentId).val() + '<div class="expand-contract"><img onclick="toggleExpand(event)" id="subunit' + data.relationship.endNode + '-expand" src="images/contract.png"></div>\
                                </div>\
                                <div id="subunit' + data.relationship.endNode + '-list" class="list-body profile-list">\
                                    <form id="subunit_form' + data.relationship.endNode + '" action="neo/ajax/update_properties.do" method="post">\
                                    <fieldset>\
                                    <input type="hidden" name="_id" value="' + data.relationship.endNode + '">\
                                    <input type="hidden" name="_type" value="node">\
                                    <input type="hidden" name="_strict" value="true">\
                                    <input type="hidden" name="_username" value="admin">\
                                    <input type="hidden" name="nodeClass" value="unit">\
                                    <div class="field-box"><div class="field-label-box">Namn</div><div><input type="text" name="name" onchange="$(\'#subunit_form' + data.relationship.endNode + '\').ajaxSubmit()" class="text-field" id="name-field' + data.relationship.endNode + '"></div></div>\
                                    <br>\
                                    <div class="field-box"><div class="field-label-box">Beskrivning</div><div><textarea name="description" onchange="$(\'#subunit_form' + data.relationship.endNode + '\').ajaxSubmit()" id="description-field' + data.relationship.endNode + '"></textarea></div></div>\
                                    <br>\
                                    <div class="field-label-box">Chef</div>\
                                    <div>\
                                        <select id="manager-selection" name="manager" onchange="assignManager(this, ' + data.relationship.endNode + ')">\
                                            <option>Välj...</option>\
                                            <%=managerSnippet.toString()%>\
                                    </select>\
                                    </div>\
                                    <br>\
                                    <div class="field-box"><div class="field-label-box">Telefonnummer</div><div><input type="text" name="phone" onchange="$(\'#subunit_form' + data.relationship.endNode + '\').ajaxSubmit()" class="text-field" id="phone-field' + data.relationship.endNode + '"></div></div>\
                                    <br>\
                                    <div class="field-box"><div class="field-label-box">Faxnummer</div><div><input type="text" name="fax" onchange="$(\'#subunit_form' + data.relationship.endNode + '\').ajaxSubmit()" class="text-field" id="fax-field' + data.relationship.endNode + '"></div></div>\
                                    <br>\
                                    <div class="field-box"><div class="field-label-box">E-post</div><div><input type="text" name="email" onchange="$(\'#subunit_form' + data.relationship.endNode + '\').ajaxSubmit()" class="text-field" id="email-field' + data.relationship.endNode + '"></div></div>\
                                    <br>\
                                    <div class="field-box"><div class="field-label-box">Hemsida</div><div><input type="text" name="web" onchange="$(\'#subunit_form' + data.relationship.endNode + '\').ajaxSubmit()" class="text-field" id="web-field' + data.relationship.endNode + '"></div></div>\
                                    <br>\
                                    <div class="field-box"><div class="field-label-box">Adress</div><div><input type="text" name="address" onchange="$(\'#subunit_form' + data.relationship.endNode + '\').ajaxSubmit()" class="text-field" id="streetaddress-field' + data.relationship.endNode + '"></div></div>\
                                    <br>\
                                    <div class="field-box"><div class="field-label-box">Postnummer</div><div><input type="text" name="postalcode" onchange="$(\'#subunit_form' + data.relationship.endNode + '\').ajaxSubmit()" class="text-field" id="zip-field' + data.relationship.endNode + '"></div></div>\
                                    <br>\
                                    <div class="field-box"><div class="field-label-box">Ort</div><div><input type="text" name="city" onchange="$(\'#subunit_form' + data.relationship.endNode + '\').ajaxSubmit()" class="text-field" id="city-field' + data.relationship.endNode + '"></div></div>\
                                    <br>\
                                    <div class="field-box"><div class="field-label-box">Land</div><div><input type="text" name="country" onchange="$(\'#subunit_form' + data.relationship.endNode + '\').ajaxSubmit()" class="text-field" id="country-field' + data.relationship.endNode + '"></div></div>\
                                    <br>\
                                    </fieldset>\
                                    </form>\
                                    <br>\
                                </div>\
                                <div id="subunit' + data.relationship.endNode + '-footer" class="list-footer"><a href="javascript: addOrganisationSubUnit(\'name-field' + data.relationship.endNode + '\', ' + data.relationship.endNode + ')">Lägg till underliggande enhet</a>\
                                &nbsp;<a href="javascript: deleteOrganisationSubUnit(' + data.relationship.endNode + ')">Avbryt</a>\
                            </div>').appendTo($('#content'));

                        $('#main').scrollTo($('#subunit_header' + data.relationship.endNode), 1600, {easing: 'easeOutSine', offset: {left: 0, top: -8} });


                                $('#name-field' + data.relationship.endNode).focus();

                                });


                }

                function deleteOrganisationSubUnit(node) {

                    $.getJSON("neo/ajax/delete_node.do", {_nodeId:node}, function() { changeView('organisationdetails.jsp'); });

                }

                function scrollToUnit() {

                    if ($.url.param("unitId")) {

                        $('#main').scrollTo($('#subunit_header' + $.url.param("unitId")), 1200, {easing: 'easeOutSine', offset: {left: 0, top: -8} });

                    } else {

                        $('#name-field').focus();

                    }

                }

                $(document).ready(function() {

                    adjustViewPort();

                    setTimeout('scrollToUnit()', 400);

                    $('#modalizer').fadeOut(500);

                });

            </script>

        </head>
        <body onload="onload(<%= organization.getId()%>)" onresize="adjustViewPort()">
            <%@include file="WEB-INF/jspf/iqpageheader.jsp" %>
            <div id="main">
                <div id="content">
                    <div class="header text-header">
                        Huvudorganisation<div class="expand-contract"><img onclick="toggleExpand(event)" id="mainorganisation-expand" src="images/newlook/contract.png"></div>
                    </div>
                    <div id="mainorganisation-list" class="list-body profile-list">
                        <form id="organization_form" action="neo/ajax/update_properties.do" method="post">
                        <fieldset>
                            <input type="hidden" name="_id" value="<%= organization.getId()%>">
                            <input type="hidden" name="_type" value="node">
                            <input type="hidden" name="_strict" value="true">
                            <input type="hidden" name="_username" value="admin">
                        <div class="field-box"><div class="field-label-box">Namn</div><div><input type="text" onchange="$('#organization_form').ajaxSubmit(organizationFormSaved())" value="<%=organization.getProperty("name", "")%>" class="text-field" id="name-field" name="name"></div></div>
                        <br>
                        <div class="field-box"><div class="field-label-box">Beskrivning</div><div><textarea onchange="$('#organization_form').ajaxSubmit(organizationFormSaved())" id="description-field" name="description"><%=organization.getProperty("description", "")%></textarea></div></div>
                        <br>
                        <div class="field-box"><div class="field-label-box">Organisationsnummer</div><div><input onchange="$('#organization_form').ajaxSubmit(organizationFormSaved())" type="text" value="<%=organization.getProperty("regnr", "")%>" name="regnr" class="text-field" id="orgnr-field"></div></div>
                        <br>
                        <div class="field-box"><div class="field-label-box">Telefonnummer</div><div><input type="text" onchange="$('#organization_form').ajaxSubmit(organizationFormSaved())" value="<%=organization.getProperty("phone", "")%>" name="phone" class="text-field" id="phone-field"></div></div>
                        <br>
                        <div class="field-box"><div class="field-label-box">Faxnummer</div><div><input type="text" onchange="$('#organization_form').ajaxSubmit(organizationFormSaved())" value="<%=organization.getProperty("fax", "")%>" name="fax" class="text-field" id="fax-field"></div></div>
                        <br>
                        <div class="field-box"><div class="field-label-box">E-post</div><div><input type="text" onchange="$('#organization_form').ajaxSubmit(organizationFormSaved())" value="<%=organization.getProperty("email", "")%>" name="email" class="text-field" id="email-field"></div></div>
                        <br>
                        <div class="field-box"><div class="field-label-box">Hemsida</div><div><input type="text" onchange="$('#organization_form').ajaxSubmit(organizationFormSaved())" value="<%=organization.getProperty("web", "")%>" name="web" class="text-field" id="web-field"></div></div>
                        <br>
                            </fieldset>
                            </form>
                            <form id="organization_address_form0" action="neo/ajax/update_properties.do" method="post">
                            <fieldset>
                            <input type="hidden" name="_id" value="<%= mainAddressNode.getId()%>">
                            <input type="hidden" name="_type" value="node">
                            <input type="hidden" name="_strict" value="true">
                            <input type="hidden" name="_username" value="admin">
                        <div class="field-box"><div class="field-label-box">Adressbenämning</div><div><input type="text" onchange="$('#organization_address_form0').ajaxSubmit()" class="text-field" id="addressname-field0" name="description" value="<%=mainAddressNode.getProperty("description", "Huvudadress")%>"></div></div>
                        <br>
                        <div class="field-box"><div class="field-label-box">Adress</div><div><input type="text" onchange="$('#organization_address_form0').ajaxSubmit()" class="text-field" id="streetaddress-field0" name="address" value="<%=mainAddressNode.getProperty("address", "")%>"></div></div>
                        <br>
                        <div class="field-box"><div class="field-label-box">Postnummer</div><div><input type="text" onchange="$('#organization_address_form0').ajaxSubmit()" class="text-field" id="zip-field0" name="postalcode" value="<%=mainAddressNode.getProperty("postalcode", "")%>"></div></div>
                        <br>
                        <div class="field-box"><div class="field-label-box">Ort</div><div><input type="text" onchange="$('#organization_address_form0').ajaxSubmit()" class="text-field" id="city-field0" name="city" value="<%=mainAddressNode.getProperty("city", "")%>"></div></div>
                        <br>
                        <div class="field-box"><div class="field-label-box">Land</div><div><input type="text" onchange="$('#organization_address_form0').ajaxSubmit()" class="text-field" id="country-field0" name="country" value="<%=mainAddressNode.getProperty("country", "")%>"></div></div>
                        <br>

                        </fieldset>
                                </form>
                        <div id="additional-adresses-box">
                        <%

                        for (Relationship entry : organization.getRelationships(SimpleRelationshipType.withName("HAS_ADDRESS"))) {

                            if (entry.getEndNode().getId() != mainAddressNode.getId()) {

                        %>

                        <form id="organization_address_form<%=entry.getEndNode().getId()%>" action="neo/ajax/update_properties.do" method="post">
                        <fieldset>
                        <input type="hidden" name="_id" value="<%=entry.getEndNode().getId()%>">
                        <input type="hidden" name="_type" value="node">
                        <input type="hidden" name="_strict" value="true">
                        <input type="hidden" name="_username" value="admin">
                        <div class="field-box"><div class="field-label-box">Adressbenämning</div><div><input type="text" onchange="$('#organization_address_form<%=entry.getEndNode().getId()%>').ajaxSubmit()" class="text-field" id="addressname-field<%=entry.getEndNode().getId()%>" name="description" value="<%=entry.getEndNode().getProperty("description", "")%>"></div></div>
                        <br>
                        <div class="field-box"><div class="field-label-box">Adress</div><div><input type="text" onchange="$('#organization_address_form<%=entry.getEndNode().getId()%>').ajaxSubmit()" class="text-field" id="streetaddress-field<%=entry.getEndNode().getId()%>" name="address" value="<%=entry.getEndNode().getProperty("address", "")%>"></div></div>
                        <br>
                        <div class="field-box"><div class="field-label-box">Postnummer</div><div><input type="text" onchange="$('#organization_address_form<%=entry.getEndNode().getId()%>').ajaxSubmit()" class="text-field" id="zip-field<%=entry.getEndNode().getId()%>" name="postalcode" value="<%=entry.getEndNode().getProperty("postalcode", "")%>"></div></div>
                        <br>
                        <div class="field-box"><div class="field-label-box">Ort</div><div><input type="text" onchange="$('#organization_address_form<%=entry.getEndNode().getId()%>').ajaxSubmit()" class="text-field" id="city-field<%=entry.getEndNode().getId()%>" name="city" value="<%=entry.getEndNode().getProperty("city", "")%>"></div></div>
                        <br>
                        <div class="field-box"><div class="field-label-box">Land</div><div><input type="text" onchange="$('#organization_address_form<%=entry.getEndNode().getId()%>').ajaxSubmit()" class="text-field" id="country-field<%=entry.getEndNode().getId()%>" name="country" value="<%=entry.getEndNode().getProperty("country", "")%>"></div></div>
                        <br>
                        </fieldset>
                        </form>

                        <%

                            }

                        }

                        %>
                        </div>
                        <br>
                        <a href="javascript: addMainOrganisationAddressFieldButtonClick(event)">Lägg till ytterligare en adress</a>
                        <br>
                        &nbsp;
                    </div>
                    <div id="mainorganisation-footer" class="list-footer">
                        <a href="javascript: addOrganisationSubUnit('name-field', <%= organization.getId()%>)">Lägg till underliggande enhet</a>
                    </div>

                    <%

                        for (Relationship entry : organization.getRelationships(SimpleRelationshipType.withName("HAS_UNIT"))) {

                            try {


                    %>

                        <jsp:include page="unit.jsp">
                            <jsp:param name="parentName" value="<%=organization.getProperty("name", "")%>"></jsp:param>
                            <jsp:param name="parentId" value="<%=organization.getId()%>"></jsp:param>
                            <jsp:param name="unitId" value="<%=entry.getEndNode().getId()%>"></jsp:param>
                        </jsp:include>

                    <%
                            } catch (Exception ex) {
                                   response.getWriter().write(ex.getMessage());
                            }

                        }
                    %>

                </div>
                <div id="modalizer">&nbsp;</div>
                <%@include file="WEB-INF/jspf/goaldialog.jsp" %>
            </div>
        </body>
    </html>