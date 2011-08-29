/**
 * Created by IntelliJ IDEA.
 * User: fairview
 * Date: 7/7/11
 * Time: 11:09 AM
 * To change this template use File | Settings | File Templates.
 */

function generateBaseUnitEditForm(data) {

    var unitId = data.node.id;
    var formId = getOrganizationFormId();
    var properties = data.node.properties;

    var updateForm = generateUpdateForm(formId);

    var fieldSet = $('<fieldset>');

    var hiddenField_id = hiddenField('_id', unitId);
    var hiddenField_type = hiddenField('_type', 'node');
    var hiddenField_strict = hiddenField('_strict', 'true');
    var hiddenField_username = hiddenField('_username', 'admin');

    var descriptionDiv = textAreaInputComponent('Beskrivning', 'description', propValue(properties.description), formId, 'descriptionDiv');

    var nameDiv = textInputComponent('Namn', 'name', propValue(properties.name), formId);
    editTreeNamesOnChange(nameDiv, unitId);
    var phoneDiv = textInputComponent('Telefonnummer', 'phone', propValue(properties.phone), formId);
    var faxDiv = textInputComponent('Faxnummer', 'fax', propValue(properties.fax), formId);
    var emailDiv = textInputComponent('E-post', 'email', propValue(properties.email), formId);
    var webDiv = textInputComponent('Hemsida', 'web', propValue(properties.web), formId);

    //adds the elements to the fieldset -> the order of the elements appended equals the order of the elements displayed on the page
    fieldSet.append(hiddenField_id, hiddenField_strict, hiddenField_type, hiddenField_username, nameDiv, '<br/>', descriptionDiv, '<br/>', phoneDiv, '<br/>', faxDiv, '<br/>',
        emailDiv, '<br/>', webDiv, '<br/>');
    updateForm.append(fieldSet);
    return updateForm;
}

function generateSubunitCreationForm() {
    var formId = 'subunitform';
    var form = generateUpdateForm(formId);
    var fieldSet = $('<fieldset>');

    var hiddenField_id = hiddenField('_id', '');
    var hiddenField_type = hiddenField('_type', 'node');
    var hiddenField_strict = hiddenField('_strict', 'true');
    var hiddenField_username = hiddenField('_username', 'admin');
    var hiddenField_nodeClass = hiddenField('nodeClass', 'unit');

    var descriptionDiv = textAreaInputComponent('Beskrivning', 'description', '', formId, 'descriptionDiv');

    var nameDiv = textInputComponent('Namn', 'name', '', formId);
    var phoneDiv = textInputComponent('Telefonnummer', 'phone', '', formId);
    var faxDiv = textInputComponent('Faxnummer', 'fax', '', formId);
    var emailDiv = textInputComponent('E-post', 'email', '', formId);
    var webDiv = textInputComponent('Hemsida', 'web', '', formId);

    var addressDiv = textInputComponent('Adress', 'address', '', getOrganizationFormId());
    var postnummerDiv = textInputComponent('Postnummer', 'postalcode', '', getOrganizationFormId());
    var cityDiv = textInputComponent('Ort', 'city', '', getOrganizationFormId());
    var countryDiv = textInputComponent('Land', 'country', '', getOrganizationFormId());

    fieldSet.append(hiddenField_id, hiddenField_nodeClass, hiddenField_strict, hiddenField_type, hiddenField_type,
        hiddenField_username, nameDiv, '<br/>', descriptionDiv, '<br/>', phoneDiv, '<br/>', faxDiv, '<br/>', emailDiv,
        '<br/>', webDiv, '<br/>', addressDiv, '<br/>', postnummerDiv, '<br/>', cityDiv, '<br/>', countryDiv, '<br/>');
    form.append(fieldSet);
    return form;
}


