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
    [#macro text code]${springMacroRequestContext.getMessage(code, code)}[/#macro]
    <title>[@text code="label.reports"/]</title>

    <script type="text/javascript">
        $(document).ready(function() {
            $("#tabs").tabs();
        });
    </script>

</head>
<body>

<h1>[@text code="label.reports"/]</h1>

<div id="tabs">

    <ul>
        [#foreach category in reports?keys]
        <li><a href="#tabs-${category_index}">${category}</a></li>
        [/#foreach]
    </ul>

    [#foreach category in reports?keys]

    <div id="tabs-${category_index}">

        [#foreach report in reports[category]]

        [@securityTags.authorize ifAllGranted="ROLE_ADMIN"]
        <p>
            <a href="${report.file?replace(".jasper",".html")}">${report.name!report.file}</a><br/>
            ${report.description!"unkown"}
            <br/><a
                href="delete.do?file=${report.file}">[[@text code="label.delete"/] ${report.name!report.file}]</a>
        </p>
        [/@securityTags.authorize]

        [@securityTags.authorize ifNotGranted="ROLE_ADMIN"]
        [#if !report.description?starts_with("subreport")]
        <p>
            <a href="${report.file?replace(".jasper",".html")}">${report.name!"unkown"}</a><br/>
            ${report.description!""}
        </p>
        [/#if]
        [/@securityTags.authorize]

        [/#foreach]

    </div>

    [/#foreach]

</div>

[@securityTags.authorize ifAllGranted="ROLE_ADMIN"]

<h1>[@text code="label.reports-upload"/]</h1>

[#if file??]
${file.originalFilename} [@text code="label.reports-upload-ok"/]
[/#if]

<form method="post" action="upload.do" enctype="multipart/form-data">
    <input type="file" name="file"/>
    <input type="submit" name="submit" value="[@text code="label.reports-upload-submit"/]"/>
</form>

[/@securityTags.authorize]
</body>
</html>