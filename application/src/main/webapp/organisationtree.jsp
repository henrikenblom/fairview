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
    <script type="text/javascript" src="js/jquery-1.4.4.min.js"></script>
    <script type="text/javascript" src="js/jquery-ui-1.8.13.custom.min.js"></script>
    <script type="text/javascript" src="iq.js"></script>
    <script type="text/javascript">
        $(document).ready(function() {

            adjustViewPort();
            $('#modalizer').fadeOut(500);

        });
        $(function() {
            $("#unitsettings-tabs").tabs();
        });
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
                    <h3><%=organization.getProperty("name" ,"")%>
                    </h3>
                    <ul>
                        <%
                            for (Relationship entry : organization.getRelationships(SimpleRelationshipType.withName("HAS_UNIT"))) {
                        %>
                        <jsp:include page="unittreeentry.jsp">
                            <jsp:param name="unitId" value="<%=entry.getEndNode().getId()%>"></jsp:param>
                        </jsp:include>
                        <br>
                        <%
                            }
                        %>
                    </ul>
                </div>
                <div class="tree-column">
                    <h3>
                        <button class="imageonly-button"><img src="images/newunit.png" alt="Ny underenhet"></button>
                        <button class="imageonly-button"><img src="images/newfunction.png" alt="Ny funktion"></button>
                        <button class="imageonly-button"><img src="images/newgoal.png" alt="Nytt mål"></button>
                    </h3>
                    <%
                        for (Relationship entry : organization.getRelationships(SimpleRelationshipType.withName("HAS_UNIT"))) {
                    %>
                    <jsp:include page="unittreecontrol.jsp">
                        <jsp:param name="unitId" value="<%=entry.getEndNode().getId()%>"></jsp:param>
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
<div id="unitsettings-dialog">
    <div id="unitsettings-tabs">
        <ul>
            <li><a href="#unitsettings-general">Avdelningsinställningar</a></li>
            <li><a href="#unitsettings-subunits">Underavdelningar</a></li>
            <li><a href="#unitsettings-goals">Mål och uppgifter</a></li>
            <li><a href="#unitsettings-functions">Funktioner</a></li>
            <li><a href="#unitsettings-persons">Personer</a></li>
        </ul>
        <div id="unitsettings-general">Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor
            incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco
            laboris nisi ut aliquip ex ea commodo consequat test.
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