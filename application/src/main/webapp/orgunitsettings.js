function fieldLabelBox() {
    return $('<div class="field-label-box">');
}
function fieldBox() {
    return $('<div class="field-box">');
}
function textInputComponent(labelText, inputId) {
    var inputDiv = fieldBox();
    var inputLabel = fieldLabelBox();
    inputLabel.append(labelText);
    var nameinput = $('<input type="text" class="text-field" id="'+inputId+'-field" name="'+inputId+'" onchange="" value="">');
    inputDiv.append(inputLabel, nameinput);
    return inputDiv;
}
/**
 * Created by IntelliJ IDEA.
 * User: fairview
 * Date: 7/7/11
 * Time: 11:09 AM
 * To change this template use File | Settings | File Templates.
 */


function generateOrgUnitForm() {
    var organizationForm = $('<form>', {id: 'organization_form', method:'post'});

    var fieldSet = $('<fieldset>');

    var descriptionDiv = fieldBox();
    var descriptionLabel = fieldLabelBox();
    descriptionLabel.append('Beskrivning');
    var descriptionInput = $('<textarea id="description-field" name="description" onchange="" value="">');
    descriptionDiv.append(descriptionLabel, descriptionInput, $('<br>'));

    var nameDiv = textInputComponent('Namn','name');
    var phoneDiv = textInputComponent('Telefonnummer','phone');
    var faxDiv = textInputComponent('Faxnummer', 'fax');
    var emailDiv = textInputComponent('E-post', 'e-mail');
    var webDiv = textInputComponent('Hemsida', 'web');
    var adressDiv = textInputComponent('Adress', 'adress');
    var postnummerDiv = textInputComponent('Postnummer', 'postalcode');
    var cityDiv = textInputComponent('Ort', 'city');
    var countryDiv = textInputComponent('Land', 'country');


    //the order of the elements appended equals the order of the elements displayed on the page
    fieldSet.append(nameDiv,'<br/>' ,descriptionDiv, '<br/>', phoneDiv,'<br/>', faxDiv, '<br/>',
    emailDiv,'<br/>',webDiv,'<br/>', adressDiv, '<br/>', postnummerDiv, '<br/>', cityDiv, '<br/>', countryDiv );
    organizationForm.append(fieldSet);
    return organizationForm;
}

