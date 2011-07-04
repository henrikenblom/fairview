[#ftl encoding="UTF-8"]
<html>
<body>

<h1>Påmminelse
[#switch type]
[#case "HAS_SALARY_NEGOTIATION"]
Lönesamtal
[#break]
[#case "HAS_EMPLOYEE_DIALOGUE"]
Medarbetarsamtal
[#break]
[#case "HAS_HEALTHCHECK"]
Hälsoundersökning
[#break]
[/#switch]
</h1>

[#if target == "manager"]
[#switch type]
[#case "HAS_SALARY_NEGOTIATION"]
Klicka <a href="${baseURL}/edit/salary/index.do?employee=${employee.id}">här</a> för att boka in nästa Lönesamtal
med ${employee.firstname!("anställd #"+employee.id)} ${employee.lastname!""}.
[#break]
[#case "HAS_EMPLOYEE_DIALOGUE"]
Klicka <a href="${baseURL}/edit/development/index.do?employee=${employee.id}">här</a> för att boka in nästa
Medarbetarsamtal för ${employee.firstname!("anställd #"+employee.id)} ${employee.lastname!""}.
[#break]
[#case "HAS_HEALTHCHECK"]
Nu är det dags att boka hälsoundersökning för ${employee.firstname!("anställd #"+employee.id)} ${employee.lastname!""}.
Hälsokontrollen ska ske hos: xxx
Bokning sker på följande sätt: xxx (kontaktuppgift, tider, länk ifall att bokningen kan ske via Internet osv).
[#break]
[/#switch]
[#else]
[#switch type]
[#case "HAS_SALARY_NEGOTIATION"]
Nu är det dags att boka in nästa Lönesamtal med din
chef, ${manager.firstname!("anställd #"+employee.id)} ${manager.lastname!""}.
[#break]
[#case "HAS_EMPLOYEE_DIALOGUE"]
Nu är det dags att boka in nästa Medarbetarsamtal med din
chef, ${manager.firstname!("anställd #"+employee.id)} ${manager.lastname!""}.
[#break]
[#case "HAS_HEALTHCHECK"]
Nu är det dags att boka en ny hälsoundersökning. Denna påminnelse har även gått till din
chef, ${manager.firstname!("anställd #"+employee.id)} ${manager.lastname!""}.
Hälsokontrollen ska ske hos: xxx
Bokning sker på följande sätt: xxx (kontaktuppgift, tider osv). Denna påminnelse går även till din chef.
[#break]
[/#switch]
[/#if]
</body>
</html>