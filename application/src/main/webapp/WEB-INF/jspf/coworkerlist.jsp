<%@page pageEncoding="UTF-8" %>
<%--<%@include file="/WEB-INF/jspf/beanMapper.jsp" %>   --%>
<script type="text/javascript" src="js/jquery-plugins/jquery.form-2.17.js"></script>
<script type="text/javascript">

    function addCoworker(event) {

        $.getJSON("neo/ajax/create_relationship.do", {_startNodeId:<%= neo.getReferenceNode().getId() %>, _type:"HAS_USER" }, function(dataUser) {
                    $.getJSON("neo/ajax/create_relationship.do", {_startNodeId:<%= organization.getId()%>, _endNodeId:dataUser.relationship.endNode, _type:"HAS_EMPLOYEE" }, function(dataEmployee) {
                        $.getJSON("neo/ajax/update_node.do", {_nodeId:dataEmployee.relationship.endNode, nodeClass:"employee", _preserve:"password" }, function(data) {

                            $('#newUserId').val(data.node.id);
                            $('#newUserDialog').show();
                            $('#username-field').focus();

                        });
                    });
                });
    }

    function abortNewUser(event) {

         $('#newUserDialog').hide();
         $.getJSON("neo/ajax/delete_node.do", {_nodeId:$('#newUserId').val()});

    }

    function validateNewUserForm() {

        if ($('#username-field').val().length > 0
                && $('#password_confirm_1-field').val().length > 0
                && $('#password_confirm_2-field').val().length > 0
                && $('#password_confirm_1-field').val() == $('#password_confirm_2-field').val()) {

            $('#credentials-footer').html('<a href="#" onclick="$(\'#credentials_form\').ajaxSubmit(function() { document.location = \'coworkerprofile.jsp?id=\' + $(\'#newUserId\').val(); })">Spara</a>');

        } else {

            $('#credentials-footer').html("&nbsp;");

        }

    }

</script>
<div class="header"><input type="text" class="text-field filter-field" onkeyup="coworkerTextFilter(event)" placeholder="Personer" id="coworker-text-filter"></div>
<div id="coworker-list" class="list-body">

    <%
        for (Relationship entry : organization.getRelationships(SimpleRelationshipType.withName("HAS_EMPLOYEE"), Direction.OUTGOING)) {

            try {

                String coworkerName = entry.getEndNode().getProperty("lastname") + ", " + entry.getEndNode().getProperty("firstname");
    %>

        <div class="list-entry coworker-list-entry"><a class="active" href="coworkerprofile.jsp?id=<%= entry.getEndNode().getId()%>"><%= coworkerName%></a></div>

    <%
            } catch (Exception ex) {

            }
        }
    %>

</div>
<div id="coworker-footer" class="list-footer">
    <a href="#" onclick="addCoworker(event)">Lägg till person</a>
</div>
<div id="newUserDialog" class="popup" style="display: none">
<div class="popup-header">
                    <div class="popup-header-text">Ny person</div><div class="popup-header-close-box"><a href="#" onclick="abortNewUser(event)" class="close"><img src="images/close.gif"></a></div>
                </div>
                <div class="list-body profile-list" id="credentials-list">
                    <form id="credentials_form" action="neo/ajax/update_credentials.do" method="post">
                        <input name="_id" type="hidden" id="newUserId"/>
                        <fieldset>
                            <div class="field-box"><div class="field-label-box">Användarnamn</div><div id="username-field-box" class="field-input-box"><input type="text" onkeyup="validateNewUserForm()" name="username" class="text-field" id="username-field"></div></div>
                            <br>
                            <div class="field-box"><div class="field-label-box">Lösenord</div><div id="password_confirm_1-field-box" class="field-input-box"><input type="password" onkeyup="validateNewUserForm()" name="password_confirm_1" class="text-field" id="password_confirm_1-field"></div></div>
                            <br>
                            <div class="field-box"><div class="field-label-box">Lösenord (bekräfta)</div><div id="password_confirm_2-field-box" class="field-input-box"><input type="password" onkeyup="validateNewUserForm()" name="password_confirm_2" class="text-field" id="password_confirm_2-field"></div></div>
                            <br>
                            <div class="field-box"><div class="field-label-box">Funktion</div>
                                <input type="checkbox" onchange="validateNewUserForm()" name="role:checkbox" value="ROLE_MANAGER" /> A
                                <input type="checkbox" onchange="validateNewUserForm()" name="role:checkbox" value="ROLE_HR" /> B
                                <input type="checkbox" onchange="validateNewUserForm()" name="role:checkbox" value="ROLE_EMPLOYEE" checked="true"/> C
                            </div>
                        </fieldset>
                    </form>
                </div>
                <div id="credentials-footer" class="list-footer">&nbsp;</div>
    </div>