<%--
   Document   : coworkerprofile
   Created on : 2010-nov-02, 16:45:39
   Author     : henrik
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%@include file="WEB-INF/jspf/beanMapper.jsp" %>

<%

    Node employee = neo.getNodeById(Long.decode((String) request.getParameter("id")));

    HashMap<Long, Long> belongsToUnits = new HashMap<Long, Long>();

    for (Relationship entry : employee.getRelationships(SimpleRelationshipType.withName("BELONGS_TO"), Direction.OUTGOING)) {

        belongsToUnits.put(entry.getEndNode().getId(),entry.getId());

    }

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
    "http://www.w3.org/TR/html4/loose.dtd">

<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Infero Quest - Medarbetare</title>
        <link rel="stylesheet" href="css/newlook.css" type="text/css" media="screen" charset="utf-8" />
        <script type="text/javascript" src="js/jquery-1.4.4.min.js"></script>
        <script type="text/javascript" src="js/jquery-plugins/jquery.form.js"></script>
        <script type="text/javascript" src="iq.js"></script>
        <script type="text/javascript">

            var belongsToUnits = {};

            <%

                for (Long key : belongsToUnits.keySet()) {

                    %>

                        belongsToUnits[<%=key%>] = <%=belongsToUnits.get(key)%>;

                    <%

                }

            %>

            function makeBirthdate(event) {

                var civic = $('#civic-field').val();

                if (civic.length > 6) {

                    $('#birthday-field').val(civic.substr(0,6));

                } else {

                    $('#birthday-field').val(civic);

                }

            }

            function translatePseudoCheckbox(event, form_name) {

                var checkbox = event.target.id.toString().replace("pseudo-", "");

                $('#' + checkbox + '-field').val(event.target.checked);

                if (checkbox == "authorization") {

                    if (event.target.checked) {

                        $('#authorization-amount-field').show();

                    } else {

                        $('#authorization-amount-field').hide();

                    }

                }

                $('#' + form_name).ajaxSubmit();

            }

            function assignToUnit() {

                $('#unit > option').each(function() {

                    var unitId = $(this).val();

                    if (!this.selected && belongsToUnits[unitId] > 0) {

                        $.getJSON("neo/ajax/delete_relationship.do", {_relationshipId:belongsToUnits[unitId]});

                    } else if (this.selected && !belongsToUnits[unitId] > 0) {

                        $.getJSON("neo/ajax/create_relationship.do", {_startNodeId:<%=employee.getId()%>, _type:"BELONGS_TO", _endNodeId:unitId }, function(data) {

                            belongsToUnits[unitId] = data.relationship.id;

                        });

                    }

                });

            }

            $(document).ready(function() {

                $('#modalizer').fadeOut(500);
                adjustViewPort();

            });

            function addEducation() {

                    $.getJSON("neo/ajax/create_relationship.do", {_startNodeId:<%=employee.getId()%>, _type:"HAS_EDUCATION" }, function(data) {

                            $('<div>\
                            <form id="educationForm' + data.relationship.endNode + '" action="neo/ajax/update_properties.do" method="post">\
                                <fieldset>\
                                    <input type="hidden" name="_id" value="' + data.relationship.endNode + '">\
                                    <input type="hidden" name="_type" value="node">\
                                    <input type="hidden" name="_strict" value="false">\
                                    <input type="hidden" name="_username" value="admin">\
                                    <div class="field-label-box">Benämning</div>\
                                    <div class="field-input-box"><input type="text" onchange="$(\'#educationForm' + data.relationship.endNode + '\').ajaxSubmit()" name="name" id="education-field' + data.relationship.endNode + '" value=""></div>\
                                    <div class="field-label-box">Utbildningsnivå</div>\
                                    <select onchange="$(\'#educationForm' + data.relationship.endNode + '\').ajaxSubmit()" name="level">\
                                        <option>Gymnasieskola eller motsvarande</option>\
                                        <option>Certifierad</option>\
                                        <option>Yrkesutbildad</option>\
                                        <option>Enstaka kurser</option>\
                                        <option>Övriga eftergymnasiala kurser</option>¶\
                                        <option>Kandidatexamen</option>\
                                        <option>Magister eller civilingenjörexamen</option>\
                                        <option>Licentiat eller doktorsexamen</option>\
                                        <option>Yrkeslicens</option>\
                                    </select>\
                                    <div class="field-label-box">Inriktning</div>\
                                    <div class="field-input-box"><input type="text" onchange="$(\'#educationForm' + data.relationship.endNode + '\').ajaxSubmit()" name="direction" id="education-direction-field' + data.relationship.endNode + '" value=""></div>\
                                    <div class="field-label-box">Omfattning</div>\
                                    <div class="field-input-box"><input type="text" onchange="$(\'#educationForm' + data.relationship.endNode + '\').ajaxSubmit()" name="scope" id="education-scope-field' + data.relationship.endNode + '" value=""></div>\
                                    <div class="field-label-box">Från och med</div>\
                                    <div class="field-input-box"><input type="text" onchange="$(\'#educationForm' + data.relationship.endNode + '\').ajaxSubmit()" name="from" id="education-from-field' + data.relationship.endNode + '" value=""></div>\
                                    <div class="field-label-box">Till och med</div>\
                                    <div class="field-input-box"><input type="text" onchange="$(\'#educationForm' + data.relationship.endNode + '\').ajaxSubmit()" name="to" id="education-to-field' + data.relationship.endNode + '" value=""></div>\
                                    <div class="field-label-box">Land</div>\
                                    <div class="field-input-box"><input type="text" onchange="$(\'#educationForm' + data.relationship.endNode + '\').ajaxSubmit()" name="country" id="education-country-field' + data.relationship.endNode + '" value="Sverige"></div>\
                                    <div class="field-label-box">Beskrivning</div>\
                                    <div class="field-input-box"><input type="text" onchange="$(\'#educationForm' + data.relationship.endNode + '\').ajaxSubmit()" name="description" id="education-description-field' + data.relationship.endNode + '" value=""></div>\
                                    <br>\
                                </fieldset>\
                            </form>\
                        </div>\
                        <br>').appendTo($('#education-list'));

                    });

            }

            function addCourse() {

                $.getJSON("neo/ajax/create_relationship.do", {_startNodeId:<%=employee.getId()%>, _type:"HAS_COURSE" }, function(data) {

                    $('<div>\
                        <div class="field-label-box">Kurs</div>\
                        <form id="courseForm' + data.relationship.endNode + '" action="neo/ajax/update_properties.do" method="post">\
                            <fieldset>\
                                <input type="hidden" name="_id" value="' + data.relationship.endNode + '">\
                                <input type="hidden" name="_type" value="node">\
                                <input type="hidden" name="_strict" value="false">\
                                <input type="hidden" name="_username" value="admin">\
                                <div class="field-label-box">Benämning</div>\
                                <div class="field-input-box"><input type="text" onchange="$(\'#courseForm' + data.relationship.endNode + '\').ajaxSubmit()" name="name" id="course-field' + data.relationship.endNode + '" value=""></div>\
                                <div class="field-label-box">Från och med</div>\
                                <div class="field-input-box"><input type="text" onchange="$(\'#courseForm' + data.relationship.endNode + '\').ajaxSubmit()" name="from" id="course-from-field' + data.relationship.endNode + '" value=""></div>\
                                <div class="field-label-box">Till och med</div>\
                                <div class="field-input-box"><input type="text" onchange="$(\'#courseForm' + data.relationship.endNode + '\').ajaxSubmit()" name="to" id="course-to-field' + data.relationship.endNode + '" value=""></div>\
                                <div class="field-label-box">Beskrivning</div>\
                                <div class="field-input-box"><input type="text" onchange="$(\'#courseForm' + data.relationship.endNode + '\').ajaxSubmit()" name="description" id="course-description-field' + data.relationship.endNode + '" value=""></div>\
                                <br>\
                            </fieldset>\
                        </form>\
                    </div>\
                    <br>').appendTo($('#course-list'));

                });

            }

            function addLanguage() {

                $.getJSON("neo/ajax/create_relationship.do", {_startNodeId:<%=employee.getId()%>, _type:"HAS_LANGUAGESKILL" }, function(data) {

                    $('<div>\
                        <form id="languageForm' + data.relationship.endNode + '" action="neo/ajax/update_properties.do" method="post">\
                            <fieldset>\
                                <input type="hidden" name="_id" value="' + data.relationship.endNode + '">\
                                <input type="hidden" name="_type" value="node">\
                                <input type="hidden" name="_strict" value="false">\
                                <input type="hidden" name="_username" value="admin">\
                                <div class="field-label-box">Språk</div>\
                                <div class="field-input-box"><input type="text" onchange="$(\'#languageForm' + data.relationship.endNode + '\').ajaxSubmit()" name="language" id="language-field' + data.relationship.endNode + '" value=""></div>\
                                <div class="field-label-box">Kunskapsnivå - skriftlig</div>\
                                <select name="written" onchange="$(\'#languageForm' + data.relationship.endNode + '\').ajaxSubmit()" id="written-field' + data.relationship.endNode + '">\
                                    <option>Viss</option>\
                                    <option>God</option>\
                                    <option>Avancerad</option>\
                                </select>\
                                <div class="field-label-box">Kunskapsnivå - muntlig</div>\
                                <select name="spoken" onchange="$(\'#languageForm' + data.relationship.endNode + '\').ajaxSubmit()" id="spoken-field' + data.relationship.endNode + '">\
                                    <option>Viss</option>\
                                    <option>God</option>\
                                    <option>Avancerad</option>\
                                </select>\
                                <br>\
                            </fieldset>\
                        </form>\
                    </div>\
                    <br>').appendTo($('#language-list'));

                });

            }

        function addWorkExperience() {

            $.getJSON("neo/ajax/create_relationship.do", {_startNodeId:<%=employee.getId()%>, _type:"HAS_WORK_EXPERIENCE" }, function(data) {

                $('<div>\
                    <form id="workexperienceForm' + data.relationship.endNode + '" action="neo/ajax/update_properties.do" method="post">\
                        <fieldset>\
                            <input type="hidden" name="_id" value="' + data.relationship.endNode + '">\
                            <input type="hidden" name="_type" value="node">\
                            <input type="hidden" name="_strict" value="false">\
                            <input type="hidden" name="_username" value="admin">\
                            <div class="field-label-box">Tidigare befattning</div>\
                            <div class="field-input-box"><input type="text" onchange="$(\'#workexperienceForm' + data.relationship.endNode + '\').ajaxSubmit()" name="name" id="name-field' + data.relationship.endNode + '" value=""></div>\
                            <div class="field-label-box">Företag</div>\
                            <div class="field-input-box"><input type="text" onchange="$(\'#workexperienceForm' + data.relationship.endNode + '\').ajaxSubmit()" name="company" id="company-field' + data.relationship.endNode + '" value=""></div>\
                            <div class="field-label-box">Bransch</div>\
                            <div class="field-input-box"><input type="text" onchange="$(\'#workexperienceForm' + data.relationship.endNode + '\').ajaxSubmit()" name="trade" id="trade-field' + data.relationship.endNode + '" value=""></div>\
                            <div class="field-label-box">Land</div>\
                            <div class="field-input-box"><input type="text" onchange="$(\'#workexperienceForm' + data.relationship.endNode + '\').ajaxSubmit()" name="country" id="country-field' + data.relationship.endNode + '" value="Sverige"></div>\
                            <div class="field-label-box">Från och med</div>\
                            <div class="field-input-box"><input type="text" onchange="$(\'#workexperienceForm' + data.relationship.endNode + '\').ajaxSubmit()" name="from" id="from-field' + data.relationship.endNode + '" value=""></div>\
                            <div class="field-label-box">Till och med</div>\
                            <div class="field-input-box"><input type="text" onchange="$(\'#workexperienceForm' + data.relationship.endNode + '\').ajaxSubmit()" name="to" id="to-field' + data.relationship.endNode + '" value=""></div>\
                            <div class="field-label-box">Uppgifter</div>\
                            <div class="field-input-box"><textarea onchange="$(\'#workexperienceForm' + data.relationship.endNode + '\').ajaxSubmit()" name="assignments" id="assignments-field' + data.relationship.endNode + '"></textarea></div>\
                            <br>\
                        </fieldset>\
                    </form>\
                </div>\
                <br>').appendTo($('#workexperience-list'));

            });

        }

        </script>
    </head>
    <body onload="onload(<%= organization.getId()%>)" onresize="adjustViewPort();">
        <%@include file="WEB-INF/jspf/iqpageheader.jsp" %>
        <div id="main">
            <div id="content">
                <form id="profile_form" action="neo/ajax/update_properties.do" method="post">
                        <fieldset>
                <div class="header text-header">
                    Anställningsuppgifter<div class="expand-contract"><img onclick="toggleExpand(event)" id="profile-expand" src="images/contract.png"></div>
                </div>
                <div class="list-body profile-list" id="profile-list">
                    
                            <input name="_id" type="hidden" value="<%= employee.getId()%>"/>
                            <input name="_type" type="hidden" value="node"/>
                            <input name="_strict" type="hidden" value="false"/>
                            <input name="_username" type="hidden" value="admin"/>
                            <input type="hidden" name="birthday" id="birthday-field" value="<%=employee.getProperty("birthday", "")%>">

                    <input type="hidden" id="authorization-field" name="authorization" value="<%=employee.getProperty("authorization", "false")%>">
                    <input type="hidden" id="executive-field" name="executive" value="<%=employee.getProperty("executive", "false")%>">
                    <input type="hidden" id="budget-responsibility-field" name="budget-responsibility" value="<%=employee.getProperty("budget-responsibility", "false")%>">
                    <input type="hidden" id="own-result-responsibility-field" name="own-result-responsibility" value="<%=employee.getProperty("own-result-responsibility", "false")%>">

                    <div class="field-box"><div class="field-label-box">Förnamn</div><div id="firstname-field-box" class="field-input-box"><input type="text" onchange="$('#profile_form').ajaxSubmit()" name="firstname" class="text-field" id="firstname-field" value="<%=employee.getProperty("firstname", "")%>"></div></div>
                    <br>
                    <div class="field-box"><div class="field-label-box">Efternamn</div><div id="lastname-field-box" class="field-input-box"><input type="text" onchange="$('#profile_form').ajaxSubmit()" name="lastname" class="text-field" id="lastname-field" value="<%=employee.getProperty("lastname", "")%>"></div></div>
                    <br>
                    <div class="field-box"><div class="field-label-box">Kön</div><div id="gender-field-box" class="field-input-box"><select name="gender" onchange="$('#profile_form').ajaxSubmit()">
                        <% if (employee.getProperty("gender", "").equals("")) {%><option>Välj...</option> <% } %>
                        <option value="M" <% if (employee.getProperty("gender", "").equals("M")) { %>selected="true"<% } %>>Man</option>
                        <option value="F" <% if (employee.getProperty("gender", "").equals("F")) { %>selected="true"<% } %>>Kvinna</option>
                    </select></div></div>
                    <br>
                    <div class="field-box"><div class="field-label-box">Nationalitet</div><div id="nationality-field-box" class="field-input-box"><input type="text" onchange="$('#profile_form').ajaxSubmit()" name="nationality" class="text-field" id="nationality-field" value="<%=employee.getProperty("nationality", "Svensk")%>"></div></div>
                    <br>
                    <div class="field-box"><div class="field-label-box">Anställningsnummer</div><div id="employmentid-field-box" class="field-input-box"><input type="text" onchange="$('#profile_form').ajaxSubmit()" name="employmentid" class="text-field" id="employmentid-field"  value="<%=employee.getProperty("employmentid", "")%>"></div></div>
                    <br>
                    <div class="field-box"><div class="field-label-box">Personnummer</div><div id="civic-field-box" class="field-input-box"><input type="text" onkeyup="makeBirthdate(event)" onchange="$('#profile_form').ajaxSubmit()" name="civic" class="text-field" id="civic-field" value="<%=employee.getProperty("civic", "")%>"></div></div>
                    <br>
                    <div class="field-box"><div class="field-label-box">Adress</div><div id="address-field-box" class="field-input-box"><input type="text" onchange="$('#profile_form').ajaxSubmit()" name="address" class="text-field" id="address-field" value="<%=employee.getProperty("address", "")%>"></div></div>
                    <br>
                    <div class="field-box"><div class="field-label-box">Postnummer</div><div id="zip-field-box" class="field-input-box"><input type="text" onchange="$('#profile_form').ajaxSubmit()" name="zip" class="text-field digits-6" id="zip-field" value="<%=employee.getProperty("zip", "")%>"></div></div>
                    <br>
                    <div class="field-box"><div class="field-label-box">Postort</div><div id="city-field-box" class="field-input-box"><input type="text" onchange="$('#profile_form').ajaxSubmit()" name="city" class="text-field" id="city-field" <%=employee.getProperty("city", "").equals("") ? "" : "value=\"" + employee.getProperty("city") + "\""%>></div></div>
                    <br>
                    <div class="field-box"><div class="field-label-box">Land</div><div id="country-field-box" class="field-input-box"><input type="text" onchange="$('#profile_form').ajaxSubmit()" name="country" class="text-field" id="country-field" value="<%=employee.getProperty("country", "Sverige")%>"></div></div>
                    <br>
                    <div class="field-box"><div class="field-label-box">Telefon</div><div class="field-input-box"><div id="phone-field-box" class="field-input-box"><input type="text" onchange="$('#profile_form').ajaxSubmit()" name="phone" class="text-field" id="phone-field" value="<%=employee.getProperty("phone", "")%>"></div></div></div>
                    <br>
                    <div class="field-box"><div class="field-label-box">Mobiltelefon</div><div class="field-input-box"><div id="cell-field-box" class="field-input-box"><input type="text" onchange="$('#profile_form').ajaxSubmit()" name="cell" class="text-field" id="cell-field" value="<%=employee.getProperty("cell", "")%>"></div></div></div>
                    <br>
                    <div class="field-box"><div class="field-label-box">E-post</div><div class="field-input-box"><div id="email-field-box" class="field-input-box"><input type="text" onchange="$('#profile_form').ajaxSubmit()" name="email" class="text-field" id="email-field" value="<%=employee.getProperty("email", "")%>"></div></div></div>
                    <br>
                    <div class="field-box"><div class="field-label-box">Funktion</div><div class="field-preview">
                        <select name="function" onchange="functionAssignedToEmployee(event, <%=employee.getId()%>)" id="function-field">
                            <option>Välj...</option>
                        <%
                            for (Node function : functionListGenerator.getSortedList(FunctionListGenerator.ALPHABETICAL, false)) {

                                try {

                                    String functionName = (String) function.getProperty("name");
                                    String selected = "";

                                    try {

                                        Traverser employmentTraverser = function.traverse(Traverser.Order.BREADTH_FIRST, StopEvaluator.END_OF_GRAPH, ReturnableEvaluator.ALL_BUT_START_NODE, SimpleRelationshipType.withName("PERFORMS_FUNCTION"), Direction.INCOMING);
                                        Traverser employeeTraverser = employmentTraverser.iterator().next().traverse(Traverser.Order.BREADTH_FIRST, StopEvaluator.END_OF_GRAPH, ReturnableEvaluator.ALL_BUT_START_NODE, SimpleRelationshipType.withName("HAS_EMPLOYMENT"), Direction.INCOMING);

                                        if (employeeTraverser.iterator().next().getId() == employee.getId()) {

                                            selected = "selected=\"true\"";

                                        }

                                    } catch (Exception ex) {

                                    }

                        %>
                        <option value="<%=function.getId()%>" <%=selected%>><%=functionName%></option>

                            <% } catch (Exception ex) {

                                }
                                }
                                %>
                        </select>
                    </div></div>
                    <br>
                    <div class="field-box"><div class="field-label-box">Från datum</div><div class="field-input-box"><div id="fromdate-field-box" class="field-input-box"><input type="text" onchange="$('#profile_form').ajaxSubmit()" name="fromdate" class="text-field" id="fromdate-field" value="<%=employee.getProperty("fromdate", "")%>"></div></div></div>
                    <br>
                    <div class="field-box"><div class="field-label-box">Till datum</div><div class="field-input-box"><div id="todate-field-box" class="field-input-box"><input type="text" onchange="$('#profile_form').ajaxSubmit()" name="todate" class="text-field" id="todate-field" value="<%=employee.getProperty("todate", "")%>"></div></div></div>
                    <br>
                    <div class="field-box"><div class="field-label-box">Anställningsform</div>
                        <div class="field-input-box">
                            <div id="employment-field-box" class="field-input-box">
                                <select onchange="$('#profile_form').ajaxSubmit()" name="employment" id="employment-field">
                                    <option>Välj...</option>
                                    <option value="Tills vidare" <%=(employee.getProperty("employment", "").equals("Tills vidare")) ? "selected=\"true\"" : ""%>>Tills vidare</option>
                                    <option value="Provanställning" <%=(employee.getProperty("employment", "").equals("Provanställning")) ? "selected=\"true\"" : ""%>>Provanställning</option>
                                    <option value="Visstidsanställning" <%=(employee.getProperty("employment", "").equals("Visstidsanställning")) ? "selected=\"true\"" : ""%>>Visstidsanställning</option>
                                    <option value="Projektanställning" <%=(employee.getProperty("employment", "").equals("Projektanställning")) ? "selected=\"true\"" : ""%>>Projektanställning</option>
                                    <option value="Säsongsanställning" <%=(employee.getProperty("employment", "").equals("Säsongsanställning")) ? "selected=\"true\"" : ""%>>Säsongsanställning</option>
                                    <option value="Timanställning" <%=(employee.getProperty("employment", "").equals("Timanställning")) ? "selected=\"true\"" : ""%>>Timanställning</option>
                                </select>
                            </div>
                        </div>
                    </div>
                    <br>
                    <div class="field-box"><div class="field-label-box">Övrigt</div>
                        <div class="field-input-box"><textarea onchange="$('#profile_form').ajaxSubmit()" name="additional_info" id="additional_info-field"><%=employee.getProperty("additional_info", "")%></textarea></div>
                    </div>
                    <br>
                    <br>
                </div>

                <div id="profile-footer" class="list-footer">&nbsp;</div>

                <div class="header text-header">
                    Arbetsbeskrivning<div class="expand-contract"><img onclick="toggleExpand(event)" id="responsibility-expand" src="images/contract.png"></div>
                </div>
                <div class="list-body profile-list" id="responsibility-list">
                <div class="field-box"><div class="field-label-box">Arbetstider</div><div class="workhours-input-box"><div id="workhours-field-box" class="field-input-box"><input type="text" onchange="$('#profile_form').ajaxSubmit()" name="workhours" class="text-field" id="workhours-field" value="<%=employee.getProperty("workhours", "")%>"></div></div></div>
                <br>
                    <div class="field-box">
                        <div class="field-label-box">Ansvar/Befogenheter</div>
                        <div class="field-input-box"><input type="checkbox" <%=(employee.getProperty("executive", "").equals("true")) ? "checked=\"true\"" : ""%> id="pseudo-executive" onchange="translatePseudoCheckbox(event, 'profile_form')"> Ledningsgrupp</div>
                        <div class="field-input-box"><input type="checkbox" <%=(employee.getProperty("budget-responsibility", "").equals("true")) ? "checked=\"true\"" : ""%> id="pseudo-budget-responsibility" onchange="translatePseudoCheckbox(event, 'profile_form')"> Budgetansvar</div>
                        <div class="field-input-box"><input type="checkbox" <%=(employee.getProperty("own-result-responsibility", "").equals("true")) ? "checked=\"true\"" : ""%> id="pseudo-own-result-responsibility" onchange="translatePseudoCheckbox(event, 'profile_form')"> Eget resultatansvar</div>
                        <div class="field-input-box"><input type="checkbox" <%=(employee.getProperty("authorization", "").equals("true")) ? "checked=\"true\"" : ""%> id="pseudo-authorization" onchange="translatePseudoCheckbox(event, 'profile_form')"> Attesträtt</div>
                    </div>
                    <br>
                    <div class="field-box" id="authorization-amount-box" <%= (employee.getProperty("authorization", "")).equals("true") ? "" : "style=\"display:none\""%>>
                        <div class="field-label-box">Attesträtt belopp</div>
                        <div class="field-input-box"><input type="text" onchange="$('#profile_form').ajaxSubmit()" name="authorization-amount" class="text-field digits-6" id="authorization-amount-field" value="<%=employee.getProperty("authorization-amount", "")%>"> kr</div>
                    </div>
                    <br>
                    <div class="field-box">
                        <div class="field-label-box">Löneform</div>
                        <div class="field-input-box">
                            <select onchange="$('#profile_form').ajaxSubmit()" name="payment-form" id="payment-form-field">
                                    <option>Välj...</option>
                                    <option value="Månadslön" <%=(employee.getProperty("payment-form", "").equals("Månadslön")) ? "selected=\"true\"" : ""%>>Månadslön</option>
                                    <option value="Tvåveckorslön" <%=(employee.getProperty("payment-form", "").equals("Tvåveckorslön")) ? "selected=\"true\"" : ""%>>Tvåveckorslön</option>
                                    <option value="Veckolön" <%=(employee.getProperty("payment-form", "").equals("Veckolön")) ? "selected=\"true\"" : ""%>>Veckolön</option>
                                    <option value="Timlön" <%=(employee.getProperty("payment-form", "").equals("Timlön")) ? "selected=\"true\"" : ""%>>Timlön</option>
                                </select>
                        </div>
                    </div>
                    <br>
                    <div class="field-box">
                        <div class="field-label-box">Aktuell lön</div>
                        <div class="field-input-box"><input type="text" onchange="$('#profile_form').ajaxSubmit()" name="salary" class="text-field digits-6" id="salary-field" value="<%=employee.getProperty("salary", "")%>"> kr</div>
                    </div>
                    <br>
                    <div class="field-box">
                        <div class="field-label-box">Övertidsersättning</div>
                        <div class="field-input-box">
                            <input type="radio" <%=(employee.getProperty("overtime-compensation", "").equals("true")) ? "checked=\"true\"" : ""%> onchange="$('#profile_form').ajaxSubmit()" name="overtime-compensation" value="true"> Ja
                            <input type="radio" <%=(employee.getProperty("overtime-compensation", "").equals("false")) ? "checked=\"true\"" : ""%> onchange="$('#profile_form').ajaxSubmit()" name="overtime-compensation" value="false"> Nej
                        </div>
                    </div>
                    <br>
                    <div class="field-box">
                        <div class="field-label-box">Reseersättning</div>
                        <div class="field-input-box">
                            <input type="radio" <%=(employee.getProperty("travel-compensation", "").equals("true")) ? "checked=\"true\"" : ""%> onchange="$('#profile_form').ajaxSubmit()" name="travel-compensation" value="true"> Ja
                            <input type="radio" <%=(employee.getProperty("travel-compensation", "").equals("false")) ? "checked=\"true\"" : ""%> onchange="$('#profile_form').ajaxSubmit()" name="travel-compensation" value="false"> Nej
                        </div>
                    </div>
                    <br>
                    <div class="field-box">
                        <div class="field-label-box">Semesterrätt</div>
                        <div class="field-input-box"><input type="text" onchange="$('#profile_form').ajaxSubmit()" name="vaication-days" class="text-field" id="vaication-days-field" value="<%=employee.getProperty("vaication-days", "")%>"></div>
                    </div>
                    <br>
                    <div class="field-box"><div class="field-label-box">Uppsägningstid (anställd)</div>
                        <div>
                            <div id="dismissal-period-employee-field-box" class="field-input-box">
                                <select onchange="$('#profile_form').ajaxSubmit()" name="dismissal-period-employee" id="dismissal-period-employee-field">
                                    <option>Välj...</option>
                                    <%
                                        for (int i = 1; i < 13; i++) { %>

                                        <option value="<%=i%>" <%=(String.valueOf(i).equals((String) employee.getProperty("dismissal-period-employee", "0"))) ? "selected=\"true\"" : ""%>><%=i%> månad<%=(i > 1) ? "er" : ""%></option>

                                    <% } %>
                                </select>
                            </div>
                        </div>
                    </div>
                    <br>
                    <div class="field-box"><div class="field-label-box">Uppsägningstid (arbetsgivare)</div>
                        <div>
                            <div id="dismissal-period-employer-field-box" class="field-input-box">
                                <select onchange="$('#profile_form').ajaxSubmit()" name="dismissal-period-employer" id="dismissal-period-employer-field">
                                    <option value="0">Välj...</option>
                                    <%
                                        for (int i = 1; i < 13; i++) { %>

                                        <option value="<%=i%>" <%=(String.valueOf(i).equals((String) employee.getProperty("dismissal-period-employer", "0"))) ? "selected=\"true\"" : ""%>><%=i%> månad<%=(i > 1) ? "er" : ""%></option>

                                    <% } %>
                                </select>
                            </div>
                        </div>
                    </div>
                    <br>
                    <br>
                    <div class="field-box">
                        <div class="field-label-box">Tjänstebil</div>
                        <div class="field-input-box"><input type="text" onchange="$('#profile_form').ajaxSubmit()" name="company-car" class="text-field" id="company-car-field" value="<%=employee.getProperty("company-car", "")%>"></div>
                    </div>
                    <br>
                    <div class="field-box">
                        <div class="field-label-box">Pension och försäkringar</div>
                        <div class="field-input-box"><input type="text" onchange="$('#profile_form').ajaxSubmit()" name="pension-insurances" class="text-field" id="pension-insurances-field" value="<%=employee.getProperty("pension-insurances", "")%>"></div>
                    </div>
                    <br>
                    <br>
                    <div class="field-box"><div class="field-label-box">Ansvarsområden</div>
                        <div class="field-input-box"><textarea onchange="$('#profile_form').ajaxSubmit()" name="responsibilities" id="responsibilities-field"><%=employee.getProperty("responsibilities", "")%></textarea></div>
                    </div>
                    <br>
                   <div class="field-box"><div class="field-label-box">Arbetsuppgifter</div>
                        <div class="field-input-box"><textarea onchange="$('#profile_form').ajaxSubmit()" name="tasks" id="tasks-field"><%=employee.getProperty("tasks", "")%></textarea></div>
                    </div>
                    <br>
                    <br>
                </div>
                <div id="responsibility-footer" class="list-footer">&nbsp;</div>
                        </fieldset>
                 </form>
                <div class="header text-header">
                    Kompetens<div class="expand-contract"><img onclick="toggleExpand(event)" id="competence-expand" src="images/contract.png"></div>
                </div>
                <div class="list-body profile-list" id="competence-list">
                <form id="driversLicenseForm" action="neo/ajax/update_properties.do" method="post">
                                <fieldset>
                                    <input type="hidden" name="_id" value="<%=employee.getId()%>">
                                    <input type="hidden" name="_type" value="node">
                                    <input type="hidden" name="_strict" value="false">
                                    <input type="hidden" name="_username" value="admin">
                                    <input type="hidden" id="dl_a1-field" name="dl_a1" value="<%=employee.getProperty("dl_a1", "false")%>">
                                    <input type="hidden" id="dl_a-field" name="dl_a" value="<%=employee.getProperty("dl_a", "false")%>">
                                    <input type="hidden" id="dl_b-field" name="dl_b" value="<%=employee.getProperty("dl_b", "false")%>">
                                    <input type="hidden" id="dl_c-field" name="dl_c" value="<%=employee.getProperty("dl_c", "false")%>">
                                    <input type="hidden" id="dl_d-field" name="dl_d" value="<%=employee.getProperty("dl_d", "false")%>">
                                    <input type="hidden" id="dl_be-field" name="dl_be" value="<%=employee.getProperty("dl_be", "false")%>">
                                    <input type="hidden" id="dl_ce-field" name="dl_ce" value="<%=employee.getProperty("dl_ce", "false")%>">
                                    <input type="hidden" id="dl_de-field" name="dl_de" value="<%=employee.getProperty("dl_de", "false")%>">
                                    <br>
                                    <div class="field-box">
                                        <div class="field-label-box">Körkortsbehörighet</div>
                                        <div class="field-input-box"><input type="checkbox" <%=(employee.getProperty("dl_a1", "").equals("true")) ? "checked=\"true\"" : ""%> id="pseudo-dl_a1" onchange="translatePseudoCheckbox(event, 'driversLicenseForm')"> A1</div>
                                        <div class="field-input-box"><input type="checkbox" <%=(employee.getProperty("dl_a", "").equals("true")) ? "checked=\"true\"" : ""%> id="pseudo-dl_a" onchange="translatePseudoCheckbox(event,'driversLicenseForm')"> A</div>
                                        <div class="field-input-box"><input type="checkbox" <%=(employee.getProperty("dl_b", "").equals("true")) ? "checked=\"true\"" : ""%> id="pseudo-dl_b" onchange="translatePseudoCheckbox(event, 'driversLicenseForm')"> B</div>
                                        <div class="field-input-box"><input type="checkbox" <%=(employee.getProperty("dl_c", "").equals("true")) ? "checked=\"true\"" : ""%> id="pseudo-dl_c" onchange="translatePseudoCheckbox(event, 'driversLicenseForm')"> C</div>
                                        <div class="field-input-box"><input type="checkbox" <%=(employee.getProperty("dl_d", "").equals("true")) ? "checked=\"true\"" : ""%> id="pseudo-dl_d" onchange="translatePseudoCheckbox(event, 'driversLicenseForm')"> D</div>
                                        <div class="field-input-box"><input type="checkbox" <%=(employee.getProperty("dl_be", "").equals("true")) ? "checked=\"true\"" : ""%> id="pseudo-dl_be" onchange="translatePseudoCheckbox(event, 'driversLicenseForm')"> BE</div>
                                        <div class="field-input-box"><input type="checkbox" <%=(employee.getProperty("dl_ce", "").equals("true")) ? "checked=\"true\"" : ""%> id="pseudo-dl_ce" onchange="translatePseudoCheckbox(event, 'driversLicenseForm')"> CE</div>
                                        <div class="field-input-box"><input type="checkbox" <%=(employee.getProperty("dl_de", "").equals("true")) ? "checked=\"true\"" : ""%> id="pseudo-dl_de" onchange="translatePseudoCheckbox(event, 'driversLicenseForm')"> DE</div>
                                    </div>
                                    <br>
                                    </fieldset>
                                </form>
                    <div id="education-list" class="field-box">

                        <%

                            int educationCount = 0;

                                for (Relationship entry : employee.getRelationships(SimpleRelationshipType.withName("HAS_EDUCATION"), Direction.OUTGOING)) {

                                    //if (!entry.getEndNode().getProperty("name", "").equals("")) {

                                        educationCount++;
                                        long id = entry.getEndNode().getId();

                                    %>

                        <div>
                            <form id="educationForm<%= id%>" action="neo/ajax/update_properties.do" method="post">
                                <fieldset>
                                    <input type="hidden" name="_id" value="<%= id%>">
                                    <input type="hidden" name="_type" value="node">
                                    <input type="hidden" name="_strict" value="false">
                                    <input type="hidden" name="_username" value="admin">
                                    <div class="field-label-box">Benämning</div>
                                    <div class="field-input-box"><input type="text" onchange="$('#educationForm<%= id%>').ajaxSubmit()" name="name" id="education-field<%= id%>" value="<%=entry.getEndNode().getProperty("name", "")%>"></div>
                                    <div class="field-label-box">Utbildningsnivå</div>
                                    <select onchange="$('#educationForm<%= id%>').ajaxSubmit()" name="level">
                                        <option>Gymnasieskola eller motsvarande</option>
                                        <option>Certifierad</option>
                                        <option>Yrkesutbildad</option>
                                        <option>Enstaka kurser</option>
                                        <option>Övriga eftergymnasiala kurser</option>
                                        <option>Kandidatexamen</option>
                                        <option>Magister eller civilingenjörexamen</option>
                                        <option>Licentiat eller doktorsexamen</option>
                                        <option>Yrkeslicens</option>
                                    </select>
                                    <div class="field-label-box">Inriktning</div>
                                    <div class="field-input-box"><input type="text" onchange="$('#educationForm<%= id%>').ajaxSubmit()" name="direction" id="education-direction-field<%= id%>" value="<%=entry.getEndNode().getProperty("direction", "")%>"></div>
                                    <div class="field-label-box">Omfattning</div>
                                    <div class="field-input-box"><input type="text" onchange="$('#educationForm<%= id%>').ajaxSubmit()" name="scope" id="education-scope-field<%= id%>" value="<%=entry.getEndNode().getProperty("scope", "")%>"></div>
                                    <div class="field-label-box">Från och med</div>
                                    <div class="field-input-box"><input type="text" onchange="$('#educationForm<%= id%>').ajaxSubmit()" name="from" id="education-from-field<%= id%>" value="<%=entry.getEndNode().getProperty("from", "")%>"></div>
                                    <div class="field-label-box">Till och med</div>
                                    <div class="field-input-box"><input type="text" onchange="$('#educationForm<%= id%>').ajaxSubmit()" name="to" id="education-to-field<%= id%>" value="<%=entry.getEndNode().getProperty("to", "")%>"></div>
                                    <div class="field-label-box">Land</div>
                                    <div class="field-input-box"><input type="text" onchange="$('#educationForm<%= id%>').ajaxSubmit()" name="country" id="education-country-field<%= id%>" value="<%=entry.getEndNode().getProperty("country", "Sverige")%>"></div>
                                    <div class="field-label-box">Beskrivning</div>
                                    <div class="field-input-box"><input type="text" onchange="$('#educationForm<%= id%>').ajaxSubmit()" name="description" id="education-description-field<%= id%>" value="<%=entry.getEndNode().getProperty("description", "")%>"></div>
                                    <br>
                                </fieldset>
                            </form>
                        </div>
                        <br>

                                    <%
                                            //}

                                        }

                                        if (educationCount == 0) {


                                        Transaction tx = neo.beginTx();
                                        Node education = null;

                                        try {

                                            education = neo.createNode();

                                            long id = education.getId();

                                            education.setProperty("nodeClass", "education");

                                            employee.createRelationshipTo(education, SimpleRelationshipType.withName("HAS_EDUCATION"));

                                            tx.success();


                                        %>

                        <div>
                            <form id="educationForm<%= id%>" action="neo/ajax/update_properties.do" method="post">
                                <fieldset>
                                    <input type="hidden" name="_id" value="<%= id%>">
                                    <input type="hidden" name="_type" value="node">
                                    <input type="hidden" name="_strict" value="false">
                                    <input type="hidden" name="_username" value="admin">
                                    <div class="field-label-box">Benämning</div>
                                    <div class="field-input-box"><input type="text" onchange="$('#educationForm<%= id%>').ajaxSubmit()" name="name" id="education-field<%= id%>" value=""></div>
                                    <div class="field-label-box">Utbildningsnivå</div>
                                    <select onchange="$('#educationForm<%= id%>').ajaxSubmit()" name="level">
                                        <option>Gymnasieskola eller motsvarande</option>
                                        <option>Certifierad</option>
                                        <option>Yrkesutbildad</option>
                                        <option>Enstaka kurser</option>
                                        <option>Övriga eftergymnasiala kurser</option>
                                        <option>Kandidatexamen</option>
                                        <option>Magister eller civilingenjörexamen</option>
                                        <option>Licentiat eller doktorsexamen</option>
                                        <option>Yrkeslicens</option>
                                    </select>
                                    <div class="field-label-box">Inriktning</div>
                                    <div class="field-input-box"><input type="text" onchange="$('#educationForm<%= id%>').ajaxSubmit()" name="direction" id="education-direction-field<%= id%>" value=""></div>
                                    <div class="field-label-box">Omfattning</div>
                                    <div class="field-input-box"><input type="text" onchange="$('#educationForm<%= id%>').ajaxSubmit()" name="scope" id="education-scope-field<%= id%>" value=""></div>
                                    <div class="field-label-box">Från och med</div>
                                    <div class="field-input-box"><input type="text" onchange="$('#educationForm<%= id%>').ajaxSubmit()" name="from" id="education-from-field<%= id%>" value=""></div>
                                    <div class="field-label-box">Till och med</div>
                                    <div class="field-input-box"><input type="text" onchange="$('#educationForm<%= id%>').ajaxSubmit()" name="to" id="education-to-field<%= id%>" value=""></div>
                                    <div class="field-label-box">Land</div>
                                    <div class="field-input-box"><input type="text" onchange="$('#educationForm<%= id%>').ajaxSubmit()" name="country" id="education-country-field<%= id%>" value="Sverige"></div>
                                    <div class="field-label-box">Beskrivning</div>
                                    <div class="field-input-box"><input type="text" onchange="$('#educationForm<%= id%>').ajaxSubmit()" name="description" id="education-description-field<%= id%>" value=""></div>
                                    <br>
                                </fieldset>
                            </form>
                        </div>
                        <br>

                        <%

                                } catch (Exception e) {

                                } finally {

                                    tx.finish();
                                    tx = null;
                                    education = null;

                                }

                            }

                        %>


                    </div>
                    <br>
                    <a href="#" onclick="addEducation()"><img src="images/plus.png"> Lägg till utbildning</a>

                    <!-- Kurser början -->

                    <br>
                    <div id="course-list" class="field-box">

                        <%

                            int courseCount = 0;

                                for (Relationship entry : employee.getRelationships(SimpleRelationshipType.withName("HAS_COURSE"), Direction.OUTGOING)) {

                                    //if (!entry.getEndNode().getProperty("name", "").equals("")) {

                                        courseCount++;
                                        long id = entry.getEndNode().getId();

                                    %>

                        <div>
                            <div class="field-label-box">Kurs</div>
                            <form id="courseForm<%= id%>" action="neo/ajax/update_properties.do" method="post">
                                <fieldset>
                                    <input type="hidden" name="_id" value="<%= id%>">
                                    <input type="hidden" name="_type" value="node">
                                    <input type="hidden" name="_strict" value="false">
                                    <input type="hidden" name="_username" value="admin">
                                    <div class="field-label-box">Benämning</div>
                                    <div class="field-input-box"><input type="text" onchange="$('#courseForm<%= id%>').ajaxSubmit()" name="name" id="course-field<%= id%>" value="<%=entry.getEndNode().getProperty("name", "")%>"></div>
                                    <div class="field-label-box">Från och med</div>
                                    <div class="field-input-box"><input type="text" onchange="$('#courseForm<%= id%>').ajaxSubmit()" name="from" id="course-from-field<%= id%>" value="<%=entry.getEndNode().getProperty("from", "")%>"></div>
                                    <div class="field-label-box">Till och med</div>
                                    <div class="field-input-box"><input type="text" onchange="$('#courseForm<%= id%>').ajaxSubmit()" name="to" id="course-to-field<%= id%>" value="<%=entry.getEndNode().getProperty("to", "")%>"></div>
                                    <div class="field-label-box">Beskrivning</div>
                                    <div class="field-input-box"><input type="text" onchange="$('#courseForm<%= id%>').ajaxSubmit()" name="description" id="course-description-field<%= id%>" value="<%=entry.getEndNode().getProperty("description", "")%>"></div>
                                    <br>
                                </fieldset>
                            </form>
                        </div>
                        <br>

                                    <%
                                            //}

                                        }

                                        if (courseCount == 0) {


                                        Transaction tx = neo.beginTx();
                                        Node course = null;

                                        try {

                                            course = neo.createNode();

                                            long id = course.getId();

                                            course.setProperty("nodeClass", "course");

                                            employee.createRelationshipTo(course, SimpleRelationshipType.withName("HAS_COURSE"));

                                            tx.success();


                                        %>

                        <div>
                            <div class="field-label-box">Kurs</div>
                            <form id="courseForm<%= id%>" action="neo/ajax/update_properties.do" method="post">
                                <fieldset>
                                    <input type="hidden" name="_id" value="<%= id%>">
                                    <input type="hidden" name="_type" value="node">
                                    <input type="hidden" name="_strict" value="false">
                                    <input type="hidden" name="_username" value="admin">
                                    <div class="field-label-box">Benämning</div>
                                    <div class="field-input-box"><input type="text" onchange="$('#courseForm<%= id%>').ajaxSubmit()" name="name" id="course-field<%= id%>" value=""></div>
                                    <div class="field-label-box">Från och med</div>
                                    <div class="field-input-box"><input type="text" onchange="$('#courseForm<%= id%>').ajaxSubmit()" name="from" id="course-from-field<%= id%>" value=""></div>
                                    <div class="field-label-box">Till och med</div>
                                    <div class="field-input-box"><input type="text" onchange="$('#courseForm<%= id%>').ajaxSubmit()" name="to" id="course-to-field<%= id%>" value=""></div>
                                    <div class="field-label-box">Beskrivning</div>
                                    <div class="field-input-box"><input type="text" onchange="$('#courseForm<%= id%>').ajaxSubmit()" name="description" id="course-description-field<%= id%>" value=""></div>
                                    <br>
                                </fieldset>
                            </form>
                        </div>
                        <br>

                        <%
                                        } catch (Exception e) {

                                        } finally {

                                            tx.finish();
                                            tx = null;
                                            course = null;

                                        }
                            }
                        %>

                    </div>
                    <br>
                    <a href="#" onclick="addCourse()"><img src="images/plus.png"> Lägg till kurs</a>

                    <!-- Kurser slut -->

                    <!-- Språk början -->

                    <br>
                    <div id="language-list" class="field-box">

                        <%

                            int languageCount = 0;

                                for (Relationship entry : employee.getRelationships(SimpleRelationshipType.withName("HAS_LANGUAGESKILL"), Direction.OUTGOING)) {

                                    //if (!entry.getEndNode().getProperty("language", "").equals("")) {

                                        languageCount++;
                                        long id = entry.getEndNode().getId();

                                    %>

                        <div>
                            <form id="languageForm<%= id%>" action="neo/ajax/update_properties.do" method="post">
                                <fieldset>
                                    <input type="hidden" name="_id" value="<%= id%>">
                                    <input type="hidden" name="_type" value="node">
                                    <input type="hidden" name="_strict" value="false">
                                    <input type="hidden" name="_username" value="admin">
                                    <div class="field-label-box">Språk</div>
                                    <div class="field-input-box"><input type="text" onchange="$('#languageForm<%= id%>').ajaxSubmit()" name="language" id="language-field<%= id%>" value="<%=entry.getEndNode().getProperty("language", "")%>"></div>
                                    <div class="field-label-box">Kunskapsnivå - skriftlig</div>
                                    <select name="written" onchange="$('#languageForm<%= id%>').ajaxSubmit()" id="written-field<%= id%>">
                                        <option <%=entry.getEndNode().getProperty("written", "").equals("Viss") ? "checked" : ""%>>Viss</option>
                                        <option <%=entry.getEndNode().getProperty("written", "").equals("God") ? "checked" : ""%>>God</option>
                                        <option <%=entry.getEndNode().getProperty("written", "").equals("Avancerad") ? "checked" : ""%>>Avancerad</option>
                                    </select>
                                    <div class="field-label-box">Kunskapsnivå - muntlig</div>
                                    <select name="spoken" onchange="$('#languageForm<%= id%>').ajaxSubmit()" id="spoken-field<%= id%>">
                                        <option <%=entry.getEndNode().getProperty("spoken", "").equals("Viss") ? "checked" : ""%>>Viss</option>
                                        <option <%=entry.getEndNode().getProperty("spoken", "").equals("God") ? "checked" : ""%>>God</option>
                                        <option <%=entry.getEndNode().getProperty("spoken", "").equals("Avancerad") ? "checked" : ""%>>Avancerad</option>
                                    </select>
                                    <br>
                                </fieldset>
                            </form>
                        </div>
                        <br>

                                    <%
                                        //    }

                                        }

                                        if (languageCount == 0) {


                                        Transaction tx = neo.beginTx();
                                        Node language = null;

                                        try {

                                            language = neo.createNode();

                                            long id = language.getId();

                                            language.setProperty("nodeClass", "language");

                                            employee.createRelationshipTo(language, SimpleRelationshipType.withName("HAS_LANGUAGESKILL"));

                                            tx.success();


                                        %>

                        <div>
                            <form id="languageForm<%= id%>" action="neo/ajax/update_properties.do" method="post">
                                <fieldset>
                                    <input type="hidden" name="_id" value="<%= id%>">
                                    <input type="hidden" name="_type" value="node">
                                    <input type="hidden" name="_strict" value="false">
                                    <input type="hidden" name="_username" value="admin">
                                    <div class="field-label-box">Språk</div>
                                    <div class="field-input-box"><input type="text" onchange="$('#languageForm<%= id%>').ajaxSubmit()" name="language" id="language-field<%= id%>" value=""></div>
                                    <div class="field-label-box">Kunskapsnivå - skriftlig</div>
                                    <select name="written" onchange="$('#languageForm<%= id%>').ajaxSubmit()" id="written-field<%= id%>">
                                        <option>Viss</option>
                                        <option>God</option>
                                        <option>Avancerad</option>
                                    </select>
                                    <div class="field-label-box">Kunskapsnivå - muntlig</div>
                                    <select name="spoken" onchange="$('#languageForm<%= id%>').ajaxSubmit()" id="spoken-field<%= id%>">
                                        <option>Viss</option>
                                        <option>God</option>
                                        <option>Avancerad</option>
                                    </select>
                                    <br>
                                </fieldset>
                            </form>
                        </div>
                        <br>

                        <%

                                        } catch (Exception e) {

                                        } finally {

                                            tx.finish();
                                            tx = null;
                                            language = null;

                                        }

                            }

                        %>

                    </div>
                    <br>
                    <a href="#" onclick="addLanguage()"><img src="images/plus.png"> Lägg till språk</a>

                    <!-- Språk slut -->

                    <form id="additionalKnowledgeForm" action="neo/ajax/update_properties.do" method="post">
                        <fieldset>
                            <input type="hidden" name="_id" value="<%=employee.getId()%>">
                            <input type="hidden" name="_type" value="node">
                            <input type="hidden" name="_strict" value="false">
                            <input type="hidden" name="_username" value="admin">
                            <br>
                            <div class="field-box"><div class="field-label-box">Annan kunskap</div>
                                <div class="field-input-box"><textarea onchange="$('#additionalKnowledgeForm').ajaxSubmit()" name="additional-knowledge" id="additional-knowledge-field"><%=employee.getProperty("additional-knowledge", "")%></textarea></div>
                            </div>
                            <br>
                        </fieldset>
                    </form>
                    &nbsp;
                </div>
                <div id="competence-footer" class="list-footer">&nbsp;</div>

                <div class="header text-header">
                    Erfarenhet<div class="expand-contract"><img onclick="toggleExpand(event)" id="experience-expand" src="images/contract.png"></div>
                </div>
                <div class="list-body profile-list" id="experience-list">

                    <!-- Befattningar början -->

                    <br>
                    <div id="workexperience-list" class="field-box">

                        <%

                            int workexperienceCount = 0;

                                for (Relationship entry : employee.getRelationships(SimpleRelationshipType.withName("HAS_WORK_EXPERIENCE"), Direction.OUTGOING)) {

                                    //if (!entry.getEndNode().getProperty("name", "").equals("")) {

                                        workexperienceCount++;
                                        long id = entry.getEndNode().getId();

                                    %>

                        <div>
                            <form id="workexperienceForm<%= id%>" action="neo/ajax/update_properties.do" method="post">
                                <fieldset>
                                    <input type="hidden" name="_id" value="<%= id%>">
                                    <input type="hidden" name="_type" value="node">
                                    <input type="hidden" name="_strict" value="false">
                                    <input type="hidden" name="_username" value="admin">
                                    <div class="field-label-box">Tidigare befattning</div>
                                    <div class="field-input-box"><input type="text" onchange="$('#workexperienceForm<%= id%>').ajaxSubmit()" name="name" id="name-field<%= id%>" value="<%=entry.getEndNode().getProperty("name", "")%>"></div>
                                    <div class="field-label-box">Företag</div>
                                    <div class="field-input-box"><input type="text" onchange="$('#workexperienceForm<%= id%>').ajaxSubmit()" name="company" id="company-field<%= id%>" value="<%=entry.getEndNode().getProperty("company", "")%>"></div>
                                    <div class="field-label-box">Bransch</div>
                                    <div class="field-input-box"><input type="text" onchange="$('#workexperienceForm<%= id%>').ajaxSubmit()" name="trade" id="trade-field<%= id%>" value="<%=entry.getEndNode().getProperty("trade", "")%>"></div>
                                    <div class="field-label-box">Land</div>
                                    <div class="field-input-box"><input type="text" onchange="$('#workexperienceForm<%= id%>').ajaxSubmit()" name="country" id="country-field<%= id%>" value="<%=entry.getEndNode().getProperty("country", "Sverige")%>"></div>
                                    <div class="field-label-box">Från och med</div>
                                    <div class="field-input-box"><input type="text" onchange="$('#workexperienceForm<%= id%>').ajaxSubmit()" name="from" id="from-field<%= id%>" value="<%=entry.getEndNode().getProperty("from", "")%>"></div>
                                    <div class="field-label-box">Till och med</div>
                                    <div class="field-input-box"><input type="text" onchange="$('#workexperienceForm<%= id%>').ajaxSubmit()" name="to" id="to-field<%= id%>" value="<%=entry.getEndNode().getProperty("to", "")%>"></div>
                                    <div class="field-label-box">Uppgifter</div>
                                    <div class="field-input-box"><textarea onchange="$('#workexperienceForm<%= id%>').ajaxSubmit()" name="assignments" id="assignments-field<%= id%>"><%=entry.getEndNode().getProperty("assignments", "")%></textarea></div>
                                    <br>
                                </fieldset>
                            </form>
                        </div>
                        <br>

                                    <%
                                            //}

                                        }

                                        if (workexperienceCount == 0) {


                                        Transaction tx = neo.beginTx();
                                        Node workexperience = null;

                                        try {

                                            workexperience = neo.createNode();

                                            long id = workexperience.getId();

                                            workexperience.setProperty("nodeClass", "workexperience");

                                            employee.createRelationshipTo(workexperience, SimpleRelationshipType.withName("HAS_WORK_EXPERIENCE"));

                                            tx.success();


                                        %>

                        <div>
                            <form id="workexperienceForm<%= id%>" action="neo/ajax/update_properties.do" method="post">
                                <fieldset>
                                    <input type="hidden" name="_id" value="<%= id%>">
                                    <input type="hidden" name="_type" value="node">
                                    <input type="hidden" name="_strict" value="false">
                                    <input type="hidden" name="_username" value="admin">

                                    <div class="field-label-box">Tidigare befattning</div>
                                    <div class="field-input-box"><input type="text" onchange="$('#workexperienceForm<%= id%>').ajaxSubmit()" name="name" id="name-field<%= id%>" value=""></div>
                                    <div class="field-label-box">Företag</div>
                                    <div class="field-input-box"><input type="text" onchange="$('#workexperienceForm<%= id%>').ajaxSubmit()" name="company" id="company-field<%= id%>" value=""></div>
                                    <div class="field-label-box">Bransch</div>
                                    <div class="field-input-box"><input type="text" onchange="$('#workexperienceForm<%= id%>').ajaxSubmit()" name="trade" id="trade-field<%= id%>" value=""></div>
                                    <div class="field-label-box">Land</div>
                                    <div class="field-input-box"><input type="text" onchange="$('#workexperienceForm<%= id%>').ajaxSubmit()" name="country" id="country-field<%= id%>" value="Sverige"></div>
                                    <div class="field-label-box">Från och med</div>
                                    <div class="field-input-box"><input type="text" onchange="$('#workexperienceForm<%= id%>').ajaxSubmit()" name="from" id="from-field<%= id%>" value=""></div>
                                    <div class="field-label-box">Till och med</div>
                                    <div class="field-input-box"><input type="text" onchange="$('#workexperienceForm<%= id%>').ajaxSubmit()" name="to" id="to-field<%= id%>" value=""></div>
                                    <div class="field-label-box">Uppgifter</div>
                                    <div class="field-input-box"><textarea onchange="$('#workexperienceForm<%= id%>').ajaxSubmit()" name="assignments" id="assignments-field<%= id%>"></textarea></div>
                                    <br>
                                </fieldset>
                            </form>
                        </div>
                        <br>

                        <%

                                        } catch (Exception e) {

                                        } finally {

                                            tx.finish();
                                            tx = null;
                                            workexperience = null;

                                        }

                            }

                        %>

                    </div>
                    <br>
                    <a href="#" onclick="addWorkExperience()"><img src="images/plus.png"> Lägg till tidigare befattning</a>
                    <br>
                    <!-- Befattningar slut -->

                    <form id="additionalExperienceForm" action="neo/ajax/update_properties.do" method="post">
                                <fieldset>
                                    <input type="hidden" name="_id" value="<%=employee.getId()%>">
                                    <input type="hidden" name="_type" value="node">
                                    <input type="hidden" name="_strict" value="false">
                                    <input type="hidden" name="_username" value="admin">
                    <div class="field-box"><div class="field-label-box">Annan erfarenhet</div>
                        <div class="field-input-box"><textarea onchange="$('#additionalExperienceForm').ajaxSubmit()" name="additional-experience" id="additional-experience-field"><%=employee.getProperty("additional-experience", "")%></textarea></div>
                    </div>
                    <br>
                    <div class="field-box"><div class="field-label-box">Militärtjänst</div>
                        <div class="field-input-box"><textarea onchange="$('#additionalExperienceForm').ajaxSubmit()" name="military-service" id="military-service-field"><%=employee.getProperty("military-service", "")%></textarea></div>
                    </div>
                    <br>
                    <br>
                                    </fieldset>
                        </form>
                </div>
                <div id="experience-footer" class="list-footer">&nbsp;</div>

        </div>
        <div id="modalizer">&nbsp;</div>
        </div>
    </body>
</html>