/**
 * Created by IntelliJ IDEA.
 * User: danielwallerius
 * Date: 2011-09-06
 * Time: 14.32
 * To change this template use File | Settings | File Templates.
 */

///////////////// creating html ////////////////////
function generateFunctionMultiSelectForm(unitId){
    var multiSelectForm = $('<form>');
    multiSelectForm.attr("id", "functionForm");
    multiSelectForm.attr("action", "");
    multiSelectForm.attr("method", "post");
    var fieldset = $('<fieldset>');
    var select = createSelect(unitId);
    fieldset.append(select);
    var hidden = createHidden(unitId);
    fieldset.append(hidden);
    var submitDiv = $('<div>')
    var submit = createSubmitBtn();
    submitDiv.append(submit);
    var span = createSavedSpan();
    submitDiv.append(span);
    fieldset.append(submitDiv);
    multiSelectForm.append(fieldset);

    return multiSelectForm;
}

function createSelect(unitId){
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
    });
    return select;
}

function createHidden(unitId){
    var hidden = $('<input>');
    hidden.attr("type", "hidden");
    hidden.attr("value", unitId);
    hidden.attr("name", "_unitId");
    return hidden;
}

function createSubmitBtn(){
    var submit = $('<input>');
    submit.attr("type", "submit");
    submit.attr("name", "submit");
    submit.attr("class", "button");
    submit.attr("id", "submit_btn");
    submit.attr("value", "Skicka");
    return submit;
}
function createSavedSpan(){
    var span = $('<p>');
    span.attr("style", "display: none; color: red");
    span.attr("id", "savedSpan");
    span.append("Sparad");
    return span;
}

/////////////////// Logic /////////////////////////////////

function getDataUpdateDatabase(_unitId) {
    $('#functionForm').click().ajaxForm(function() {
        var functionIds = new Array();
        var data = "[";
        var multi = false;

        $.each($('#functionMultiselectms2side__dx option'), function(i) {
            if (multi) {
                data += ",";
            }
            data += $(this).val();
            multi = true;
        });
        data += "]";
        $.getJSON('fairview/ajax/set_multiselect_functions.do', {_functionIds:data, _unitId:_unitId}, function(json){
                                    $("#submit_btn").attr('disabled', true).css({ opacity: 0.5 }).delay('2000').queue(function(n){
                                        $(this).removeAttr('disabled').css({ opacity: 1 });
                                        n();
                                    });
                                    $("#savedSpan").show().fadeOut(5000);
        });
    });
}

function initDoubleBoxes() {
    $('#multiSelect').multiselect2side({
        selectedPosition: 'right',
        moveOptions: false,
        labelsx: '',
        labeldx: '',
        autoSort: true,
        autoSortAvailable: true
    });
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