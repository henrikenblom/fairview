<%--
  Created by IntelliJ IDEA.
  User: fairview
  Date: 7/5/11
  Time: 10:17 AM
  To change this template use File | Settings | File Templates.
--%>
<%@page contentType="text/html" pageEncoding="UTF-8" %>
<%@include file="WEB-INF/jspf/beanMapper.jsp" %>
<%
        Node mainAddressNode = null;

        try {

            mainAddressNode = ((Iterable<Relationship>) organization.getRelationships(SimpleRelationshipType.withName("HAS_ADDRESS"))).iterator().next().getEndNode();

        } catch (Exception ex) {

           Transaction tx = neo.beginTx();

           try {

                mainAddressNode = neo.createNode();

                organization.createRelationshipTo(mainAddressNode, SimpleRelationshipType.withName("HAS_ADDRESS"));

                tx.success();

            } catch (Exception e) {

            }    finally {

                   tx.finish();

            }

        }

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
                        <form id="organization_form" action="neo/ajax/update_properties.do" method="post">
                        <fieldset>
                            <input type="hidden" name="_id" value="<%= organization.getId()%>">
                            <input type="hidden" name="_type" value="node">
                            <input type="hidden" name="_strict" value="true">
                            <input type="hidden" name="_username" value="admin">
                        <div class="field-box"><div class="field-label-box">Namn</div><div><input type="text" onchange="$('#organization_form').ajaxSubmit(organizationFormSaved())" value="<%=organization.getProperty("name", "")%>" class="text-field" id="name-field" name="name"></div></div>
                        <br>
                        <div class="field-box"><div class="field-label-box">Beskrivning</div><div><textarea onchange="$('#organization_form').ajaxSubmit(organizationFormSaved())" id="description-field" name="description"><%=organization.getProperty("description", "")%></textarea></div></div>
                        <br>
                        <div class="field-box"><div class="field-label-box">Organisationsnummer</div><div><input onchange="$('#organization_form').ajaxSubmit(organizationFormSaved())" type="text" value="<%=organization.getProperty("regnr", "")%>" name="regnr" class="text-field" id="orgnr-field"></div></div>
                        <br>
                        <div class="field-box"><div class="field-label-box">Telefonnummer</div><div><input type="text" onchange="$('#organization_form').ajaxSubmit(organizationFormSaved())" value="<%=organization.getProperty("phone", "")%>" name="phone" class="text-field" id="phone-field"></div></div>
                        <br>
                        <div class="field-box"><div class="field-label-box">Faxnummer</div><div><input type="text" onchange="$('#organization_form').ajaxSubmit(organizationFormSaved())" value="<%=organization.getProperty("fax", "")%>" name="fax" class="text-field" id="fax-field"></div></div>
                        <br>
                        <div class="field-box"><div class="field-label-box">E-post</div><div><input type="text" onchange="$('#organization_form').ajaxSubmit(organizationFormSaved())" value="<%=organization.getProperty("email", "")%>" name="email" class="text-field" id="email-field"></div></div>
                        <br>
                        <div class="field-box"><div class="field-label-box">Hemsida</div><div><input type="text" onchange="$('#organization_form').ajaxSubmit(organizationFormSaved())" value="<%=organization.getProperty("web", "")%>" name="web" class="text-field" id="web-field"></div></div>
                        <br>
                            </fieldset>
                            </form>
                            <form id="organization_address_form0" action="neo/ajax/update_properties.do" method="post">
                            <fieldset>
                            <input type="hidden" name="_id" value="<%= mainAddressNode.getId()%>">
                            <input type="hidden" name="_type" value="node">
                            <input type="hidden" name="_strict" value="true">
                            <input type="hidden" name="_username" value="admin">
                        <div class="field-box"><div class="field-label-box">Adressbenämning</div><div><input type="text" onchange="$('#organization_address_form0').ajaxSubmit()" class="text-field" id="addressname-field0" name="description" value="<%=mainAddressNode.getProperty("description", "Huvudadress")%>"></div></div>
                        <br>
                        <div class="field-box"><div class="field-label-box">Adress</div><div><input type="text" onchange="$('#organization_address_form0').ajaxSubmit()" class="text-field" id="streetaddress-field0" name="address" value="<%=mainAddressNode.getProperty("address", "")%>"></div></div>
                        <br>
                        <div class="field-box"><div class="field-label-box">Postnummer</div><div><input type="text" onchange="$('#organization_address_form0').ajaxSubmit()" class="text-field" id="zip-field0" name="postalcode" value="<%=mainAddressNode.getProperty("postalcode", "")%>"></div></div>
                        <br>
                        <div class="field-box"><div class="field-label-box">Ort</div><div><input type="text" onchange="$('#organization_address_form0').ajaxSubmit()" class="text-field" id="city-field0" name="city" value="<%=mainAddressNode.getProperty("city", "")%>"></div></div>
                        <br>
                        <div class="field-box"><div class="field-label-box">Land</div><div><input type="text" onchange="$('#organization_address_form0').ajaxSubmit()" class="text-field" id="country-field0" name="country" value="<%=mainAddressNode.getProperty("country", "")%>"></div></div>
                        <br>

                        </fieldset>
                                </form>
                        <div id="additional-adresses-box">
                        <%

                        for (Relationship entry : organization.getRelationships(SimpleRelationshipType.withName("HAS_ADDRESS"))) {

                            if (entry.getEndNode().getId() != mainAddressNode.getId()) {

                        %>

                        <form id="organization_address_form<%=entry.getEndNode().getId()%>" action="neo/ajax/update_properties.do" method="post">
                        <fieldset>
                        <input type="hidden" name="_id" value="<%=entry.getEndNode().getId()%>">
                        <input type="hidden" name="_type" value="node">
                        <input type="hidden" name="_strict" value="true">
                        <input type="hidden" name="_username" value="admin">
                        <div class="field-box"><div class="field-label-box">Adressbenämning</div><div><input type="text" onchange="$('#organization_address_form<%=entry.getEndNode().getId()%>').ajaxSubmit()" class="text-field" id="addressname-field<%=entry.getEndNode().getId()%>" name="description" value="<%=entry.getEndNode().getProperty("description", "")%>"></div></div>
                        <br>
                        <div class="field-box"><div class="field-label-box">Adress</div><div><input type="text" onchange="$('#organization_address_form<%=entry.getEndNode().getId()%>').ajaxSubmit()" class="text-field" id="streetaddress-field<%=entry.getEndNode().getId()%>" name="address" value="<%=entry.getEndNode().getProperty("address", "")%>"></div></div>
                        <br>
                        <div class="field-box"><div class="field-label-box">Postnummer</div><div><input type="text" onchange="$('#organization_address_form<%=entry.getEndNode().getId()%>').ajaxSubmit()" class="text-field" id="zip-field<%=entry.getEndNode().getId()%>" name="postalcode" value="<%=entry.getEndNode().getProperty("postalcode", "")%>"></div></div>
                        <br>
                        <div class="field-box"><div class="field-label-box">Ort</div><div><input type="text" onchange="$('#organization_address_form<%=entry.getEndNode().getId()%>').ajaxSubmit()" class="text-field" id="city-field<%=entry.getEndNode().getId()%>" name="city" value="<%=entry.getEndNode().getProperty("city", "")%>"></div></div>
                        <br>
                        <div class="field-box"><div class="field-label-box">Land</div><div><input type="text" onchange="$('#organization_address_form<%=entry.getEndNode().getId()%>').ajaxSubmit()" class="text-field" id="country-field<%=entry.getEndNode().getId()%>" name="country" value="<%=entry.getEndNode().getProperty("country", "")%>"></div></div>
                        <br>
                        </fieldset>
                        </form>

                        <%

                            }

                        }

                        %>
                        </div>
                        <br>
                        <a href="javascript: addMainOrganisationAddressFieldButtonClick(event)">Lägg till ytterligare en adress</a>
                        <br>
                        &nbsp;
                    </div>