function generateProfileEmploymentInfoForm(data) {
    var formId = 'profile_form';
    var unitId = data.node.id;
    var properties = data.node.properties;

    var form = generateUpdateForm(formId);
    var fieldSet = $('<fieldset>');

    var hiddenField_id = hiddenField('_id', unitId);
    var hiddenField_type = hiddenField('_type', 'node');
    var hiddenField_strict = hiddenField('_strict', 'false');
    var hiddenField_username = hiddenField('_username', 'admin');
    var hiddenField_birthday = hiddenField('birthday', properties.birthday);

    var firstNameDiv = textInputComponent('Förnamn', 'firstname', propValue(properties.firstname), formId);
    var lastNameDiv = textInputComponent('Efternamn', 'lastname', propValue(properties.lastname), formId);
    var nationalityDiv = textInputComponent('Nationalitet', 'nationality', propValue(properties.nationality), formId);
    var employmentIdDiv = textInputComponent('Anställningsnummer', 'employmentid', propValue(properties.employmentid), formId);
    var civicDiv = textInputComponent('Personnummer', 'civic', propValue(properties.civic), formId);
    var addressDiv = textInputComponent('Adress', 'address', propValue(properties.address), formId);
    var zipDiv = textInputComponent('Postnummer', 'zip', propValue(properties.zip), formId);

    var cityDiv = textInputComponent('Postort', 'city', propValue(properties.city), formId);
    var countryDiv = textInputComponent('Land', 'country', propValue(properties.country), formId);
    var phoneDiv = textInputComponent('Telefon', 'phone', propValue(properties.phone), formId);
    var cellDiv = textInputComponent('Mobiltelefon', 'cell', propValue(properties.cell), formId);
    var emailDiv = textInputComponent('E-post', 'email', propValue(properties.email), formId);
    //          FUNKTION placeholder
    var fromdateDiv = textInputComponent('Från datum', 'fromdate', propValue(properties.fromdate), formId);
    var todateDiv = textInputComponent('Till datum', 'todate', propValue(properties.todate), formId);
    // Anställningsform
    var additional_infoDiv = textAreaInputComponent('Övrigt', 'additional_info', propValue(properties.additional__info), formId, 'additional_infoDiv');

    var genderDiv = selectInputComponent('Kön', 'gender', 'genderDiv', formId);
    addGenderOptions(properties.gender, genderDiv.children('#gender-field'));

    var assignedFunctionId = getFunctionId(unitId).long;
    var functionDiv = functionSelectInputComponent('Funktion', 'function', 'functionDiv', unitId);
    addFunctionOptions(functionDiv.children('#function-field'), unitId, assignedFunctionId);


    fieldSet.append(hiddenField_id, hiddenField_strict, hiddenField_type, hiddenField_username, hiddenField_birthday,
        firstNameDiv, '<br/>', lastNameDiv, '<br/>', nationalityDiv, '<br/>', employmentIdDiv, '<br/>', civicDiv, '<br/>', addressDiv, '<br/>',
        zipDiv, '<br/>', cityDiv, '<br/>', countryDiv, '<br/>', phoneDiv, '<br/>', cellDiv, '<br/>', emailDiv, '<br/>', fromdateDiv, '<br/>',
        todateDiv, '<br/>', additional_infoDiv, '<br/>', genderDiv, '<br/>', functionDiv);

    form.append(fieldSet);
    return form;
}

function addFunctionOptions(functionInputElement, unitId, assignedFunctionId) {
    var func = getFunctions(unitId);

    if (assignedFunctionId == -1) {
        var chooseOption = $('<option>');
        chooseOption.html('Välj...');
        chooseOption.attr('selected', 'true');
        functionInputElement.append(chooseOption);
    }
    if (func.map.entry.length > 1) {
        $.each(func.map.entry, function(nr, value) {
            var functionOption = $('<option>');
            functionOption.attr('value', value.long);
            functionOption.html(value.string);
            if (assignedFunctionId == value.long)
                functionOption.attr('selected', 'true');
            functionInputElement.append(functionOption);
        });
    } else {  //if the map contains only one entry, it is not considered an array by javascript but rather a single value
        var functionOption = $('<option>');
        functionOption.attr('value', func.map.entry.long);
        functionOption.html(func.map.entry.string);
        if (assignedFunctionId == func.map.entry.long)
            functionOption.attr('selected', 'true');
        functionInputElement.append(functionOption);
    }
}

function addGenderOptions(gender, genderInputElement) {
    var optionMan = $('<option>');
    optionMan.attr('value', 'M');
    optionMan.html('Man');
    var optionFemale = $('<option>');
    optionFemale.attr('value', 'F');
    optionFemale.html('Kvinna');
    if (propValue(gender) == 'M')
        optionMan.attr('selected', 'true');
    else if (propValue(gender) == 'F')
        optionFemale.attr('selected', 'true');
    else {
        var optionChooseGender = $('<option>');
        optionChooseGender.html('Välj...');
        genderInputElement.append(optionChooseGender, optionMan, optionFemale);
        return;
    }
    genderInputElement.append(optionMan, optionFemale)
}

function makeBirthdate(civicnumber) {
    if (civicnumber.length > 6)
        return civicnumber.substr(0, 6);
    else
        return civicnumber;
}

function generateTabHeader(name) {
    $('#popup-header').empty().append(name);
    $('#name-field').change(function() {
        $('#popup-header').html(this.value);
    });
}

