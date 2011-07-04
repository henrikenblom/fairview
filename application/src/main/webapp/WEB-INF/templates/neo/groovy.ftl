[#ftl encoding="UTF-8" attributes={'content_type' : 'text/html; charset=utf-8'}]<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html
        PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">

<head>

    <title>Groovy</title>

    [#global groovy ="com.fairviewiq.spring.freemarker.GroovyDirective"?new()]

</head>

<body>

<form action="groovy.do" method="POST">
    <textarea name="g" rows="40" cols="80">${RequestParameters.g!""}</textarea>
    <br/>
    <input type="submit" name="s" value="Run!"/>
</form>

[#if RequestParameters.g??]
<pre>[@groovy]${RequestParameters.g}[/@groovy]</pre>
[/#if]

</body>
</html>