<%@ page import="org.neo4j.kernel.impl.batchinsert.SimpleRelationship" %>
<%--
    Document   : index
    Created on : 2010-okt-28, 13:08:39
    Author     : henrik
--%>

<%@page contentType="text/html" pageEncoding="UTF-8" %>

<%@include file="WEB-INF/jspf/beanMapper.jsp" %>


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
"http://www.w3.org/TR/html4/loose.dtd">

<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>Infero Quest - Startsida</title>
    <link rel="stylesheet" href="css/newlook.css" type="text/css" media="screen" charset="utf-8"/>
    <script type="text/javascript" src="js/plugins/jquery-1.4.4.min.js"></script>
    <script type="text/javascript" src="js/iq.js"></script>
    <script type="text/javascript" src="js/formgenerator.js"></script>
    <script type="text/javascript">
        $(document).ready(function() {
            var organisationId = <%=organization.getId()%>;
            adjustViewPort();
            $('#modalizer').fadeOut(500);
            generateLogoMediumImage(organisationId);
            //test
        });
    </script>
</head>
<body onload="onload(<%= organization.getId()%>)" onresize="adjustViewPort()">
<%@include file="WEB-INF/jspf/iqpageheader.jsp" %>
<div id="main">
    <div id="content">
        <div id="frontpage-box">
            <div id="frontpage-image-box">
            </div>
            <div id="frontpage-information-box">
                <h2><%=organization.getProperty("name", "Namnlös")%>
                </h2>
                <br>
                <%=organization.getProperty("address", "")%><br>
                <%=organization.getProperty("postalcode", "")%> <%=organization.getProperty("city", "")%><br>
                Tel: <%=organization.getProperty("phone", "")%><br>
                Fax: <%=organization.getProperty("fax", "")%><br>
            </div>
        </div>
    </div>
    <div id="modalizer">&nbsp;</div>
</div>
</body>
</html>