[#ftl encoding="UTF-8" attributes={'content_type' : 'text/html; charset=utf-8'}]

[#-- @ftlvariable name="node" type="org.neo4j.graphdb.Node" --]
[#-- @ftlvariable name="neo" type="org.neo4j.graphdb.GraphDatabaseService" --]

[#assign springTags=JspTaglibs["http://www.springframework.org/tags"]]
[#assign securityTags=JspTaglibs["http://www.springframework.org/security/tags"]]

[#assign organization=neo.referenceNode.HAS_ORGANIZATION_OUTGOING[0].endNode]
[#assign uuid ="se.codemate.spring.freemarker.UUIDDirective"?new()]

[#global options ="com.fairviewiq.spring.freemarker.DynamicOptionsDirective"?new()]
[#global groovy ="com.fairviewiq.spring.freemarker.GroovyDirective"?new()]
[#global functions ="com.fairviewiq.spring.freemarker.FunctionsDirective"?new()]

[#macro text code]${springMacroRequestContext.getMessage(code, code)}[/#macro]

[#macro text2 name label]
${springMacroRequestContext.getMessage("label.${name}.${label}", springMacroRequestContext.getMessage("label.${label}", label))}
[/#macro]

[#macro header class="" type="node" strict=true preserve=""]
<input name="_id" type="hidden" value="${node.id}"/>
<input name="_type" type="hidden" value="${type}"/>
<input name="_strict" type="hidden" value="${strict?string}"/>
[#if preserve?length > 0]
<input name="_preserve" type="hidden" value="${preserve}"/>
[/#if]
<input name="_username" type="hidden" value="[@securityTags.authentication property="principal.username"/]"/>
<input id="properties_form_uuid_node_${node.id}" name="_formUUID" type="hidden" value="[@uuid/]"/>
[#if class?length > 0]
<input id="property_${type}_${node.id}_${type}class" type="hidden" name="${type}Class" value="${class}"/>
[/#if]
[/#macro]

[#macro label name class]
<label for="property_node_${node.id}_${name}">[@text code="label.${name}"/]
    [#if class?index_of("required") != -1]<em>*</em>[/#if]
</label>
[/#macro]

[#macro helppopup name help=""]
[#if help?length == 0]
[#assign helplabel="help_${name}"/]
[#assign helpkey="help.${name}"/]
[#assign helptext=springMacroRequestContext.getMessage("help.${name}","")/]
[#else]
[#assign helplabel="help_${help}"/]
[#assign helpkey="help.${help}"/]
[#assign helptext=springMacroRequestContext.getMessage("help.${help}","")/]
[/#if]
[#if helptext?length > 0]
<span onclick="$('#${helplabel}_${node.id}').toggle('blind', {direction:'vertical'}, 250);" style="color:green"><img src="/images/help.png" width="16" height="16" border="0" alt="help"/></span>
<div id="${helplabel}_${node.id}" class="help" style="display:none">${helptext}</div>
[/#if]
[/#macro]

[#macro input name class="" type="" help=""]
<div id="property_block_node_${node.id}_${name}">
    [@label name class/]
    <input id="property_node_${node.id}_${name}" type="text" name="${name}${type}" class="${class}" value="${(node[name])!""}"/>
    [@helppopup name help/]
</div>
[/#macro]

[#macro date name class="" type="" help=""]
<div id="property_block_node_${node.id}_${name}">
    [@label name class/]
    <input id="property_node_${node.id}_${name}" type="text" name="${name}:date" class="datepicker ${class}" value="${(node[name]?string("yyyy-MM-dd"))!""}"/>
    [@helppopup name help/]
</div>
[/#macro]

[#macro password name class="" type="" default="" help=""]
<div id="property_block_node_${node.id}_${name}">
    [@label name class/]
    <input id="property_node_${node.id}_${name}" type="password" name="${name}${type}" class="${class}" value="${(node[name])!default}"/>
    [@helppopup name help/]
</div>
[/#macro]

[#macro textarea name rows="6" cols="40" class="" type="" help=""]
<div id="property_block_node_${node.id}_${name}">
    [@label name class/]
    <textarea rows="${rows}" cols="${cols}" id="property_node_${node.id}_${name}" name="${name}${type}" class="${class}">${(node[name])!""}</textarea>
    [@helppopup name help/]
</div>
[/#macro]

[#macro select name labels values class="" type="" help="" prefix="" suffix=""]
<div id="property_block_node_${node.id}_${name}">
    [@label name class/]
    ${prefix}<select id="property_node_${node.id}_${name}" name="${name}${type}" class="${class}">
        [#list labels as label]
        <option value="${values[label_index]}" [#if node[name]?? && node[name]?string == values[label_index]]selected="true"[/#if]>[@text2 name label/]</option>
        [/#list]
    </select>${suffix}
    [@helppopup name help/]
</div>
[/#macro]

[#macro dynamicselect name nodeClass="" class="" type="" help="" prefix="" suffix=""]
<div id="property_block_node_${node.id}_${name}">
    [@label name class/]
    ${prefix}<select id="property_node_${node.id}_${name}" name="${name}${type}" class="dynamic_dropdown ${class}">
        [@options class=nodeClass property=name selected=(node[name])!""/]
    </select>${suffix}
    [@helppopup name help/]
</div>
[/#macro]

[#macro checkboxes name labels values class="" help=""]
<div id="property_block_node_${node.id}_${name}">
    [@label name class/]
    [#list labels as label]
    [#assign cname="${name}#${values[label_index]}"]
    <input type="checkbox" name="${name}:checkbox" class="${class}" value="${values[label_index]}" [#if node[cname]?? && node[cname] == true]checked="yes"[/#if]/> [@text2 name label/]
    [/#list]
    [@helppopup name help/]
</div>
[/#macro]

[#macro radiobuttons name labels values class="" type="" help=""]
<div id="property_block_node_${node.id}_${name}">
    [@label name class/]
    [#list labels as label]
    <input type="radio" name="${name}${type}" class="${class}" value="${values[label_index]}" [#if node[name]?? && node[name]?string == values[label_index]]checked="yes"[/#if]/> [@text2 name label/]
    [/#list]
    [@helppopup name help/]
</div>
[/#macro]

[#macro selectPosition name class="" help=""]
[#if (node[name][0])??]
[#assign currentPosition=node[name][0].endNode.id/]
[#else]
[#assign currentPosition=-1/]
[/#if]
<p id="property_block_node_${node.id}_${name}">
    [@label name class/]
    <select id="property_node_${node.id}_${name}" name="${name}:relationship" class="${class}">
        <option value="-1" [#if currentPosition == -1] selected="true"[/#if]>-</option>
        [#foreach position in neoSort((organization.HAS_POSITION_OUTGOING)![],"endNode.name")]
        [#if position.endNode.id != node.id]
        <option value="${position.endNode.id}"[#if currentPosition == position.endNode.id] selected="true"[/#if]>
            ${(position.endNode.name)!(position.endNode.id)}
        </option>
        [/#if]
        [/#foreach]
    </select>
    [@helppopup name help/]
</p>
[/#macro]

[#macro selectUnit name class="" help=""]
    [#if (node[name][0])??]
    [#assign currentChild=node[name][0].endNode.id/]
    [#else]
    [#assign currentChild=-1/]
    [/#if]
    <div id="property_block_node_${node.id}_${name}">
        [@label name class/]
        <select id="property_node_${node.id}_${name}" name="${name}:relationship" class="${class}">
            <option value="-1" [#if currentChild == -1] selected="true"[/#if]>-</option>
            [#if organization.HAS_UNIT_OUTGOING??]
            [@selectUnitOptions currentChild name organization.HAS_UNIT_OUTGOING 0/]
            [/#if]
        </select>
        [@helppopup name help/]
    </div>
[/#macro]

[#macro selectUnitOptions currentChild name children depth]
    [#foreach child in children]
    <option value="${child.endNode.id}" [#if currentChild == child.endNode.id]selected="true"[/#if]>
        ${depth}:${(child.endNode.name)!(child.endNode.id)}
    </option>
    [#if child.endNode.HAS_UNIT_OUTGOING??]
    [@selectUnitOptions currentChild name child.endNode.HAS_UNIT_OUTGOING depth+1/]
    [/#if]
    [/#foreach]
[/#macro]

[#macro selectEmployee name class="" help=""]
    [#if (node[name][0])??]
    [#assign currentEmployee=node[name][0].endNode.id/]
    [#else]
    [#assign currentEmployee=-1/]
    [/#if]
    <div id="property_block_node_${node.id}_${name}">
        [@label name class/]
        <select id="property_node_${node.id}_${name}" name="${name}:relationship" class="${class}">
            <option value="-1" [#if currentEmployee == -1] selected="true"[/#if]>-</option>
            [#foreach position in neoSort((organization.HAS_EMPLOYEE_OUTGOING)![],"endNode.lastname","endNode.firstname")]
            [#if position.endNode.id != node.id]
            <option value="${position.endNode.id}"[#if currentEmployee == position.endNode.id] selected="true"[/#if]>
                ${(position.endNode.firstname)!""} ${(position.endNode.lastname)!""} [@functions employee=position.endNode prefix="(" suffix=")" separator=", "/]
            </option>
            [/#if]
            [/#foreach]
        </select>
        [@helppopup name help/]
    </div>
[/#macro]

[#macro selectFunction name class="" help=""]
    [#if (node[name][0])??]
    [#assign currentFunction=node[name][0].endNode.id/]
    [#else]
    [#assign currentFunction=-1/]
    [/#if]
    <div id="property_block_node_${node.id}_${name}">
        [@label name class/]
        <select id="property_node_${node.id}_${name}" name="${name}:relationship" class="${class}">
            <option value="-1" [#if currentFunction == -1] selected="true"[/#if]>-</option>
            [#foreach function in neoSort((organization.HAS_FUNCTION_OUTGOING)![],"endNode.name")]
            [#if function.endNode.id != node.id]
            <option value="${function.endNode.id}"[#if currentFunction == function.endNode.id] selected="true"[/#if]>
                ${(function.endNode.name)!(function.endNode.id)}
            </option>
            [/#if]
            [/#foreach]
        </select>
        [@helppopup name help/]
    </div>
[/#macro]

[#macro componentScript name limit=-1 component="" sort="TS_CREATED" script=""]

    [#assign domName=(name?capitalize)?replace(" ","")/]
    [#assign relationship="HAS_${(name?upper_case)?replace(' ','_')}"/]
    [#if component == ""]
    [#assign comp="${name?lower_case}.do"/]
    [#else]
    [#assign comp="${component?lower_case}.do"/]
    [/#if]

    var ${domName}FormCount = 0;

    $("#add${domName}Button_${node.id}").click(function() {
        if (${limit} == -1 || $("#components${domName}${node.id}  > .properties_edit").size() < ${limit}) {
            $.getJSON("/neo/ajax/create_relationship.do", {_startNodeId:${node.id}, _type:"${relationship}" }, function(data) {
                add${domName}Form${node.id}(data.relationship.endNode);
            });
        }
    });

    function add${domName}Form${node.id}(endNodeId) {
        $.get("/edit/components/${comp}", {id:endNodeId}, function(data) {
            $("#add${domName}Button_${node.id}").after(data);
            $.getScript("/edit/scripts/properties.do?node="+endNodeId);
            [#if script?length > 0]
            $.getScript("/edit/scripts/${script}.do?node="+endNodeId);
            [/#if]
            $("#properties_edit_node_"+endNodeId).show("blind", {direction:"vertical"}, 250);
            $("#properties_edit_node_"+endNodeId).unload(function () {
                ${domName}FormCount--;
                check${domName}Count${node.id}();
            });
            ${domName}FormCount++;
            check${domName}Count${node.id}();
        }, "html");
    }

    function check${domName}Count${node.id}() {
        if (${limit} > 0) {
            if (${domName}FormCount < ${limit}) {
                if ($("#add${domName}Button_${node.id}").css("display") == "none") {
                    $("#add${domName}Button_${node.id}").show("blind", {direction:"vertical"}, 250);
                }
            } else {
                $("#add${domName}Button_${node.id}").hide("blind", {direction:"vertical"}, 250);
            }
        }
    }

    [#foreach r in neoSort((node["${relationship}_OUTGOING"])![],sort)]
        add${domName}Form${node.id}(${r.endNode.id});
    [/#foreach]
    
[/#macro]

[#macro componentButton name]

    [#assign domName=(name?capitalize)?replace(" ","")/]
    [#assign labelName=(name?lower_case)?replace(" ","_")/]

    <div id="components${domName}${node.id}" class="properties_edit_collection">
        <div id="add${domName}Button_${node.id}" class="addButton">[@text code="label.add"/] [@text code="label.${labelName}"/]</div>
    </div>

[/#macro]


