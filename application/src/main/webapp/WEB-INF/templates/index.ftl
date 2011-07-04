[#ftl encoding="UTF-8" attributes={'content_type' : 'text/html; charset=utf-8'}]<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html
        PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">

<head>
    [#assign securityTags=JspTaglibs["http://www.springframework.org/security/tags"]]
    [#assign organization=neo.referenceNode.HAS_ORGANIZATION_OUTGOING[0].endNode]
    [#assign user=neoSearch.getNodes("username:${userPrincipal.name}")[0]]

    [#macro text code]${springMacroRequestContext.getMessage(code, code)}[/#macro]
    <title>V&auml;lkommen ${user.firstname!""} ${user.lastname!""}</title>

</head>
<body>

<table border="0" cellpadding="0" cellspacing="20">
    <tr>

        <td valign="top">

            [#if organization.logo_url??]<img src="${organization.logo_url}" border="0"/>[/#if]

            <h2>${organization.name!""}</h2>

            [#if organization.web??]<a href="${organization.web}">${organization.web}</a>[/#if]

            [#foreach relationship in (organization.HAS_ADDRESS)![]]
            [#assign address=relationship.endNode/]
            <p>
                [#if address.description??]<strong>${address.description}</strong><br/>[/#if]
                [#if address.address??]${address.address}<br/>[/#if]
                ${address.postalcode!""} ${address.city!""}<br/>
                [#if address.country??]${address.country}<br/>[/#if]
            </p>
            [/#foreach]

        </td>

        <td valign="top">

            <h2>V&auml;lkommen ${user.firstname!""} ${user.lastname!""}</h2>

            [@securityTags.authorize ifAllGranted="ROLE_EMPLOYEE"]
            <strong>Allm&auml;nt</strong>
            <ul>
                <li><a href="/reports/foretag.html">F&ouml;retag</a></li>
                <li><a href="/reports/kontaktuppgifter.html">Kontaktuppgifter</a></li>
                <li><a href="/reports/policy.html">Policydokument</a></li>
            </ul>
            [/@securityTags.authorize]

            [@securityTags.authorize ifAllGranted="ROLE_HR"]
            <strong>Personal</strong>
            <ul>
                <li><a href="/reports/narvaro.html">N&auml;rvaro</a></li>
                <li><a href="/reports/anstallningsuppgifter.html">Anst&auml;llningsuppgifter</a></li>
                <li><a href="/reports/arbetsbeskrivningar.html">Arbetsbeskrivningar</a></li>
                <li><a href="/reports/cvs.html">CV</a></li>
                <li><a href="/reports/medarbetarsamtal.html">Medarbetarsamtal</a></li>
                <li><a href="/reports/kompetens.html">Kompetens</a></li>
                <li><a href="/reports/halsa.html">H&auml;lsa</a></li>
            </ul>
            [/@securityTags.authorize]

            [@securityTags.authorize ifAllGranted="ROLE_MANAGER"]
            <strong>Grupp</strong>
            <ul>
                <li><a href="/reports/narvaro-chef.html?id=${user.id}">N&auml;rvaro</a></li>
                <li><a href="/reports/kontaktuppgifter-chef.html?id=${user.id}">Kontaktuppgifter</a></li>
                <li><a href="/reports/anstallningsuppgifter-chef.html?id=${user.id}">Anst&auml;llningsuppgifter</a></li>
                <li><a href="/reports/arbetsbeskrivningar-chef.html?id=${user.id}">Arbetsbeskrivningar</a></li>
                <li><a href="/reports/cvs-chef.html?id=${user.id}">CV</a></li>
                <li><a href="/reports/medarbetarsamtal-chef.html?id=${user.id}">Medarbetarsamtal</a></li>
                <li><a href="/reports/kompetens-chef.html?id=${user.id}">Kompetens</a></li>
                <li><a href="/reports/mal-chef.html?id=${user.id}">Personliga m&aring;l</a></li>
                <li><a href="/reports/halsa-chef.html?id=${user.id}">H&auml;lsa</a></li>
            </ul>
            [/@securityTags.authorize]

            [@securityTags.authorize ifAllGranted="ROLE_EMPLOYEE"]
            <strong>Min Profil</strong>
            <ul>
                <li><a href="/reports/anstallning.html?id=${user.id}">Min anst&auml;llning</a></li>
                <li><a href="/reports/arbetsbeskrivning.html?id=${user.id}">Min arbetsbeskrivning</a></li>
                <li><a href="/reports/cv.html?id=${user.id}">Mitt CV</a></li>
                <li><a href="/edit/cv/index.do?employee=${user.id}">Revidera mitt CV</a></li>
                <li><a href="/reports/mal.html?id=${user.id}">Mina m&aring;l</a></li>
            </ul>
            [/@securityTags.authorize]

        </td>

    </tr>
</table>
</body>
</html>