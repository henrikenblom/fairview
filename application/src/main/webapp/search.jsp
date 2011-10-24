<%--
  Created by IntelliJ IDEA.
  User: erik@codemate.se
  Date: 2011-10-21
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html><html>
<head>
    <%@include file="WEB-INF/jspf/beanMapper.jsp" %>
    <title>Infero Quest - Sök</title>
    <link rel="stylesheet" href="css/newlook.css" type="text/css" media="screen" charset="utf-8"/>
    <link rel="stylesheet" href="css/demo_table.css" type="text/css" media="screen" charset="utf-8"/>
    <link type="text/css" href="css/jquery-ui/jquery-ui-1.8.13.custom.css" rel="stylesheet"/>
    <script type="text/javascript" src="js/plugins/jquery-1.6.4.min.js"></script>
    <script type="text/javascript" src="js/plugins/jquery-ui-1.8.13.custom.min.js"></script>
    <script type="text/javascript" src="js/plugins/jquery.form.js"></script>
    <script type="text/javascript" src="js/plugins/mustache.js"></script>
    <script type="text/javascript" src="js/plugins/jQueryMustache.js"></script>
    <script type="text/javascript" src="js/formgenerator.js"></script>

    <style type="text/css">
        .search_result {
            border-bottom: 1px solid gray;
        }
    </style>

    <script id="template_undefined" type="x-tmpl-mustache">
        <div class="search_result">
            <p>ID: {{_id}}</p>
            <p>nodeclass: {{nodeclass}}</p>
        </div>
    </script>

    <script id="template_employee" type="x-tmpl-mustache">
        <div class="search_result">
            <p>{{firstname}} {{lastname}}</p>
            <p><img src="/fairview/ajax/get_image.do?_nodeId={{_id}}&size=small_image&random={{_random}}" width="80" height="120"/></p>
            <p><a href="mailto:{{email}}">{{email}}</a></p>
        </div>
    </script>

    <script>

        function flatten(node) {
            var data = {};
            data['_id'] = node.id;
            if (node.properties) {
                for (name in node.properties) {
                    if (node.properties[name].value) {
                        data[name] = node.properties[name].value;
                    }
                }
            }
            return data;
        }

        function processResults(results) {
            if (results['linked-list'] && results['linked-list'].node) {
                var nodes = results['linked-list'].node;
                $("#search_results").empty();
                $("#search_results").append('<h2>' + nodes.length + ' tr&auml;ffar</h2>');
                $.each(nodes, function(index, node) {
                    var data = flatten(node);
                    data['_index'] = index;
                    data['_random'] = Math.random()*100000;
                    var templateId = '#template_' + (data.nodeclass ? data.nodeclass : 'undefined');
                    if ($(templateId).length == 0) {
                        templateId = '#template_undefined';
                    }
                    $(templateId).mustache(data).appendTo("#search_results");
                });
            } else {
                $("#search_results").text('Inga träffar');
            }
        }

        $(document).ready(function() {
            $('#search_form').ajaxForm({
                dataType:  'json',
                success: processResults
            });
        });

    </script>

</head>
<%@include file="WEB-INF/jspf/iqpageheader.jsp" %>
<body class="ex_highlight_row">
<div id="movieList"></div>
<div id="main">
    <p>
    <form id="search_form" action="/neo/ajax/report-search.do" method="post">
        <input type="text" name="query" value="" style="width:400px"/>
        <input type="submit" value="S&ouml;k"/>
    </form>
    </p>
    <div id="search_results" style="margin-left:20px;text-align: left">

    </div>
</div>
</body>
</html>