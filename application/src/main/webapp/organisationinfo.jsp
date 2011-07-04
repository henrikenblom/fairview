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

                            <br>
                            <div class="field-box"><b>Namn</b><br><%=organization.getProperty("name", "")%></div>
                            <br>
                            <br>
                            <div class="field-box"><b>Beskrivning</b><br><%=organization.getProperty("description", "-")%></div>
                            <br>
                            <br>
                            <div class="field-box"><b>Organisationsnummer</b><br><%=organization.getProperty("regnr", "-")%></div>
                            <br>
                            <br>
                            <div class="field-box"><b>Telefonnummer</b><br><%=organization.getProperty("phone", "-")%></div>
                            <br>
                            <br>
                            <div class="field-box"><b>Faxnummer</b><br><%=organization.getProperty("fax", "-")%></div>
                            <br>
                            <br>
                            <div class="field-box"><b>E-post</b><br><%=organization.getProperty("email", "-")%></div>
                            <br>
                            <br>
                            <div class="field-box"><b>Hemsida</b><br><%=organization.getProperty("web", "-")%></div>
                            <br>
                            <br>
                            </fieldset>
                            </form>
                            <form id="organization_address_form0" action="neo/ajax/update_properties.do" method="post">
                            <fieldset>
                            <input type="hidden" name="_id" value="<%= mainAddressNode.getId()%>">
                            <input type="hidden" name="_type" value="node">
                            <input type="hidden" name="_strict" value="true">
                            <input type="hidden" name="_username" value="admin">
                            <div class="field-box"><b>Adressbenämning</b><br><%=mainAddressNode.getProperty("description", "Huvudadress")%></div>
                            <br>
                            <br>
                            <div class="field-box"><b>Adress</b><br><%=mainAddressNode.getProperty("address", "-")%></div>
                            <br>
                            <br>
                            <div class="field-box"><b>Postnummer</b><br><%=mainAddressNode.getProperty("postalcode", "-")%></div>
                            <br>
                            <br>
                            <div class="field-box"><b>Ort</b><br><%=mainAddressNode.getProperty("city", "-")%></div>
                            <br>
                            <br>
                            <div class="field-box"><b>Land</b><br><%=mainAddressNode.getProperty("country", "-")%></div>
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
                                <div class="field-box"><b>Adressbenämning</b><br><%=entry.getEndNode().getProperty("description", "-")%></div>
                                <br>
                                <br>
                                <div class="field-box"><b>Adress</b><br><%=entry.getEndNode().getProperty("address", "-")%></div>
                                <br>
                                <br>
                                <div class="field-box"><b>Postnummer</b><br><%=entry.getEndNode().getProperty("postalcode", "-")%></div>
                                <br>
                                <br>
                                <div class="field-box"><b>Ort</b><br><%=entry.getEndNode().getProperty("city", "-")%></div>
                                <br>
                                <br>
                                <div class="field-box"><b>Land</b><br><%=entry.getEndNode().getProperty("country", "")%></div>
                                <br>
                            </fieldset>
                        </form>

                        <%

                            }

                        }

                        %>
                        </div>
                        <br>
                        <br>
                        &nbsp;

                    </div>
                    <div id="mainorganisation-footer" class="list-footer">&nbsp;</div>

                    <%

                        for (Relationship entry : organization.getRelationships(SimpleRelationshipType.withName("HAS_UNIT"))) {

                            try {


                    %>

                        <jsp:include page="unitinfo.jsp">
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
            </div>
        </body>
    </html>