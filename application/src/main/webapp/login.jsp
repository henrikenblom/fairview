<%@ page import="java.util.Date" %>
<%@ page import="java.util.Locale" %>
<%@ page import="java.text.DateFormat" %>
<%--
    Document   : index
    Created on : 2010-okt-28, 13:08:39
    Author     : henrik
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
    "http://www.w3.org/TR/html4/loose.dtd">

<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Infero Quest - Startsida</title>
        <link rel="stylesheet" href="css/newlook.css" type="text/css" media="screen" charset="utf-8" />
        <script type="text/javascript" src="js/plugins/jquery-1.4.4.min.js"></script>
        <script type="text/javascript">
            $(document).ready(function() {

                $('#j_username').focus();

            });
        </script>
    </head>
    <body>
        <div id="page-header">
    <img alt="Infero Quest" id="logo" src="images/logo.jpg">
    <div id="control-bar">
        <div id="information-bar">&nbsp;</div>
        <div id="button-bar">&nbsp;</div>
    </div>
</div>
        <div id="main">
            <div id="content">
                <div id="loginDialog" class="popup">
                <div class="popup-header">
                    <div class="popup-header-text">Inloggning</div>
                </div>
                <div class="list-body profile-list">
                    <form id="login" name="login" action="j_spring_security_check" method="post">
                        <input name="_id" type="hidden" id="newUserId"/>
                        <fieldset>
                            <div class="field-box"><div class="field-label-box">Användarnamn</div><div id="username-field-box" class="field-input-box"><input id="j_username" name="j_username" type="text" value="" minlength="4"/></div></div>
                            <br>
                            <div class="field-box"><div class="field-label-box">Lösenord</div><div id="password_field-box" class="field-input-box"><input id="j_password" name="j_password" type="password"/></div></div>
                            <br>
                            <div class="field-box"><div class="field-label-box"><input type="checkbox" name="_spring_security_remember_me"/>&nbsp;Kom ihåg mig</div></div>
                            <br>
                            <br>
                            <input  type="submit" name="submit" value="Logga in"/>
                        </fieldset>
                    </form>
                </div>
                <div id="login-footer" class="list-footer">&nbsp;</div>
    </div>


            </div>
            <%--
            <div id="right-column">
                <%@include file="WEB-INF/jspf/coworkerlist.jsp" %>

                <%@include file="WEB-INF/jspf/reportlist.jsp" %>
                <%@include file="WEB-INF/jspf/policydocumentlist.jsp" %>

            </div>
            --%>
        </div>

    </body>
</html>