<%--
  Created by IntelliJ IDEA.
  User: Daniel
  Date: 10/24/11
  Time: 03:35 PM
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@include file="WEB-INF/jspf/beanMapper.jsp" %>

<html>
<head>
    <title>Infero Quest - Kompetensprofil</title>
    <link rel="stylesheet" href="css/newlook.css" type="text/css" media="screen" charset="utf-8"/>
    <link rel="stylesheet" href="css/demo_table.css" type="text/css" media="screen" charset="utf-8"/>
    <link type="text/css" href="css/jquery-ui/jquery-ui-1.8.13.custom.css" rel="stylesheet"/>
    <script type="text/javascript" src="js/plugins/jquery-1.4.4.min.js"></script>
    <script type="text/javascript" src="js/plugins/jquery.dataTables.js"></script>
    <script type="text/javascript" src="js/popupControls.js"></script>
    <script type="text/javascript" src="js/plugins/jquery-ui-1.8.13.custom.min.js"></script>
    <script type="text/javascript" src="js/formgenerator.js"></script>
    <script type="text/javascript" src="js/plugins/jquery.form.js"></script>
    <script type="text/javascript" src="js/datatables_util.js"></script>
    <script type="text/javascript" src="js/plugins/jquery.validate.js"></script>
    <script type="text/javascript" src="js/plugins/jquery.dataSelector.js"></script>
    <script type="text/javascript" src="js/plugins/spin.min.js"></script>
    <script type="text/javascript">
        $(document).ready(function() {
            $('.addnew').click(function() {
                var data = new Array;
                createExperienceProfileTab(data);
                openExperienceProfileForm(data);
            });
            oTable = $('#datatable').dataTable({
                "bProcessing": true,
                "bSortClasses": false,
                "bStateSave": true,
                "oLanguage": {
                    "sEmptyTable": "Inga profiler finns i databasen."
                },
                "sAjaxSource": "fairview/ajax/datatables/get_experience_profile_data.do",
                "aoColumns": [
                    { "mDataProp": "name"},
                    { "mDataProp": "description" }


                ],
                "fnDrawCallback" : function() {
                    var datatable = this;
                    var trNodes = this.fnGetNodes();
                    var tdNodes = $(trNodes).children();
                    $.each(tdNodes, function() {
                        var data = datatable.fnGetData(this.parentNode);
                        if (this.cellIndex == '0' || this.cellIndex == '1') {  //employee-cell
                            intExperienceProfileCell(data, this, 0);
                        }
                    });
                    $('td', datatable.fnGetNodes()).hover(function() {
                        $('td').removeClass('cell_highlight');
                        $(this).addClass('cell_highlight');
                    });
                }
            });
            fadeOutModalizer();
        });
        function openExperienceProfileForm(data, popupIndex) {
            $('#experience-profile-general').append(footerButtonsComponent(data.id, updateTableCallback(oTable)));
            bindExperienceProfileTabs();
            openPopupTab(popupIndex);
        }
    </script>
</head>
<%@include file="WEB-INF/jspf/iqpageheader.jsp" %>
<body class="ex_highlight_row">
<div id="main">
    <div id="content">
        <div class="addnew addnewtop"><img src="images/newperson.png"
                                           class="helpbox-image"><span>Lägg till ny kompetensprofil</span>
        </div>
        <div class="datatable">
            <table cellpadding="0" cellspacing="0" border="0" class="display" id="datatable">
                <thead>
                <tr>
                    <th>Namn</th>
                    <th>Beskrivning</th>
                </tr>
                </thead>
                <tbody>

                </tbody>
                <tfoot>
                <tr>
                    <th>Namn</th>
                    <th>Beskrivning</th>
                </tr>
                </tfoot>
            </table>
        </div>
        <div class="addnew addnewtop"><img src="images/newperson.png"
                                           class="helpbox-image"><span>Lägg till ny kompetensprofil</span>
        </div>
    </div>
</div>
<div id="modalizer">&nbsp;</div>
<div id="popup-dialog" style="display: none;"></div>
</body>
</html>