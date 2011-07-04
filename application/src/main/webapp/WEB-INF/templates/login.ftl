[#ftl encoding="UTF-8" attributes={'content_type' : 'text/html; charset=utf-8'}]<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html
        PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">

<head>

    [#assign spring=JspTaglibs["http://www.springframework.org/tags"]]

    <title>[@spring.message code="login"/]</title>

</head>

<body>

    <h3>[@spring.message code="login"/]</h3>

    <form id="login" name="login" action="/j_spring_security_check" method="POST">
        <table>
            <tr>
                <td align="right">
                    <label for="j_username">[@spring.message code="username"/]:</label>
                </td>
                <td>
                    <input id="j_username" name="j_username" type="text" value="${SPRING_SECURITY_LAST_USERNAME!""}" class="required" minlength="4"/>
                </td>
            </tr>
            <tr>
                <td align="right">
                    <label for="j_password">[@spring.message code="password"/]:</label>
                </td>
                <td>
                    <input id="j_password" name="j_password" type="password" class="required"/>
                </td>
            </tr>
            <tr>
                <td align="right">
                </td>
                <td>
                    <input type="checkbox" name="_spring_security_remember_me"/> [@spring.message code="remember_me"/]
                </td>
            </tr>
            <tr>
                <td align="right">
                </td>
                <td>
                    <input  type="submit" name="submit" value="[@spring.message code="login"/]" class="ui-state-default"/>
                </td>
            </tr>
            [#if SPRING_SECURITY_LAST_EXCEPTION??]
            <tr>
                <td align="right">
                </td>
                <td>
                    <span id="login-error">[@spring.message code="bad_credentials"/]<span>
                </td>
            </tr>
            [/#if]

        </table>
    </form>

</body>

</html>


