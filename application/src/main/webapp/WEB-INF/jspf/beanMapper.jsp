<%@ page import="org.neo4j.kernel.EmbeddedGraphDatabase" %>
<%@ page import="org.springframework.web.context.support.WebApplicationContextUtils" %>
<%@ page import="se.codemate.neo4j.SimpleRelationshipType" %>
<%@ page import="org.neo4j.graphdb.*" %>
<%@ page import="com.fairviewiq.utils.PersonListGenerator" %>
<%@ page import="com.fairviewiq.utils.FunctionListGenerator" %>
<%@ page import="se.codemate.spring.security.NeoUserDetailsService" %>
<%@ page import="se.codemate.neo4j.NeoSearch" %>
<%@ page import="com.fairviewiq.utils.UnitListGenerator" %>

<%
    EmbeddedGraphDatabase neo = (EmbeddedGraphDatabase) WebApplicationContextUtils.getWebApplicationContext(application).getBean("neo");
    NeoSearch neoSearch = (NeoSearch) WebApplicationContextUtils.getWebApplicationContext(application).getBean("neoSearch");
    Node organization = ((Iterable<Relationship>) neo.getReferenceNode().getRelationships(SimpleRelationshipType.withName("HAS_ORGANIZATION"), Direction.OUTGOING)).iterator().next().getEndNode();
    PersonListGenerator personListGenerator = new PersonListGenerator(neo);
    FunctionListGenerator functionListGenerator = new FunctionListGenerator(neo);
    UnitListGenerator unitListGenerator = new UnitListGenerator(neo);

    Node admin= null;

    for (Relationship relationship : neo.getReferenceNode().getRelationships(new SimpleRelationshipType("HAS_USER"), Direction.OUTGOING)) {

        if (relationship.getEndNode().getProperty("username", "").equals("admin")) {

            admin = relationship.getEndNode();
            break;

        }

    }

    if (!request.getRequestURI().endsWith("organisationdetails.jsp") && organization.getProperty("name", "").equals("")) {

        response.sendRedirect("organisationdetails.jsp");

    }

%>