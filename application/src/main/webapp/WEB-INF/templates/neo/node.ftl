[#ftl encoding="UTF-8" attributes={'content_type' : 'text/html; charset=utf-8'}]<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html
        PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">

<head>

    [#if RequestParameters.id??]
    [#assign node=neo.getNodeById(RequestParameters.id?number)/]
    [#else]
    [#assign node=neo.referenceNode/]
    [/#if]

    <title>Node ${node.id}</title>

    <script type="text/javascript">

        function loadNode(id) {
            $.get("/neo/ajax/get_node_view.do", {_nodeId:id}, function(data) {
                $("#node_" + id).hide("blind", {direction:"vertical"}, 250, function() {
                    $("#node_" + id).html(data);
                    $.getScript("/neo/ajax/get_node_view.do?_nodeId=" + id + "&_variant=script");
                    $("#node_" + id).show("blind", {direction:"vertical"}, 250);
                });
            }, "html");
        }

        $(document).ready(function() {
            loadNode(${node.id});
            /*
            $.comet.init("/cometd");
            $(document).unload(function() {
                $.comet.disconnect();
            });
            */
        });


    </script>

</head>
<body>

<div id="node_${node.id}">Loading...</div>

</body>
</html>