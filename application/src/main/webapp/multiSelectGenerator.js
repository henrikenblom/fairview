/**
 * Created by IntelliJ IDEA.
 * User: danielwallerius
 * Date: 2011-09-06
 * Time: 14.32
 * To change this template use File | Settings | File Templates.
 */

function generateFunctionMultiSelect(unitId){
    var select = $('<select>');
    select.attr("id", "multiSelect");
    select.attr("name", "functionMultiselect");
    select.attr("multiple", "multiple");
    select.attr("size" , 8);
    var functionData = getAllFunctions(unitId).list["com.fairviewiq.utils.MultiSelectFunctionMember"];
    $.each(functionData, function(i){
        var option = $('<option>');
        option.attr("value", functionData[i].functionId);
        if(functionData[i].selected)
            option.attr("selected", "selected");
        option.append(functionData[i].functionName);
        select.append(option);
    })
    return select;
}

function getAllFunctions(unitId){
    var data = $.parseJSON($.ajax({
        url:"/fairview/ajax/get_multiselect_functions.do",
        data:{_unitId:unitId},
        async:false,
        dataType:"json"
    }).responseText);
    return data;
}