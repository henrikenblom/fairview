[#ftl encoding="UTF-8" attributes={'content_type' : 'text/html; charset=utf-8'}]<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html
        PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
    [#assign springTags=JspTaglibs["http://www.springframework.org/tags"]]
    [#assign springFormTags=JspTaglibs["http://www.springframework.org/tags/form"]]
    [#assign securityTags=JspTaglibs["http://www.springframework.org/security/tags"]]
    [#import "../macros/spring.ftl" as spring /]
    <title>Borkk!!</title>
</head>
<body>
[@securityTags.authorize ifAllGranted="ROLE_ADMIN"]
<div id="exception">${exception}</div>
<div id="exceptionClass">${exception.getClass()}</div>
<div id="exceptionMessage">${exception.getMessage()!""}</div>
<div id="exceptionStackTrace">
    <table>
        [#list exception.getStackTrace() as stackTraceElement]
        <tr>
            <td>${stackTraceElement.getFileName()!""}</td>
            <td>[#if stackTraceElement.getLineNumber() > -1]${stackTraceElement.getLineNumber()}[/#if]</td>
            <td>${stackTraceElement.getClassName()}</td>
            <td>${stackTraceElement.getMethodName()}</td>
        </tr>
        [/#list]
    </table>
</div>
[/@securityTags.authorize]

[@securityTags.authorize ifNotGranted="ROLE_ADMIN"]Ouch![/@securityTags.authorize]

</body>
</html>