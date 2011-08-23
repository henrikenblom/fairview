/**
 * Created by IntelliJ IDEA.
 * User: fairview
 * Date: 7/7/11
 * Time: 11:09 AM
 * To change this template use File | Settings | File Templates.
 */

function generateBaseEditForm(data) {

    var unitId = data.node.id;
    var formId = getFormId();
    var properties = data.node.properties;

    var updateForm = generateUpdateForm(formId);

    var fieldSet = $('<fieldset>');

    var hiddenField_id = hiddenField('_id', unitId);
    var hiddenField_type = hiddenField('_type', 'node');
    var hiddenField_strict = hiddenField('_strict', 'true');
    var hiddenField_username = hiddenField('_username', 'admin');

    var descriptionDiv = generateDescriptionDiv(formId, properties);

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

    var descriptionDiv = generateDescriptionDiv(formId, null);

    var nameDiv = textInputComponent('Namn', 'name', '', formId);
    var phoneDiv = textInputComponent('Telefonnummer', 'phone', '', formId);
    var faxDiv = textInputComponent('Faxnummer', 'fax', '', formId);
    var emailDiv = textInputComponent('E-post', 'email', '', formId);
    var webDiv = textInputComponent('Hemsida', 'web', '', formId);

    var addressDiv = textInputComponent('Adress', 'address', '', getFormId());
    var postnummerDiv = textInputComponent('Postnummer', 'postalcode', '', getFormId());
    var cityDiv = textInputComponent('Ort', 'city', '', getFormId());
    var countryDiv = textInputComponent('Land', 'country', '', getFormId());

    fieldSet.append(hiddenField_id, hiddenField_nodeClass, hiddenField_strict, hiddenField_type, hiddenField_type,
        hiddenField_username, nameDiv, '<br/>', descriptionDiv, '<br/>', phoneDiv, '<br/>', faxDiv, '<br/>', emailDiv,
        '<br/>', webDiv, '<br/>', addressDiv, '<br/>', postnummerDiv, '<br/>', cityDiv, '<br/>', countryDiv, '<br/>');
    form.append(fieldSet);
    return form;
}

function generateTabHeader(name) {
    $('#unitsettings-header').empty().append(name);
    $('#name-field').change(function() {
        $('#unitsettings-header').html(this.value);
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
function generateDescriptionDiv(formId, properties) {
    var descriptionDiv = fieldBox();
    descriptionDiv.attr("id", "descriptionDiv");
    var descriptionLabel = fieldLabelBox();
    descriptionLabel.append('Beskrivning');
    var descriptionInput = $('<textarea id="description-field" name="description">');
    descriptionInput.change(function() {
        $('#' + formId).ajaxSubmit();
    });
    if (properties != null)
        descriptionInput.val(propValue(properties.description))
    descriptionDiv.append(descriptionLabel, descriptionInput, $('<br>'));
    return descriptionDiv;
}
function editTreeNamesOnChange(nameDiv, unitId) {
    var nameInput = nameDiv.children('#name-field');
    nameInput.change(function() {
        $('#unitsettings-general-tablink[name=unitsettings-general-tablink' + unitId + ']').empty().append(nameInput.val());
    });
}
function getFormId() {
    var formId = 'organizationForm';
    return formId;
}

function generateOrgNrDiv(data) {
    var properties = data.node.properties;

    var orgnrDiv = textInputComponent('Organisationsnummer', 'regnr', propValue(properties.regnr), getFormId());
    return orgnrDiv;
}

function generateSubUnitAddressComponent(data) {
    var properties = data.node.properties;

    var addressDiv = textInputComponent('Adress', 'address', propValue(properties.address), getFormId());
    var postnummerDiv = textInputComponent('Postnummer', 'postalcode', propValue(properties.postalcode), getFormId());
    var cityDiv = textInputComponent('Ort', 'city', propValue(properties.city), getFormId());
    var countryDiv = textInputComponent('Land', 'country', propValue(properties.country), getFormId());

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