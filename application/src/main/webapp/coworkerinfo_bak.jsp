<%--
  Created by IntelliJ IDEA.
  User: henrik
  Date: 2011-03-18
  Time: 09.10
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%@include file="WEB-INF/jspf/beanMapper.jsp" %>

<%

    Node employee = neo.getNodeById(Long.decode((String) request.getParameter("id")));
    HashMap<Long, Long> belongsToUnits = new HashMap<Long, Long>();
    HashMap<Long, Node> functionMap = new HashMap<Long, Node>();
    boolean hasAuthority = (employee.getProperty("executive", "").equals("true")
            || employee.getProperty("budget-responsibility", "").equals("true")
            || employee.getProperty("own-result-responsibility", "").equals("true")
            || employee.getProperty("authorization", "").equals("true"));

    for (Relationship entry : organization.getRelationships(SimpleRelationshipType.withName("HAS_FUNCTION"), Direction.OUTGOING)) {

        try {

        Traverser employmentTraverser = entry.getEndNode().traverse(Traverser.Order.BREADTH_FIRST, StopEvaluator.END_OF_GRAPH, ReturnableEvaluator.ALL_BUT_START_NODE, SimpleRelationshipType.withName("PERFORMS_FUNCTION"), Direction.INCOMING);
        Traverser employeeTraverser = employmentTraverser.iterator().next().traverse(Traverser.Order.BREADTH_FIRST, StopEvaluator.END_OF_GRAPH, ReturnableEvaluator.ALL_BUT_START_NODE, SimpleRelationshipType.withName("HAS_EMPLOYMENT"), Direction.INCOMING);

        while (employeeTraverser.iterator().hasNext()) {

            functionMap.put(employeeTraverser.iterator().next().getId(), entry.getEndNode());

        }

        } catch (Exception ex) {

            // noop

        }

    }

    for (Relationship entry : employee.getRelationships(SimpleRelationshipType.withName("BELONGS_TO"), Direction.OUTGOING)) {

        belongsToUnits.put(entry.getEndNode().getId(),entry.getId());

    }

