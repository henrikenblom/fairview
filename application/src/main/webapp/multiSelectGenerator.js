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
    multiSelectForm.append(formFieldset(unitId));

    return multiSelectForm;
}

function formFieldset(unitId){
    var fieldset = $('<fieldset>');
    fieldset.append(createSelect(unitId));
    fieldset.append(createHidden(unitId));
    fieldset.append(createSubmitComponent());
    return fieldset;
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

function createSubmitComponent(){
    var submitComponent = $('<div>');
    submitComponent.append(createSubmitButton());
    submitComponent.append(createSavedSpan());
    return submitComponent;
}

function createSubmitButton(){
    var submit = $('<input>');
    submit.attr("type", "submit");
    submit.attr("name", "submit");
    submit.attr("class", "button");
    submit.attr("id", "submit_btn");
    submit.attr("value", "Spara");
    return submit;
}
function createSavedSpan(){
    var span = $('<span>');
    span.attr("style", "display: none; color: green");
    span.attr("id", "savedSpan");
    span.attr("class", "savedSpan");
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