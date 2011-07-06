<%--
  Created by IntelliJ IDEA.
  User: fairview
  Date: 7/6/11
  Time: 4:33 PM
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@include file="WEB-INF/jspf/beanMapper.jsp" %>
<%
    StringBuilder managerSnippet = new StringBuilder();

        for (Node entry : personListGenerator.getSortedList(PersonListGenerator.ALPHABETICAL, false)) {

            try {

                if (!entry.getProperty("firstname", "").equals("") || !entry.getProperty("lastname", "").equals("")) {


                    managerSnippet.append("<option value=\"");
                    managerSnippet.append(entry.getId());
                    managerSnippet.append("\">");
                    managerSnippet.append(entry.getProperty("lastname", ""));
                    managerSnippet.append(", ");
                    managerSnippet.append(entry.getProperty("firstname", ""));
                    managerSnippet.append("</option>\\\n");

                }
                    } catch (Exception ex) {

                }

            }
%>
<div id="content">
    <form id="subunit_form' + data.relationship.endNode + '" action="neo/ajax/update_properties.do" method="post">\
                                    <fieldset>
                                    <input type="hidden" name="_id" value="' + data.relationship.endNode + '">\
                                    <input type="hidden" name="_type" value="node">
                                    <input type="hidden" name="_strict" value="true">
                                    <input type="hidden" name="_username" value="admin">
                                    <input type="hidden" name="nodeClass" value="unit">
                                    <div class="field-box"><div class="field-label-box">Namn</div><div><input type="text" name="name" onchange="$('#subunit_form' + data.relationship.endNode + '').ajaxSubmit()" class="text-field" id="name-field' + data.relationship.endNode + '"></div></div>\
                                    <br>\
                                    <div class="field-box"><div class="field-label-box">Beskrivning</div><div><textarea name="description" onchange="$('#subunit_form' + data.relationship.endNode + '').ajaxSubmit()" id="description-field' + data.relationship.endNode + '"></textarea></div></div>\
                                    <br>\
                                    <div class="field-label-box">Chef</div>\
                                    <div>\
                                        <select id="manager-selection" name="manager" onchange="assignManager(this, ' + data.relationship.endNode + ')">\
                                            <option>Välj...</option>\
                                            <%=managerSnippet.toString()%>\
                                    </select>\
                                    </div>\
                                    <br>\
                                    <div class="field-box"><div class="field-label-box">Telefonnummer</div><div><input type="text" name="phone" onchange="$('#subunit_form' + data.relationship.endNode + '').ajaxSubmit()" class="text-field" id="phone-field' + data.relationship.endNode + '"></div></div>\
                                    <br>\
                                    <div class="field-box"><div class="field-label-box">Faxnummer</div><div><input type="text" name="fax" onchange="$('#subunit_form' + data.relationship.endNode + '').ajaxSubmit()" class="text-field" id="fax-field' + data.relationship.endNode + '"></div></div>\
                                    <br>\
                                    <div class="field-box"><div class="field-label-box">E-post</div><div><input type="text" name="email" onchange="$('#subunit_form' + data.relationship.endNode + '').ajaxSubmit()" class="text-field" id="email-field' + data.relationship.endNode + '"></div></div>\
                                    <br>\
                                    <div class="field-box"><div class="field-label-box">Hemsida</div><div><input type="text" name="web" onchange="$('#subunit_form' + data.relationship.endNode + '').ajaxSubmit()" class="text-field" id="web-field' + data.relationship.endNode + '"></div></div>\
                                    <br>\
                                    <div class="field-box"><div class="field-label-box">Adress</div><div><input type="text" name="address" onchange="$('#subunit_form' + data.relationship.endNode + '').ajaxSubmit()" class="text-field" id="streetaddress-field' + data.relationship.endNode + '"></div></div>\
                                    <br>\
                                    <div class="field-box"><div class="field-label-box">Postnummer</div><div><input type="text" name="postalcode" onchange="$('#subunit_form' + data.relationship.endNode + '').ajaxSubmit()" class="text-field" id="zip-field' + data.relationship.endNode + '"></div></div>\
                                    <br>\
                                    <div class="field-box"><div class="field-label-box">Ort</div><div><input type="text" name="city" onchange="$('#subunit_form' + data.relationship.endNode + '').ajaxSubmit()" class="text-field" id="city-field' + data.relationship.endNode + '"></div></div>\
                                    <br>\
                                    <div class="field-box"><div class="field-label-box">Land</div><div><input type="text" name="country" onchange="$('#subunit_form' + data.relationship.endNode + '').ajaxSubmit()" class="text-field" id="country-field' + data.relationship.endNode + '"></div></div>\
                                    <br>\
                                    </fieldset>\
                                    </form>\
</div>