%>
<html>
    <head>
        <title>Infero Quest - Medarbetare</title>
        <link rel="stylesheet" href="css/newlook.css" type="text/css" media="screen" charset="utf-8" />
        <script type="text/javascript" src="js/jquery-1.4.4.min.js"></script>
        <script type="text/javascript" src="iq.js"></script>
        <script type="text/javascript">
            $(document).ready(function() {

                $('#modalizer').fadeOut(500);
                adjustViewPort();

            });
        </script>
    </head>
    <body onresize="adjustViewPort()">
        <%@include file="WEB-INF/jspf/iqpageheader.jsp" %>
        <div id="main">
            <div id="content">
                <div class="header text-header">
                    Anställningsuppgifter - <% if (!employee.getProperty("civic", "").equals("")) { %><%=employee.getProperty("civic", "")%> - <%}%><%=employee.getProperty("lastname", "")%>, <%=employee.getProperty("firstname", "")%> <% if (employee.getProperty("gender", "").equals("M")) { %> (Man)<% } %><% if (employee.getProperty("gender", "").equals("F")) { %> (Kvinna)<% } %><div class="expand-contract"><img onclick="toggleExpand(event)" id="profile-expand" src="images/contract.png"></div>
                </div>
                <div class="list-body profile-list" id="profile-list">
                    <br>
                    <div class="field-box"><b>Nationalitet</b><br><%= employee.getProperty("nationality", "Svensk")%></div>
                    <br>
                    <br>
                    <div class="field-box"><b>Anställningsnummer</b><br><%= employee.getProperty("employmentid", "-")%></div>
                    <br>
                    <br>
                    <div class="field-box"><b>Adress</b><br><%= employee.getProperty("address", "")%>
                        <br>
                        <%= employee.getProperty("zip", "")%> <%= employee.getProperty("city", "")%>
                        <br>
                        <%=employee.getProperty("country", "Sverige")%>
                    </div>
                    <br>
                    <br>
                    <div class="field-box"><b>Telefon</b><br><%= employee.getProperty("phone", "-")%></div>
                    <br>
                    <br>
                    <div class="field-box"><b>Mobiltelefon</b><br><%= employee.getProperty("cell", "-")%></div>
                    <br>
                    <br>
                    <div class="field-box"><b>E-post</b><br><%= employee.getProperty("email", "-")%></div>
                    <br>
                    <br>
                    <div class="field-box"><b>Funktion</b><br>
                    <%
                        if (functionMap.get(employee.getId()) != null) {
                            %>
                                <%=functionMap.get(employee.getId()).getProperty("name")%>
                            <%
                        }
                    %>
                    </div>
                    <br>
                    <br>
                    <div class="field-box"><b>Enhet<%=belongsToUnits.size() > 1 ? "er" : ""%></b><br>
                        <%
                            int c = 1;
                            for (Long unitId : belongsToUnits.keySet()) {

                                %>
                                    <%=neo.getNodeById(unitId).getProperty("name", "Namnlös enhet")%><%=c != belongsToUnits.size() ? "," : ""%>
                                <%

                                c++;

                            }
                        %>
                    </div>
                    <br>
                    <br>
                    <!--
                    <div class="field-box"><b>Anställnigstid</b><br><%= employee.getProperty("fromdate", "-")%> till <%= employee.getProperty("todate", "-")%></div>
                    <br>
                    <br>
                    <div class="field-box"><b>Anställningsform</b><br><%=employee.getProperty("employment", "-").equals("Välj...") ? "-" : employee.getProperty("employment", "-")%></div>
                    <br>
                    <br>
                    <div class="field-box"><b>Övrig information</b><br><%= employee.getProperty("additional_info", "-")%></div>
                    <br>
                    <br>
                    -->
                </div>
                <div id="profile-footer" class="list-footer">&nbsp;</div>
                <!--
                <div class="header text-header">
                    Arbetsbeskrivning<div class="expand-contract"><img onclick="toggleExpand(event)" id="responsibility-expand" src="images/contract.png"></div>
                </div>
                <div class="list-body profile-list" id="responsibility-list">
                    <br>
                    <div class="field-box"><b>Arbetstider</b><br><%= employee.getProperty("workhours", "-")%></div>
                    <br>
                    <br>
                    <div class="field-box"><b>Ansvar/Befogenheter</b><br>
                        <%=employee.getProperty("executive", "").equals("true") ? "• Ledningsgrupp<br>" : ""%>
                        <%=employee.getProperty("budget-responsibility", "").equals("true") ? "• Budgetansvar<br>" : ""%>
                        <%=employee.getProperty("own-result-responsibility", "").equals("true") ? "• Eget resultatansvar<br>" : ""%>
                        <%=employee.getProperty("authorization", "").equals("true") ? "• Attesträtt<br>" : ""%>
                    </div>
                    <br>
                    <br>
                    <div class="field-box"><b>Attesträtt belopp</b><br><%= employee.getProperty("authorization-amount", "-")%></div>
                    <br>
                    <br>
                    <div class="field-box"><b>Löneform</b><br><%=employee.getProperty("payment-form", "-").equals("Välj...") ? "-" : employee.getProperty("payment-form", "-")%></div>
                    <br>
                    <br>
                    <div class="field-box"><b>Aktuell lön</b><br><%=employee.getProperty("salary", "-")%></div>
                    <br>
                    <br>
                    <div class="field-box"><b>Övertidsersättning</b><br><%=(employee.getProperty("overtime-compensation", "").equals("true")) ? "Ja" : "Nej"%></div>
                    <br>
                    <br>
                    <div class="field-box"><b>Reseersättning</b><br><%=(employee.getProperty("travel-compensation", "").equals("true")) ? "Ja" : "Nej"%></div>
                    <br>
                    <br>
                    <div class="field-box"><b>Semesterrätt (dagar)</b><br><%=employee.getProperty("vaication-days", "-")%></div>
                    <br>
                    <br>
                    <div class="field-box"><b>Uppsägningstid (anställd)</b><br><%=employee.getProperty("dismissal-period-employee", "0").equals("Välj...") ? "0" : employee.getProperty("dismissal-period-employee", "0")%></div>
                    <br>
                    <br>
                    <div class="field-box"><b>Uppsägningstid (arbetsgivare)</b><br><%=employee.getProperty("dismissal-period-employer", "0").equals("Välj...") ? "0" : employee.getProperty("dismissal-period-employer", "0")%></div>
                    <br>
                    <br>
                    <div class="field-box"><b>Tjänstebil</b><br><%=employee.getProperty("company-car", "-")%></div>
                    <br>
                    <br>
                    <div class="field-box"><b>Pension och försäkringar</b><br><%=employee.getProperty("pension-insurances", "-")%></div>
                    <br>
                    <br>
                    <div class="field-box"><b>Ansvarsområden</b><br><%=employee.getProperty("responsibilities", "-")%></div>
                    <br>
                    <br>
                    <div class="field-box"><b>Arbetsuppgifter</b><br><%=employee.getProperty("tasks", "-")%></div>
                    <br>
                    <br>
                </div>
                <div id="responsibility-footer" class="list-footer">&nbsp;</div>
                <div class="header text-header">
                    Kompetens<div class="expand-contract"><img onclick="toggleExpand(event)" id="competence-expand" src="images/contract.png"></div>
                </div>
                <div class="list-body profile-list" id="competence-list">
                    <br>
                    <br>
                    <div class="field-box"><b>Körkortsbehörighet</b><br>
                        <%=employee.getProperty("dl_a1", "").equals("true") ? "• A1<br>" : ""%>
                        <%=employee.getProperty("dl_a", "").equals("true") ? "• A<br>" : ""%>
                        <%=employee.getProperty("dl_b", "").equals("true") ? "• B<br>" : ""%>
                        <%=employee.getProperty("dl_c", "").equals("true") ? "• C<br>" : ""%>
                        <%=employee.getProperty("dl_d", "").equals("true") ? "• D<br>" : ""%>
                        <%=employee.getProperty("dl_be", "").equals("true") ? "• BE<br>" : ""%>
                        <%=employee.getProperty("dl_ce", "").equals("true") ? "• CE<br>" : ""%>
                        <%=employee.getProperty("dl_cde", "").equals("true") ? "• DE<br>" : ""%>
                    </div>
                    <br>
                    <br>
                    <div class="field-box"><b>Utbildningar</b><br>
                        <%

                            int educationCount = 0;

                            for (Relationship entry : employee.getRelationships(SimpleRelationshipType.withName("HAS_EDUCATION"), Direction.OUTGOING)) {

                                if (!entry.getEndNode().getProperty("name", "").equals("")) {

                                    educationCount++;
                                    long id = entry.getEndNode().getId();

                        %>

                        <br>
                        <div class="field-box"><b>Benämning</b><br><%=entry.getEndNode().getProperty("name")%></div>
                        <br>
                        <br>
                        <div class="field-box"><b>Utbildningsnivå</b><br><%=entry.getEndNode().getProperty("level", "-")%></div>
                        <br>
                        <br>
                        <div class="field-box"><b>Inriktning</b><br><%=entry.getEndNode().getProperty("direction", "-")%></div>
                        <br>
                        <br>
                        <div class="field-box"><b>Omfattning</b><br><%=entry.getEndNode().getProperty("scope", "-")%></div>
                        <br>
                        <br>
                        <div class="field-box"><b>Från/Till</b><br><%=entry.getEndNode().getProperty("from", "-")%> - <%=entry.getEndNode().getProperty("to", "-")%></div>
                        <br>
                        <br>
                        <div class="field-box"><b>Land</b><br><%=entry.getEndNode().getProperty("country", "-")%></div>
                        <br>
                        <br>
                        <div class="field-box"><b>Beskrivning</b><br><%=entry.getEndNode().getProperty("description", "-")%></div>
                        <br>
                        <br>

                        <%

                                }
                            }

                        %>

                        <%=educationCount == 0 ? "-" : ""%>
                        </div>
                    <br>
                    <br>
                    <div class="field-box"><b>Kurser</b>
                        <br>
                    <%

                        int courseCount = 0;

                            for (Relationship entry : employee.getRelationships(SimpleRelationshipType.withName("HAS_COURSE"), Direction.OUTGOING)) {

                                if (!entry.getEndNode().getProperty("name", "").equals("")) {

                                    courseCount++;
                                    long id = entry.getEndNode().getId();

                                %>
                        <br>
                        <div class="field-box"><b>Benämning</b><br><%=entry.getEndNode().getProperty("name")%></div>
                        <br>
                        <br>
                        <div class="field-box"><b>Från/Till</b><br><%=entry.getEndNode().getProperty("from", "-")%> - <%=entry.getEndNode().getProperty("to", "-")%></div>
                        <br>
                        <br>
                        <div class="field-box"><b>Beskrivning</b><br><%=entry.getEndNode().getProperty("description", "-")%></div>
                        <br>

                    <%

                            }
                        }

                    %>
                        <%=courseCount == 0 ? "-" : ""%>
                    </div>
                    <br>
                    <br>
                    <div class="field-box"><b>Språk</b>
                    <br>
                        <%

                            int languageCount = 0;

                                for (Relationship entry : employee.getRelationships(SimpleRelationshipType.withName("HAS_LANGUAGESKILL"), Direction.OUTGOING)) {

                                    if (!entry.getEndNode().getProperty("language", "").equals("")) {

                                        languageCount++;
                                        long id = entry.getEndNode().getId();

                                    %>
                        <div class="field-box"><%=entry.getEndNode().getProperty("language")%>:
                        <%=entry.getEndNode().getProperty("written")%> skriftlig kunskap. <%=entry.getEndNode().getProperty("spoken")%> muntlig kunskap.
                        </div>
                        <br>
                        <%

                            }
                        }

                    %>
                        <%=languageCount == 0 ? "-" : ""%>
                    </div>
                    <br>
                    <br>
                    <div class="field-box"><b>Annan kunskap</b><br><%=employee.getProperty("additional-knowledge", "-")%></div>
                    <br>
                </div>
                <div id="competence-footer" class="list-footer">&nbsp;</div>
            <div class="header text-header">
                    Erfarenhet<div class="expand-contract"><img onclick="toggleExpand(event)" id="experience-expand" src="images/contract.png"></div>
                </div>
                <div class="list-body profile-list" id="experience-list">
                    <br>
                    <div class="field-box"><b>Tidigare befattningar</b>
                        <br>
                    <%

                            int workexperienceCount = 0;

                                for (Relationship entry : employee.getRelationships(SimpleRelationshipType.withName("HAS_WORK_EXPERIENCE"), Direction.OUTGOING)) {

                                    if (!entry.getEndNode().getProperty("name", "").equals("")) {

                                        workexperienceCount++;
                                        long id = entry.getEndNode().getId();

                                    %>

                        <br>
                        <div class="field-box"><b>Benämning</b><br><%=entry.getEndNode().getProperty("name")%></div>
                        <br>
                        <br>
                        <div class="field-box"><b>Företag</b><br><%=entry.getEndNode().getProperty("company", "-")%></div>
                        <br>
                        <br>
                        <div class="field-box"><b>Bransch</b><br><%=entry.getEndNode().getProperty("trade","-")%></div>
                        <br>
                        <br>
                        <div class="field-box"><b>Land</b><br><%=entry.getEndNode().getProperty("country","-")%></div>
                        <br>
                        <br>
                        <div class="field-box"><b>Från/Till</b><br><%=entry.getEndNode().getProperty("from", "-")%> - <%=entry.getEndNode().getProperty("to", "-")%></div>
                        <br>
                        <br>
                        <div class="field-box"><b>Uppgifter</b><br><%=entry.getEndNode().getProperty("assignments","-")%></div>
                        <br>
                        <br>

                    <%

                            }
                        }

                    %>

                        <%=workexperienceCount == 0 ? "-" : ""%>
                        </div>
                    <br>
                    <br>
                    <div class="field-box"><b>Annan erfarenhet</b><br><%=employee.getProperty("additional-experience", "-")%></div>
                    <br>
                    <br>
                    <div class="field-box"><b>Militärtjänst</b><br><%=employee.getProperty("military-service", "-")%></div>
                    <br>
                    <br>
                </div>
                <div id="experience-footer" class="list-footer">&nbsp;</div>
                -->
            </div>
        </div>

        <div id="modalizer">&nbsp;</div>
        </div>
    </body>
</html>