function fieldLabelBox() {
    return $('<div class="field-label-box">');
}
function fieldBox() {
    return $('<div class="field-box">');
}
function textInputComponent(labelText, inputName, value, formId) {
    var inputDiv = fieldBox();
    var inputLabel = fieldLabelBox();
    inputLabel.append(labelText);
    var textInput = $('<input type="text">');
    textInput.addClass("text-field");
    textInput.attr("id", inputName + "-field");
    textInput.attr("name", inputName);
    textInput.val(value);
    textInput.change(function() {
        $('#' + formId).ajaxSubmit();
    });

    inputDiv.append(inputLabel, textInput);
    return inputDiv;
}
function hiddenField(name, value) {
    var hiddenField = $('<input type="hidden">');
    hiddenField.attr("name", name);
    hiddenField.val(value);
    return hiddenField;
}
function propValue(prop) {
    if ($.isEmptyObject(prop))
        return "";
    else
        return prop.value;
}
function getNodeData(unitId) {
    var data = $.parseJSON($.ajax({
        url:"neo/ajax/get_node.do",
        data:{_nodeId:unitId},
        async:false,
        dataType:"json"
    }).responseText);
    return data;
}
function generateUpdateForm(id) {
    var updateForm = $('<form>');
    updateForm.attr("id", id);
    updateForm.attr("action", "neo/ajax/update_properties.do");
    updateForm.attr("method", "post");
    return updateForm;
}
function textAreaInputComponent(labelText, inputName, value, formId, divId) {
    var textareaDiv = fieldBox();
    textareaDiv.attr("id", divId);
    var textareaLabel = fieldLabelBox();
    textareaLabel.append(labelText);
    var textareaInput = $('<textarea>');
    textareaInput.attr("name", inputName);
    textareaInput.attr("id", inputName + "-field");
    textareaInput.change(function() {
        $('#' + formId).ajaxSubmit();
    });
    textareaInput.val(value)
    textareaDiv.append(textareaLabel, textareaInput, $('<br>'));
    return textareaDiv;
}

function selectInputComponent(labelText, inputName, divId, formId) {
    var selectDiv = fieldBox();
    selectDiv.attr("id", divId);
    var selectLabel = fieldLabelBox();
    selectLabel.append(labelText);
    var selectInput = $('<select>');
    selectInput.attr("name", inputName);
    selectInput.attr("id", inputName + "-field");
    selectInput.change(function() {
        $('#' + formId).ajaxSubmit();
    });
    selectDiv.append(selectLabel, selectInput, $('<br>'));
    return selectDiv;
}

function functionSelectInputComponent(labelText, inputName, divId, employeeId) {
    var selectDiv = fieldBox();
    selectDiv.attr("id", divId);
    var selectLabel = fieldLabelBox();
    selectLabel.append(labelText);
    var selectInput = $('<select>');
    selectInput.attr("name", inputName);
    selectInput.attr("id", inputName + "-field");
    selectInput.change(function() {
        assignFunction(employeeId, selectInput.val())
    });
    selectDiv.append(selectLabel, selectInput, $('<br>'));
    return selectDiv;
}

function editTreeNamesOnChange(nameDiv, unitId) {
    var nameInput = nameDiv.children('#name-field');
    nameInput.change(function() {
        $('#unitsettings-general-tablink[name=unitsettings-general-tablink' + unitId + ']').empty().append(nameInput.val());
    });
}
function getOrganizationFormId() {
    var formId = 'organizationForm';
    return formId;
}

function generateOrgNrDiv(data) {
    var properties = data.node.properties;

    var orgnrDiv = textInputComponent('Organisationsnummer', 'regnr', propValue(properties.regnr), getOrganizationFormId());
    return orgnrDiv;
}

function generateSubUnitAddressComponent(data) {
    var properties = data.node.properties;

    var addressDiv = textInputComponent('Adress', 'address', propValue(properties.address), getOrganizationFormId());
    var postnummerDiv = textInputComponent('Postnummer', 'postalcode', propValue(properties.postalcode), getOrganizationFormId());
    var cityDiv = textInputComponent('Ort', 'city', propValue(properties.city), getOrganizationFormId());
    var countryDiv = textInputComponent('Land', 'country', propValue(properties.country), getOrganizationFormId());

    addressDiv.append(postnummerDiv, cityDiv, countryDiv);
    return addressDiv;
}

function generateMainOrganizationAddressComponent(labelText, unitId, name, value) {
    var addressDescriptionDiv = textInputComponent(labelText, name, value, 'organization_address_form' + unitId);
    addressDescriptionDiv.children('#' + name + '-field').attr("id", name + "-field" + unitId);
    return addressDescriptionDiv;
}

function getRelationshipData(parentNode) {
    var data = $.parseJSON($.ajax({
        url:"neo/ajax/create_relationship.do",
        data:{_startNodeId:parentNode, _type:"HAS_UNIT"},
        async:false,
        dataType:"json"
    }).responseText);
    return data;
}
function getFunctions(unitId) {
    var data = $.parseJSON($.ajax({
        url:"fairview/ajax/get_functions.do",
        data: {_nodeId: unitId},
        async:false,
        dataType:"json"
    }).responseText);
    return data;
}

function getFunctionId(unitId) {
    var data = $.parseJSON($.ajax({
        url:"fairview/ajax/get_functionId.do",
        data: {_nodeId: unitId},
        async:false,
        dataType:"json"
    }).responseText);
    return data;
}

function assignFunction(unitId, functionId) {
    $.getJSON("fairview/ajax/unassign_function.do", {_nodeId: unitId}, function(data) {
        $.getJSON("neo/ajax/create_relationship.do", {_startNodeId:unitId, _type:"HAS_EMPLOYMENT" }, function(dataEmployment) {
            $.getJSON("fairview/ajax/assign_function.do", {employment:dataEmployment.relationship.endNode, "function:relationship":functionId, percent:100});
        });
    });
}