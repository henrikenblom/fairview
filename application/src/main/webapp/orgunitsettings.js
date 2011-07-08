function fieldLabelBox() {
    return $('<div class="field-label-box">');
}
function fieldBox() {
    return $('<div class="field-box">');
}
function textInputComponent(labelText, inputId, value) {
    var inputDiv = fieldBox();
    var inputLabel = fieldLabelBox();
    inputLabel.append(labelText);
    var nameinput = $('<input type="text">');
    nameinput.addClass("text-field");
    nameinput.attr("id", inputId+"-field");
    nameinput.attr("name", inputId);
    nameinput.val(value);

    inputDiv.append(inputLabel, nameinput);
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
/**
 * Created by IntelliJ IDEA.
 * User: fairview
 * Date: 7/7/11
 * Time: 11:09 AM
 * To change this template use File | Settings | File Templates.
 */


function generateOrgUnitForm(unitId) {    //or organization.id if organization

    var data = $.parseJSON($.ajax({
        url:"neo/ajax/get_node.do",
        data:{_nodeId:unitId},
        async:false,
        dataType:"json"
    }).responseText);

    var props = data.node.properties;

    organizationForm = $('<form id="organizationForm" action="neo/ajax/update_properties.do" method="post">');

    var fieldSet = $('<fieldset>');

    var hiddenField_id = hiddenField('_id', data.node);  //TODO: är data.node rätt ?
    var hiddenField_type = hiddenField('_type', 'node');
    var hiddenField_strict = hiddenField('_strict', 'true');
    var hiddenField_username = hiddenField('_username', 'admin');

    var descriptionDiv = fieldBox();
    var descriptionLabel = fieldLabelBox();
    descriptionLabel.append('Beskrivning');
    var descriptionInput = $('<textarea id="description-field" name="description">');
    descriptionInput.val(propValue(props.description))
    descriptionDiv.append(descriptionLabel, descriptionInput, $('<br>'));


    var nameDiv = textInputComponent('Namn', 'name', propValue(props.name));
    var phoneDiv = textInputComponent('Telefonnummer', 'phone', propValue(props.phone));
    var faxDiv = textInputComponent('Faxnummer', 'fax', propValue(props.fax));
    var emailDiv = textInputComponent('E-post', 'e-mail', propValue(props.email));
    var webDiv = textInputComponent('Hemsida', 'web', propValue(props.web));
    var adressDiv = textInputComponent('Adress', 'adress', propValue(props.adress));
    var postnummerDiv = textInputComponent('Postnummer', 'postalcode', propValue(props.postalcode));
    var cityDiv = textInputComponent('Ort', 'city', propValue(props.city));
    var countryDiv = textInputComponent('Land', 'country', propValue(props.country));

    //the order of the elements appended equals the order of the elements displayed on the page
    fieldSet.append(hiddenField_id, hiddenField_strict, hiddenField_type, hiddenField_username, nameDiv, '<br/>', descriptionDiv, '<br/>', phoneDiv, '<br/>', faxDiv, '<br/>',
        emailDiv, '<br/>', webDiv, '<br/>', adressDiv, '<br/>', postnummerDiv, '<br/>', cityDiv, '<br/>', countryDiv);
    organizationForm.append(fieldSet);
    return organizationForm;
}

