function fieldLabelBox() {
    return $('<div class="field-label-box">');
}
function fieldBox() {
    return $('<div class="field-box">');
}
function textInputComponent(labelText, inputName, value) {
    var inputDiv = fieldBox();
    var inputLabel = fieldLabelBox();
    inputLabel.append(labelText);
    var textInput = $('<input type="text">');
    textInput.addClass("text-field");
    textInput.attr("id", inputName + "-field");
    textInput.attr("name", inputName);
    textInput.val(value);

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
function getData(unitId) {
    var data = $.parseJSON($.ajax({
        url:"neo/ajax/get_node.do",
        data:{_nodeId:unitId},
        async:false,
        dataType:"json"
    }).responseText);
    return data;
}
function generateUpdateForm(id) {
    updateForm = $('<form>');
    updateForm.attr("id", id);
    updateForm.attr("action", "neo/ajax/update_properties.do");
    updateForm.attr("method", "post");
    return updateForm;
}
/**
 * Created by IntelliJ IDEA.
 * User: fairview
 * Date: 7/7/11
 * Time: 11:09 AM
 * To change this template use File | Settings | File Templates.
 */


function generateBaseForm(unitId) {    //components shared between main and sub -organizations

    var data = getData(unitId);

    var properties = data.node.properties;

    generateUpdateForm('organizationForm');

    var fieldSet = $('<fieldset>');

    var hiddenField_id = hiddenField('_id', data.node);  //TODO: är data.node rätt ?
    var hiddenField_type = hiddenField('_type', 'node');
    var hiddenField_strict = hiddenField('_strict', 'true');
    var hiddenField_username = hiddenField('_username', 'admin');

    var descriptionDiv = fieldBox();
    descriptionDiv.attr("id", "descriptionDiv");
    var descriptionLabel = fieldLabelBox();
    descriptionLabel.append('Beskrivning');
    var descriptionInput = $('<textarea id="description-field" name="description">');
    descriptionInput.val(propValue(properties.description))
    descriptionDiv.append(descriptionLabel, descriptionInput, $('<br>'));

    var nameDiv = textInputComponent('Namn', 'name', propValue(properties.name));
    var phoneDiv = textInputComponent('Telefonnummer', 'phone', propValue(properties.phone));
    var faxDiv = textInputComponent('Faxnummer', 'fax', propValue(properties.fax));
    var emailDiv = textInputComponent('E-post', 'e-mail', propValue(properties.email));
    var webDiv = textInputComponent('Hemsida', 'web', propValue(properties.web));

    //adds the elements to the fieldset -> the order of the elements appended equals the order of the elements displayed on the page
    fieldSet.append(hiddenField_id, hiddenField_strict, hiddenField_type, hiddenField_username, nameDiv, '<br/>', descriptionDiv, '<br/>', phoneDiv, '<br/>', faxDiv, '<br/>',
        emailDiv, '<br/>', webDiv, '<br/>');
    updateForm.append(fieldSet);
    return updateForm;
}


//components that are specific to either mainorganizations or subunits

function generateOrgNrDiv(unitId) {
    var data = getData(unitId);
    var properties = data.node.properties;

    var orgnrDiv = textInputComponent('Organisationsnummer', 'regnr', propValue(properties.regnr));
    return orgnrDiv;
}

function generateSubUnitAddressComponent(unitId) {
    var data = getData(unitId);
    var properties = data.node.properties;

    var addressDiv = textInputComponent('Adress', 'address', propValue(properties.address));
    var postnummerDiv = textInputComponent('Postnummer', 'postalcode', propValue(properties.postalcode));
    var cityDiv = textInputComponent('Ort', 'city', propValue(properties.city));
    var countryDiv = textInputComponent('Land', 'country', propValue(properties.country));

    addressDiv.append(postnummerDiv, cityDiv, countryDiv);
    return addressDiv;
}

function generateMainOrganizationAddressComponent(labelText, unitId, name, value) {
    var addressDescriptionDiv = textInputComponent(labelText, name, value);
    addressDescriptionDiv.children('#' + name + '-field').attr("id", name + "-field" + unitId);
//    $('#'+name+'-field').attr("id", name + "-field" + unitId);
    return addressDescriptionDiv;
}



