<%--
  Created by IntelliJ IDEA.
  User: henrik
  Date: 2011-03-24
  Time: 14.53
  To change this template use File | Settings | File Templates.
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%@include file="WEB-INF/jspf/beanMapper.jsp" %>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
    "http://www.w3.org/TR/html4/loose.dtd">

<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Infero Quest - Systemanvändare</title>
        <link rel="stylesheet" href="css/newlook.css" type="text/css" media="screen" charset="utf-8" />
        <script type="text/javascript" src="js/jquery-1.4.4.min.js"></script>
        <script type="text/javascript" src="iq.js"></script>
        <script type="text/javascript" src="js/jquery-plugins/jquery.form.js"></script>
        <script type="text/javascript">

            var hasLogin = false;

            function grantAdmin(id) {

                $.getJSON("fairview/ajax/grant_admin.do", {_nodeId: id});

            }

            function revokeAdmin(id) {

                $.getJSON("fairview/ajax/revoke_admin.do", {_nodeId: id});

            }

            function handleAdminCheckBox() {

                if ($('#adminCheckBox').is(":checked")) {

                    grantAdmin($('#updateUserId').val());

                } else {

                    revokeAdmin($('#updateUserId').val());

                }

            }

            function updateCoworker(id, isSysadmin) {

                if (isSysadmin) {

                    //alert("sysadmin");

                } else {

                    $.getJSON("neo/ajax/get_node.do", {_nodeId: id}, function(userData) {

                        if (typeof(userData.node) == "undefined") {

                            document.location.href = "users.jsp";

                        }

                        var realName = "";

                        if (userData.node.properties.firstname.value.length > 0
                            || userData.node.properties.lastname.value.length > 0) {

                            realName = userData.node.properties.firstname.value + " " + userData.node.properties.lastname.value;

                        }

                        if (typeof(userData.node.properties.username) == "undefined" || userData.node.properties.username.value.length < 1) {

                            hasLogin = false;
                            $('#update_username-field-box').html('<input class="login-field" type="text" value="" autocomplete="off" onkeyup="validateUpdateUserForm()" name="username" class="text-field" id="update_username-field">');

                        } else {

                            hasLogin = true;
                            $('#update_username-field-box').html('<input name="username" type="hidden" value="' + userData.node.properties.username.value + '"/>' + userData.node.properties.username.value);
                            $('#name-box').text(realName);
                            $('#updateRoleUsername').val(userData.node.properties.username.value);

                        }

                        $('#update_password_confirm_1-field').val("");
                        $('#update_password_confirm_2-field').val("");
                        $('#update_credentials-footer').html("&nbsp;");
                        $('#updateUserId').val(id);
                        $('#updateRoleUserId').val(id);

                        $.getJSON("fairview/ajax/is_admin.do", {_nodeId: id}, function(data) {

                                $('#adminCheckBox').attr('checked', data.boolean);

                        });

                        $('#modalizer').fadeTo(200, 0.5, function() {

                            $('#updateUserDialog').show();

                            if (hasLogin) {

                                $('#update_password_confirm_1-field').focus();

                            } else {

                                $('#update_username-field').focus();

                            }

                        });

                    });

                }

            }

            function hideUpdateUserDialog(event) {

                 $('#updateUserDialog').hide();
                 $('#modalizer').fadeOut(200);

            }


        function validateUpdateUserForm() {

            if ($('#update_password_confirm_1-field').val().length > 0
                    && $('#update_password_confirm_1-field').val() == $('#update_password_confirm_2-field').val()) {

                $('#saveButtonBox').html('<button tabindex="3" id="saveButton" onclick="$(\'#update_credentials_form\').ajaxSubmit(function() { hideUpdateUserDialog(); document.location.reload(true);})">Spara</button>');

            } else {

                $('#saveButtonBox').html("&nbsp;");

            }

        }

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
                <div id="user-list" class="list-body">

                    <div class="list-entry">
                    <!--    <a href="javascript: updateCoworker(<%=admin.getId()%>, true)">    -->
                        <div class="unit-list-cell list-entry">Systemadministratör</div>
                        <div class="unit-list-cell"><%= admin.getProperty("username")%></div>
                    <!--    </a>      -->
                    </div>

                    <%

                        for (Node entry : personListGenerator.getSortedList(PersonListGenerator.ALPHABETICAL, false)) {

                            //Date creationDate = new Date((Long) entry.getProperty("TS_CREATED"));
                            //Date modificationDate = new Date((Long) entry.getProperty("TS_MODIFIED"));

                            %>

                            <div class="list-entry">
                                <a href="javascript: updateCoworker(<%=entry.getId()%>)">
                                    <div class="unit-list-cell list-entry"><%= entry.getProperty("lastname", "")%>, <%= entry.getProperty("firstname", "")%></div>
                                    <div class="unit-list-cell"><%= entry.getProperty("username", "&lt;saknar inloggning&gt;")%></div>
                                </a>
                            </div>

                            <%

                        }

                    %>

                    </div>
                <div id="user-footer" class="list-footer">
                    &nbsp;
                </div>

                <div id="modalizer">&nbsp;</div>

                <div id="updateUserDialog" class="popup" style="display: none">
                <div class="popup-header">
                    <div class="popup-header-text">Lösenord/behörighet <div id="name-box"></div></div><div class="popup-header-close-box"><a href="#" onclick="hideUpdateUserDialog(event)" class="close"><img src="images/close.gif"></a></div>
                </div>
                <div class="list-body profile-list" id="update_credentials-list">
                    <form id="update_credentials_form" action="neo/ajax/update_credentials.do" method="post">
                        <fieldset>
                        <input name="_id" type="hidden" id="updateUserId"/>
                        <input name="_type" type="hidden" value="node"/>
                        <input name="_strict" type="hidden" value="false"/>
                        <input name="_username" type="hidden" value="<%=currentUserName%>"/>
                        <input name="role:checkbox" type="hidden" value="ROLE_EMPLOYEE"/>
                        <div class="field-box"><div class="field-label-box">Användarnamn</div><div id="update_username-field-box" class="field-input-box"></div></div>
                        <br>
                        <div class="field-box"><div class="field-label-box">Lösenord</div><div id="update_password_confirm_1-field-box" class="field-input-box"><input tabindex="1" class="login-field" type="password" value="" autocomplete="off" onkeyup="validateUpdateUserForm()" name="password_confirm_1" class="text-field" id="update_password_confirm_1-field"></div></div>
                        <br>
                        <div class="field-box"><div class="field-label-box">Lösenord (bekräfta)</div><div id="update_password_confirm_2-field-box" class="field-input-box"><input tabindex="2" class="login-field" type="password" value="" autocomplete="off" onkeyup="validateUpdateUserForm()" name="password_confirm_2" class="text-field" id="update_password_confirm_2-field"></div></div>
                        <br>
                        </fieldset>
                    </form>
                    <sec:authorize ifAnyGranted="ROLE_ADMIN">
                        <div class="field-box"><div class="field-label-box">Behörighet</div>
                            <input type="checkbox" id="adminCheckBox" onchange="handleAdminCheckBox()"/> Systemadministratör
                        </div>
                    </sec:authorize>
                <br>
                    <div id="saveButtonBox">&nbsp;</div>
                </div>
                    <div id="update_credentials-footer" class="list-footer">&nbsp;</div>
            </div>
        </div>
        </div>

    </body>
</html>