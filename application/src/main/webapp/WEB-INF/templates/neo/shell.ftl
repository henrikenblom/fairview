<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html
        PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">

<head>

    <title>NeoShell v1.1</title>

    <link type="text/css" href="http://jqueryui.com/themes/base/ui.all.css" rel="stylesheet"/>

    <script type="text/javascript" src="http://www.google.com/jsapi"></script>

    <script type="text/javascript">

        google.load("jquery", "1.3.2");
        google.load("jqueryui", "1.7.2");

        var lineHeight = 0;

        var welcomeMessage = "${welcome?js_string}\n";

        var commandHistory = new Array();

        var commandCursor = 0;

        google.setOnLoadCallback(function() {

            $("#currentNode").load("shell-current-node.do");

            $("#line").focus();

            $("#currentNode").click(function() {
                $("#line").focus();
            });

            $("#console").click(function() {
                $("#line").focus();
            });

            $("#console").height($(window).height());
            lineHeight = $(document).height() - $(window).height();
            $("#console").height($(window).height() - lineHeight);
            $("#slider").height($("#console").height() - 20);

            $(window).resize(function() {
                $("#console").height($(window).height() - lineHeight);
                $("#console").attr({ scrollTop: $("#console").attr("scrollHeight") });
                $("#slider").height($("#console").height() - 20);
            });

            $("#line").ajaxError(function(event, request, settings) {
                $(this).append("<li>Error requesting page " + settings.url + "</li>");
            });

            $("#slider").slider({
                orientation: "vertical",
                min: 0,
                max: 1000000,
                value: 1000000,
                slide: function(event, ui) {
                    var ratio = (1000000 - ui.value) / 1000000;
                    $("#console").attr({ scrollTop: ratio * ($("#console").attr("scrollHeight") - $("#console").height())});
                }
            });

            $("#slider").bind('slidestop', function(event, ui) {
                $("#line").focus();
            });

            $("#slider").slider('disable');

            $(document).keyup(function(event) {
                if (event.keyCode == 13 && $("#line").val().length > 0) {
                    commandHistory.push($("#line").val());
                    commandCursor = commandHistory.length - 1;
                    $("#console").append("<span class=\"command\">" + $("#line").val() + "</span>\n");
                    $.ajax({
                        type: "POST",
                        url: "shell-interpret.do",
                        data: { line: $("#line").val() },
                        success: function(data) {
                            $("#console").append(data);
                            $("#console").attr({ scrollTop: $("#console").attr("scrollHeight") });
                            if ($("#console").attr("scrollHeight") - 16 > $("#console").height()) {
                                $("#slider").slider('enable');
                                $("#slider").slider('value', 0);
                            } else {
                                $("#slider").slider('disable');
                                $("#slider").slider('value', 1000000);
                            }
                            $("#currentNode").load("shell-current-node.do");
                        },
                        error: function(XMLHttpRequest) {
                            var end = -1;
                            var start = XMLHttpRequest.responseText.indexOf("<div id=\"exception\">");
                            if (start > -1) {
                                end = XMLHttpRequest.responseText.indexOf("</div>", start);
                            }
                            if (end > -1) {
                                $("#console").append("<span class=\"error\">" + XMLHttpRequest.responseText.substring(start + 20, end) + "</span>\n");
                            } else {
                                $("#console").append("<span class=\"error\">" + XMLHttpRequest.status + "</span>\n");
                            }
                            $("#console").attr({ scrollTop: $("#console").attr("scrollHeight") });
                            if ($("#console").attr("scrollHeight") - 16 > $("#console").height()) {
                                $("#slider").slider('enable');
                                $("#slider").slider('value', 0);
                            } else {
                                $("#slider").slider('disable');
                                $("#slider").slider('value', 1000000);
                            }
                        }
                    });

                    $("#line").val("");
                }
                if (event.keyCode == 27) {
                    $("#console").html(welcomeMessage);
                    $("#slider").slider('disable');
                    $("#slider").slider('value', 1000000);
                }
                if (event.keyCode == 38) {
                    $("#line").val(commandHistory[commandCursor]);
                    commandCursor = Math.max(0, commandCursor - 1);
                }
                if (event.keyCode == 40) {
                    commandCursor = Math.min(commandHistory.length - 1, commandCursor + 1);
                    $("#line").val(commandHistory[commandCursor]);
                }
            });
        });

    </script>

    <style type="text/css">

        body {
            overflow: hidden;
            margin: 0;
            padding: 0;
        }

        #console {
            width: 99%;
            overflow: hidden;
            white-space: pre;
            font-family: monospace;
            margin: 0;
            padding: 8px;
            background: black;
            color: #99ff00;
            z-index: 0;
        }

        #slider {
            position: absolute;
            top: 20px;
            right: 10px;
            z-index: 10;
        }

        #lineForm {
            width: 100%;
            margin: 0;
            padding: 0;
            background: black;
        }

        #line {
            width: 100%;
            border: 1px solid black;
            padding: 8px;
            background: black;
            font-size: 2em;
            color: white;
        }

        #currentNode {
            position: absolute;
            top: 4px;
            right: 35px;
            font-size: 2em;
            z-index: 100;
            color: #99ff00;
        }

        #logout {
            position: absolute;
            top: 4px;
            right: 150px;
            font-size: 2em;
            z-index: 100;
            color: #99ff00;
        }

        #logout a {
            color: #99ff00;
        }

        #status {
            margin: 8px;
        }

        .command {
            color: white;
        }

        .error {
            color: red;
        }

    </style>

</head>
<body>

<div id="console">${welcome}</div>

<div id="slider"></div>

<form id="lineForm" action="#" onsubmit="return false;">
    <div id="logout"><a href="/j_spring_security_logout">logout</a></div>
    <div id="currentNode">?</div>
    <input id="line" type="text" name="line" value=""/>
</form>

</body>
</html>