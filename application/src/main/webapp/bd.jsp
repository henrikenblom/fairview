<%

    if (request.getParameter("id") == null) {

        response.sendRedirect("bd.jsp?id=0");

    }

%>

<%@ page import="org.neo4j.graphdb.Node" %>
<%@ page import="org.neo4j.graphdb.Relationship" %>

<%--
  Created by IntelliJ IDEA.
  User: henrik
  Date: 2011-01-11
  Time: 10.23
  To change this template use File | Settings | File Templates.
--%>

<%@include file="WEB-INF/jspf/beanMapper.jsp" %>
<script type="text/javascript" src="js/jquery-1.4.4.min.js"></script>
<script type="text/javascript">

    function deleteNode() {

        $.getJSON("neo/ajax/delete_node.do", {_nodeId:<%=request.getParameter("id")%>}, function(data) {

            document.location = 'bd.jsp?id=0';

        });

    }

</script>
<%
    Node node = neo.getNodeById(Long.decode(request.getParameter("id")));
%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head><title></title></head>

<body>
<a href="javascript:deleteNode()">TA BORT</a><br><br><br>
<% for (String entry : node.getPropertyKeys()) { %>
       <%= entry%>: <%= node.getProperty(entry)%><br>
<% } %>
<br>
<br>
<% for (Relationship entry : node.getRelationships(Direction.BOTH)) {
    try {
%>
       <a href="?id=<%= entry.getStartNode().getId() %>"><%= entry.getStartNode().getId() %></a> -- <%= entry.getType() %> --> <a href="?id=<%= entry.getEndNode().getId() %>"><%= entry.getEndNode().getId() %></a><br>
 <%} catch (Exception ex) {
 }
 } %>


</body>
</html>