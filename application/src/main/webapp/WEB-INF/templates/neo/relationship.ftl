[#ftl encoding="UTF-8" attributes={'content_type' : 'text/html; charset=utf-8'}]<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html
        PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">

<head>

    [#assign relationship=neo.getRelationshipById(RequestParameters.id?number)/]

    <title>Relationship ${relationship.id}</title>

    <script type="text/javascript">

        function loadRelationship(id) {
            $.get("/neo/ajax/get_relationship_view.do", {_relationshipId:id}, function(data) {
                $("#relationship_" + id).hide("blind", {direction:"vertical"}, 250, function() {
                    $("#relationship_" + id).html(data);
                    $.getScript("/neo/ajax/get_relationship_view.do?_relationshipId=" + id + "&_variant=script");
                    $("#relationship_" + id).show("blind", {direction:"vertical"}, 250);
                });
            }, "html");
        }

        $(document).ready(function() {
            loadRelationship(${relationship.id});
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

<div id="relationship_${relationship.id}">Loading...</div>

</body>
</html>