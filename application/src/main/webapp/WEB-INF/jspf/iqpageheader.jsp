<%@page import="java.util.*"%>
<%@page import="java.text.*"%>
<%@ page import="org.springframework.web.servlet.support.RequestContext" %>
<%@ page import="org.springframework.security.context.SecurityContextHolder" %>
<%@ page import="org.springframework.security.userdetails.UserDetails" %>
<%@ page import="org.apache.lucene.search.Query" %>
<%@ page import="org.apache.lucene.search.TermQuery" %>
<%@ page import="org.apache.lucene.index.Term" %>
<%@page pageEncoding="UTF-8" %>
<%@taglib prefix="sec" uri="http://www.springframework.org/security/tags"%>

<script type="text/javascript">

    function changeView(location) {

        setTimeout(function() {document.location.href = location}, 200);
        $('#modalizer').fadeIn(200);

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

            <button <%=  request.getRequestURI().endsWith("/index.jsp") ? "disabled=\"true\"" : "" %> class="top-button" <%=buttonStyle%> onclick="changeView('index.jsp')" name="navigate-home">Startsida</button>
            <sec:authorize ifAnyGranted="ROLE_MANAGER">
                <button <%=  request.getRequestURI().endsWith("/organisationtree.jsp") ? "disabled=\"true\"" : "" %> class="top-button" <%=buttonStyle%> name="organisation"
                        onclick="changeView('organisationtree.jsp')">Organisation
                </button>
            </sec:authorize>
            <sec:authorize ifNotGranted="ROLE_MANAGER">
                <button <%=  request.getRequestURI().endsWith("/organisationinfo.jsp") ? "disabled=\"true\"" : "" %>class="top-button" <%=buttonStyle%> name="organisationinfo"
                        onclick="changeView('organisationinfo.jsp')">Organisation
                </button>
            </sec:authorize>
                <button <%=  request.getRequestURI().endsWith("/functionlist.jsp") ? "disabled=\"true\"" : "" %>class="top-button" <%=buttonStyle%> name="company-functions"
                        onclick="changeView('functionlist.jsp')">Anställningar
                </button>
                <button <%=  request.getRequestURI().endsWith("/employees.jsp") ? "disabled=\"true\"" : "" %>class="top-button" <%=buttonStyle%> name="persons"
                        onclick="changeView('employees.jsp')">Personer
                </button>
            <sec:authorize ifAnyGranted="ROLE_MANAGER">
                <button <%=  request.getRequestURI().endsWith("/users.jsp") ? "disabled=\"true\"" : "" %>class="top-button" <%=buttonStyle%> name="company-functions"
                        onclick="changeView('users.jsp')">Systemanvändare
                </button>
            </sec:authorize>
            <button class="top-button" onclick="document.location.href = 'j_spring_security_logout'" name="logout">Logga ut</button>

        </div>

        <div id="information-bar"><div id="header-organization-name"><%= currentUserRealName%> - <%=organization.getProperty("name", "Namnlös")%></div>&nbsp;-&nbsp;<%= DateFormat.getDateInstance(DateFormat.LONG, new Locale("sv", "SE")).format(new Date(System.currentTimeMillis()))%></div>

    </div>

</div>