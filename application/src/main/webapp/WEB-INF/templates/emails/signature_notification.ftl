[#ftl encoding="UTF-8"]
<html>
<body>

<h1>Brutet Sigill</h1>

<p>
    [#if modifier??]${modifier.firstname!("Person #"+modifier.id)} ${modifier.lastname!""}[#if modifier.email??](${modifier.email})[/#if][#else]Någon[/#if] har [#if method == "update"]modifierat[#else]raderat[/#if]
    en post av typen <em>${nodeMap.nodeClass}</em> som har signerats utav dig.
</p>

</body>
</html>