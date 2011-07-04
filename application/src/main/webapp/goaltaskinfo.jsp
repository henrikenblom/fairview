<%-- 
    Document   : functions.jsp
    Created on : 2010-nov-16, 08:49:16
    Author     : henrik
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%@include file="WEB-INF/jspf/beanMapper.jsp" %>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
    "http://www.w3.org/TR/html4/loose.dtd">

<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Infero Quest - Mål och uppgifter</title>
        <link rel="stylesheet" href="css/newlook.css" type="text/css" media="screen" charset="utf-8" />
        <script type="text/javascript" src="js/jquery-1.4.4.min.js"></script>
        <script type="text/javascript" src="iq.js"></script>
        <script type="text/javascript">
             $(document).ready(function() {

                 adjustViewPort();
                 $('#modalizer').fadeOut(500);

            });
        </script>
    </head>
    <body onload="onload(<%= organization.getId()%>)" onresize="adjustViewPort()">
        <%@include file="WEB-INF/jspf/iqpageheader.jsp" %>
        <div id="main">
            <div id="content">
                <div class="header"></div>
                <div id="goal_task-list" class="list-body">

                    <%

                        for (Relationship entry : organization.getRelationships(SimpleRelationshipType.withName("HAS_GOAL"))) {

                            %>

                                <jsp:include page="goaltasklistentry.jsp">
                                    <jsp:param name="id" value="<%=entry.getEndNode().getId()%>"></jsp:param>
                                    <jsp:param name="called_from" value="organization"></jsp:param>
                                </jsp:include>

                            <%

                        }

                    %>

                </div>
                <div class="list-footer">
                    &nbsp;
                </div>
            </div>
            <div id="modalizer">&nbsp;</div>
            <%@include file="WEB-INF/jspf/goaldialog.jsp" %>
        </div>
    </body>
</html>
