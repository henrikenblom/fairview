<%@page import="java.util.*"%>
<%@page import="java.text.*"%>
<%@ page import="org.springframework.web.servlet.support.RequestContext" %>
<%@ page import="org.springframework.security.core.context.SecurityContextHolder" %>
<%@ page import="org.springframework.security.core.userdetails.UserDetails" %>
<%@ page import="org.apache.lucene.search.Query" %>
<%@ page import="org.apache.lucene.search.TermQuery" %>
<%@ page import="org.apache.lucene.index.Term" %>
<%@page pageEncoding="UTF-8" %>
<%@taglib prefix="sec" uri="http://www.springframework.org/security/tags"%>
<html>
<head>
    <link type="text/css" href="formalizeme/css/formalize.css" rel="stylesheet"/>
    <script type="text/javascript" src="formalizeme/js/jquery.formalize.js"></script>
    <link type="text/css" href="css/jquery-ui/jquery-ui-override.css" rel="stylesheet"/>
</head>


<script type="text/javascript">

    function changeView(location) {

        setTimeout(function() {document.location.href = location}, 100);
        $('#modalizer').fadeIn(100);

    }

    jQuery.fn.center = function () {
        this.css("position","absolute");
        this.css("top", ( $(window).height() - this.height() - 300) / 2+$(window).scrollTop() + "px");
        this.css("left", ( $(window).width() - this.width() ) / 2+$(window).scrollLeft() + "px");
        return this;
    }

</script>

<div id="page-header">
    <img alt="Infero Quest" id="logo" src="images/logo.jpg">
    <div id="control-bar">
        <div id="button-bar">
                <%

                    String buttonStyle = "";

                    if (organization.getProperty("name", "").equals("")) {
                        buttonStyle = " style=\"display:none\"";
                    }

                    UserDetails principal = (UserDetails) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
                    Node currentUserNode = neoSearch.getNodes(new TermQuery(new Term("username", principal.getUsername()))).get(0);
                    String currentUserRealName = principal.getUsername();
                    String currentUserName = principal.getUsername();

                    try {

                        if (currentUserNode.getId() == admin.getId()) {

                            currentUserRealName = "Systemadministratör";

                        } else if (!currentUserNode.getProperty("firstname", "").equals("") && !currentUserNode.getProperty("lastname", "").equals("")) {

                            currentUserRealName = currentUserNode.getProperty("firstname") + " " + currentUserNode.getProperty("lastname");

                        }

                    } catch (Exception ex) {

                    }

                 %>

            <div <%= request.getRequestURI().endsWith("/index.jsp") ? "class=\"activetab top-button\"" : "class=\"inactivetab top-button\""%>  onclick="changeView('index.jsp')" name="navigate-home">Startsida</div>
            <sec:authorize ifAnyGranted="ROLE_ADMIN, ROLE_HR">
                <div <%= request.getRequestURI().endsWith("/organisationtree.jsp") ? "class=\"activetab top-button\"" : "class=\"inactivetab top-button\""%>  onclick="changeView('organisationtree.jsp')" name="organisation">Organisation</div>
            </sec:authorize>
            <div <%= request.getRequestURI().endsWith("/employees.jsp") ? "class=\"activetab top-button\"" : "class=\"inactivetab top-button\""%> onclick="changeView('employees.jsp')" name="persons">Personer</div>
            <div <%= request.getRequestURI().endsWith("/employments.jsp") ? "class=\"activetab top-button\"" : "class=\"inactivetab top-button\""%> onclick="changeView('employments.jsp')" name="company-functions">Anställningar</div>
            <div <%= request.getRequestURI().endsWith("/functions.jsp") ? "class=\"activetab top-button\"" : "class=\"inactivetab top-button\""%> onclick="changeView('functions.jsp')" name="functions">Funktioner</div>
            <div <%= request.getRequestURI().endsWith("/experience.jsp") ? "class=\"activetab top-button\"" : "class=\"inactivetab top-button\""%> onclick="changeView('experience.jsp')" name="experience">Kompetensprofil</div>
            <div <%= request.getRequestURI().endsWith("/search.jsp") ? "class=\"activetab top-button\"" : "class=\"inactivetab top-button\""%> onclick="changeView('search.jsp')" name="functions">S&ouml;k</div>

            <div class="inactivetab top-button" onclick="document.location.href = 'j_spring_security_logout'" name="logout"> Logga ut</div>

        </div>

        <div id="information-bar"><div id="header-organization-name"><%= currentUserRealName%> - <%=organization.getProperty("name", "Namnlös")%></div>&nbsp;-&nbsp;<%= DateFormat.getDateInstance(DateFormat.LONG, new Locale("sv", "SE")).format(new Date(System.currentTimeMillis()))%></div>

    </div>

</div>
</html>