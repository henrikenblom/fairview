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
    var organizationform = $('<form>', {id: 'organizationform', method:'post'});

    var namediv = textInputComponent('Namn','name');

    var descriptiondiv = fieldBox();
    var descriptionlabel = fieldLabelBox();
    descriptionlabel.append('Beskrivning');
    var descriptioninput = $('<textarea id="description-field" name="description" onchange="" value="">');
    descriptiondiv.append(descriptionlabel, descriptioninput, $('<br>'));

    var phonediv = textInputComponent('Telefonnummer','phone');

    organizationform.append(namediv,'<br/>' ,descriptiondiv, '<br/>', phonediv);
    organizationform.appendTo('#content');
}

