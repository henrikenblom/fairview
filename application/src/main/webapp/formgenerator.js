/**
 * Created by IntelliJ IDEA.
 * User: fairview
 * Date: 7/7/11
 * Time: 11:09 AM
 * To change this template use File | Settings | File Templates.
 */
var formChanged = false;

function generateBaseUnitEditForm(data, datatable) {

    var unitId = data.node.id;
    var formId = getOrganizationFormId();
    var properties = data.node.properties;
    formChanged = false;

    var updateForm = generateUpdateForm(formId);

    var fieldSet = $('<fieldset>');

    var hiddenField_id = hiddenField('_id', unitId);
    var hiddenField_type = hiddenField('_type', 'node');
    var hiddenField_strict = hiddenField('_strict', 'true');
    var hiddenField_username = hiddenField('_username', 'admin');

    var descriptionDiv = textAreaInputComponent('Beskrivning', 'description', propValue(properties.description), formId, 'descriptionDiv');

    var nameDiv = textInputComponent('Namn', 'name', propValue(properties.name), formId, true);

    var phoneDiv = textInputComponent('Telefonnummer', 'phone', propValue(properties.phone), formId, false);
    var faxDiv = textInputComponent('Faxnummer', 'fax', propValue(properties.fax), formId, false);
    var emailDiv = textInputComponent('E-post', 'email', propValue(properties.email), formId, false);
    var webDiv = textInputComponent('Hemsida', 'web', propValue(properties.web), formId, false);

    //adds the elements to the fieldset -> the order of the elements appended equals the order of the elements displayed on the page
    fieldSet.append(hiddenField_id, hiddenField_strict, hiddenField_type, hiddenField_username, nameDiv, '<br/>', descriptionDiv, '<br/>', phoneDiv, '<br/>', faxDiv, '<br/>',
        emailDiv, '<br/>', webDiv, '<br/>');
    updateForm.append(fieldSet);
    updateForm.validate();
    return updateForm;
}

function generateSubunitCreationForm() {
    var formId = 'subunitform';
    var form = generateUpdateForm(formId);
    var fieldSet = $('<fieldset>');
    formChanged = false;

    var hiddenField_id = hiddenField('_id', '');
    var hiddenField_type = hiddenField('_type', 'node');
    var hiddenField_strict = hiddenField('_strict', 'true');
    var hiddenField_username = hiddenField('_username', 'admin');
    var hiddenField_nodeClass = hiddenField('nodeClass', 'unit');

    var descriptionDiv = textAreaInputComponent('Beskrivning', 'description', '', formId, 'descriptionDiv');

    var nameDiv = textInputComponent('Namn', 'name', '', formId, true);
    var phoneDiv = textInputComponent('Telefonnummer', 'phone', '', formId, false);
    var faxDiv = textInputComponent('Faxnummer', 'fax', '', formId, false);
    var emailDiv = textInputComponent('E-post', 'email', '', formId, false);
    var webDiv = textInputComponent('Hemsida', 'web', '', formId, false);

    var addressDiv = textInputComponent('Adress', 'address', '', getOrganizationFormId());
    var postnummerDiv = textInputComponent('Postnummer', 'postalcode', '', getOrganizationFormId());
    var cityDiv = textInputComponent('Ort', 'city', '', getOrganizationFormId());
    var countryDiv = textInputComponent('Land', 'country', '', getOrganizationFormId());

    fieldSet.append(hiddenField_id, hiddenField_nodeClass, hiddenField_strict, hiddenField_type, hiddenField_type,
        hiddenField_username, nameDiv, '<br/>', descriptionDiv, '<br/>', phoneDiv, '<br/>', faxDiv, '<br/>', emailDiv,
        '<br/>', webDiv, '<br/>', addressDiv, '<br/>', postnummerDiv, '<br/>', cityDiv, '<br/>', countryDiv, '<br/>');
    form.append(fieldSet);
    form.validate();
    return form;
}

function generateProfileGeneralForm(data) {
    var formId = 'profile_form';
    formChanged = false;

    var idString = '';
    var birthdayString = '';
    var authorizationString = '';

    var firstNameString = '';
    var lastNameString = '';
    var nationalityString = '';
    var civicString = '';
    var addressString = '';
    var zipString = '';
    var cityString = '';
    var countryString = '';
    var phoneString = '';
    var cellString = '';
    var emailString = '';
    var additionalInfoString = '';
    var genderString = '';

    if (!$.isEmptyObject(data)) {
        var properties = data.node.properties;
        idString = data.node.id;
        birthdayString = makeBirthdate(propValue(properties.civic));
        authorizationString = boolPropValue(properties.authorization);
        firstNameString = propValue(properties.firstname);
        lastNameString = propValue(properties.lastname);
        nationalityString = propValue(properties.nationality);
        civicString = propValue(properties.civic);
        addressString = propValue(properties.address);
        zipString = propValue(properties.zip);
        cityString = propValue(properties.city);
        countryString = propValue(properties.country);
        phoneString = propValue(properties.phone);
        cellString = propValue(properties.cell);
        emailString = propValue(properties.email);
        additionalInfoString = propValue(properties.additional__info);
        genderString = propValue(properties.gender);
    }

    var form = generateUpdateForm(formId);
    var fieldSet = $('<fieldset>');

    var hiddenField_id = hiddenField('_id', idString);
    var hiddenField_type = hiddenField('_type', 'node');
    var hiddenField_strict = hiddenField('_strict', 'false');
    var hiddenField_username = hiddenField('_username', 'admin');
    var hiddenField_birthday = hiddenField('birthday', civicString);
    var hiddenField_authorization = hiddenField('authorization', authorizationString);

    var firstNameDiv = textInputComponent('Förnamn', 'firstname', firstNameString, formId, true);
    var lastNameDiv = textInputComponent('Efternamn', 'lastname', lastNameString, formId, true);
    var nationalityDiv = textInputComponent('Nationalitet', 'nationality', nationalityString, formId, false);
    var civicDiv = civicInputComponent('Personnummer', 'civic', civicString, formId, false);

    var addressDiv = textInputComponent('Adress', 'address', addressString, formId, false);
    var zipDiv = textInputComponent('Postnummer', 'zip', zipString, formId, false);

    var cityDiv = textInputComponent('Postort', 'city', cityString, formId, false);
    var countryDiv = textInputComponent('Land', 'country', countryString, formId, false);
    var phoneDiv = textInputComponent('Telefon', 'phone', phoneString, formId, false);
    var cellDiv = textInputComponent('Mobiltelefon', 'cell', cellString, formId, false);
    var emailDiv = textInputComponent('E-post', 'email', emailString, formId, false);

    var additional_infoDiv = textAreaInputComponent('Övrigt', 'additional_info', additionalInfoString, formId, 'additional_infoDiv');

    var genderDiv = selectInputComponent('Kön', 'gender', 'genderDiv', formId, true);
    addGenderOptions(genderString, genderDiv.children('#gender-field'));

    fieldSet.append(hiddenField_id, hiddenField_strict, hiddenField_type, hiddenField_username, hiddenField_birthday, hiddenField_authorization,
        firstNameDiv, '<br/>', lastNameDiv, '<br/>', genderDiv, '<br/>', nationalityDiv, '<br/>', civicDiv, '<br/>', addressDiv, '<br/>',
        zipDiv, '<br/>', cityDiv, '<br/>', countryDiv, '<br/>', phoneDiv, '<br/>', cellDiv, '<br/>', emailDiv, '<br/>', additional_infoDiv, '<br/>');

    form.append(fieldSet);
    form.validate();

    return form;
}

function generateLanguageForm(form_Id, languageNode) {
    var formId = form_Id;

    var languageString = '';
    var spokenString = '';
    var writtenString = '';
    if (!$.isEmptyObject(languageNode)) {
        var properties = languageNode.properties;
        languageString = propValue(properties.language);
        spokenString = propValue(properties.spoken);
        writtenString = propValue(properties.written);
    }


    var languageForm = generateUpdateForm(formId);
    var languageDiv = $('<div>');
    languageDiv.addClass('delimitedForm');

    var hiddenField_id = hiddenField('_id', form_Id);
    var hiddenField_type = hiddenField('_type', 'node');
    var hiddenField_strict = hiddenField('_strict', 'false');
    var hiddenField_username = hiddenField('_username', 'admin');

    var language = textInputComponent('Språk', 'language', languageString, formId, false);

    var written = selectInputComponent('Kunskapsnivå - skriftlig', 'written', 'written-field', formId, false);
    written.children('#written-field').append(generateOption('some', writtenString, 'Viss'));
    written.children('#written-field').append(generateOption('good', writtenString, 'God'));
    written.children('#written-field').append(generateOption('advanced', writtenString, 'Advancerad'));

    var spoken = selectInputComponent('Kunskapsnivå - muntlig', 'spoken', 'spoken-field', formId, false);
    spoken.children('#spoken-field').append(generateOption('some', spokenString, 'Viss'));
    spoken.children('#spoken-field').append(generateOption('good', spokenString, 'God'));
    spoken.children('#spoken-field').append(generateOption('advanced', spokenString, 'Advancerad'));

    languageForm.append(hiddenField_id, hiddenField_type, hiddenField_strict, hiddenField_username,
        language, '<br/>', written, '<br/>', spoken);
    languageDiv.append(languageForm);
    return languageDiv;
}

function generateEducationForm(form_Id, educationNode) {
    var formId = form_Id;

    var nameString = '';
    var levelString = '';
    var directionString = '';
    var scopeString = '';
    var fromString = '';
    var toString = '';
    var countryString = '';
    var descriptionString = '';
    if (!$.isEmptyObject(educationNode)) {
        var properties = educationNode.properties;
        nameString = propValue(properties.name);
        levelString = propValue(properties.level);
        directionString = propValue(properties.direction);
        scopeString = propValue(properties.scope);
        fromString = propValue(properties.from);
        toString = propValue(properties.to);
        countryString = propValue(properties.country);
        descriptionString = propValue(properties.description);
    }


    var educationForm = generateUpdateForm(formId);
    var educationDiv = $('<div>');
    educationDiv.addClass('delimitedForm');

    var hiddenField_id = hiddenField('_id', form_Id);
    var hiddenField_type = hiddenField('_type', 'node');
    var hiddenField_strict = hiddenField('_strict', 'false');
    var hiddenField_username = hiddenField('_username', 'admin');

    var nameComponent = textInputComponent('Benämning', 'name', nameString, formId, false);
    var directionComponent = textInputComponent('Inriktning', 'direction', directionString, formId, false);
    var scopeComponent = textInputComponent('Omfattning', 'scope', scopeString, formId, false);
    var fromComponent = textInputComponent('Från och med', 'from', fromString, formId, false);
    var toComponent = textInputComponent('Till och med', 'to', toString, formId, false);
    var countryComponent = textInputComponent('Land', 'country', countryString, formId, false);
    var descriptionComponent = textInputComponent('Beskrivning', 'description', descriptionString, formId, false);

    var levelComponent = selectInputComponent('Utbildningsnivå', 'level', 'level-field', formId, false);
    levelComponent.children('#level-field').append(generateOption('high_school', levelString, 'Gymnasieskola eller motsvarande'));
    levelComponent.children('#level-field').append(generateOption('certified', levelString, 'Certifierad'));
    levelComponent.children('#level-field').append(generateOption('vocational_education', levelString, 'Yrkesutbildad'));
    levelComponent.children('#level-field').append(generateOption('individual_course', levelString, 'Enstaka kurs'));
    levelComponent.children('#level-field').append(generateOption('post_highschool_course', levelString, 'Övrig eftergymnasial kurs'));
    levelComponent.children('#level-field').append(generateOption('bachelor', levelString, 'Kandidatexamen'));
    levelComponent.children('#level-field').append(generateOption('master', levelString, 'Magister eller civilingenjörsexamen'));
    levelComponent.children('#level-field').append(generateOption('phd', levelString, 'Licentiat eller doktorsexamen'));
    levelComponent.children('#level-field').append(generateOption('professional_license', levelString, 'Yrkeslicens'));

    educationForm.append(hiddenField_id, hiddenField_type, hiddenField_strict, hiddenField_username, nameComponent, '<br/>',
        levelComponent, '<br/>', directionComponent, '<br/>', scopeComponent, '<br/>', fromComponent, '<br/>', toComponent,
        '<br/>', countryComponent, '<br/>', descriptionComponent);
    educationDiv.append(educationForm);
    return educationDiv;
}

function generateCertificateForm(form_Id, certificateNode) {
    var formId = form_Id;

    var nameString = '';
    var descriptionString = '';
    var gradeString = '';
    var fromString = '';
    var toString = '';
    if (!$.isEmptyObject(certificateNode)) {
        var properties = certificateNode.properties;
        nameString = propValue(properties.name);
        descriptionString = propValue(properties.description);
        gradeString = propValue(properties.grade);
        fromString = propValue(properties.from);
        toString = propValue(properties.to);
    }

    var certificateForm = generateUpdateForm(formId);
    var certificateDiv = $('<div>');
    certificateDiv.addClass('delimitedForm');

    var hiddenField_id = hiddenField('_id', form_Id);
    var hiddenField_type = hiddenField('_type', 'node');
    var hiddenField_strict = hiddenField('_strict', 'false');
    var hiddenField_username = hiddenField('_username', 'admin');

    var nameComponent = textInputComponent('Namn', 'name', nameString, formId, false);
    var descriptionComponent = textInputComponent('Beskrivning', 'description', descriptionString, formId, false);
    var fromComponent = textInputComponent('Från och med', 'from', fromString, formId, false);
    var toComponent = textInputComponent('Till och med', 'to', toString, formId, false);
    var gradeComponent = textInputComponent('Betyg', 'grade', gradeString, formId, false);

    certificateForm.append(hiddenField_id, hiddenField_type, hiddenField_strict, hiddenField_username,
        nameComponent, '<br/>', descriptionComponent, '<br/>', fromComponent, '<br/>', toComponent
        , '<br/>', gradeComponent);
    certificateDiv.append(certificateForm);
    return certificateDiv;
}

function generateWorkExperienceForm(form_Id, workExperienceNode) {
    var formId = form_Id;

    var nameString = '';
    var companyString = '';
    var tradeString = '';
    var countryString = '';
    var fromString = '';
    var toString = '';
    var assignmentsString = '';
    if (!$.isEmptyObject(workExperienceNode)) {
        var properties = workExperienceNode.properties;
        nameString = propValue(properties.name);
        companyString = propValue(properties.description);
        tradeString = propValue(properties.grade);
        countryString = propValue(properties.from);
        fromString = propValue(properties.from);
        toString = propValue(properties.to);
        assignmentsString = propValue(properties.assignments);
    }

    var form = generateUpdateForm(formId);
    var div = $('<div>');
    div.addClass('delimitedForm');

    var hiddenField_id = hiddenField('_id', form_Id);
    var hiddenField_type = hiddenField('_type', 'node');
    var hiddenField_strict = hiddenField('_strict', 'false');
    var hiddenField_username = hiddenField('_username', 'admin');

    var nameComponent = textInputComponent('Tidigare befattning', 'name', nameString, formId, false);
    var companyComponent = textInputComponent('Företag', 'company', companyString, formId, false);
    var tradeComponent = textInputComponent('Bransch', 'trade', tradeString, formId, false);
    var countryComponent = textInputComponent('Land', 'country', countryString, formId, false);
    var fromComponent = textInputComponent('Från och med', 'from', countryString, formId, false);
    var toComponent = textInputComponent('Till och med', 'to', fromString, formId, false);
    var assignmentComponent = textAreaInputComponent('Uppgifter', 'assignment', assignmentsString, formId, 'assignment-field');

    form.append(hiddenField_id, hiddenField_type, hiddenField_strict, hiddenField_username,
        nameComponent, '<br/>', companyComponent, '<br/>', tradeComponent, '<br/>', countryComponent, '<br/>',
        fromComponent, '<br/>', toComponent, '<br/>', assignmentComponent);
    div.append(form);
    return div;
}

function generateMilitaryServiceForm(form_Id, militaryServiceNode) {
    var formId = form_Id;

    var nameString = '';
    var descriptionString = '';

    if (!$.isEmptyObject(militaryServiceNode)) {
        var properties = militaryServiceNode.properties;
        nameString = propValue(properties.name);
        descriptionString = propValue(properties.description);
    }

    var form = generateUpdateForm(formId);
    var div = $('<div>');
    div.addClass('delimitedForm');

    var hiddenField_id = hiddenField('_id', form_Id);
    var hiddenField_type = hiddenField('_type', 'node');
    var hiddenField_strict = hiddenField('_strict', 'false');
    var hiddenField_username = hiddenField('_username', 'admin');

    var nameComponent = textInputComponent('Militärtjänst', 'name', nameString, formId, false);
    var descriptionComponent = textAreaInputComponent('Beskrivning', 'description', descriptionString, formId, 'description-field');

    form.append(hiddenField_id, hiddenField_type, hiddenField_strict, hiddenField_username,
        nameComponent, '<br/>', descriptionComponent);
    div.append(form);
    return div;
}

function addEmployee() {
    openEmployeeForm();
}

function addEducationButton(nodeId) {
    var button = $('<button>');
    button.attr('id', 'addEducationButton')
    button.html('Lägg till utbildning');
    button.click(function() {
        addEducationRelationship(nodeId, '#addEducationButton');
    });
    return button;
}

function addCertificateButton(nodeId) {
    var button = $('<button>');
    button.attr('id', 'addCertificateButton')
    button.html('Lägg till certifikat');
    button.click(function() {
        addCertificateRelationship(nodeId, '#addCertificateButton');
    });
    return button;
}

function addLanguageButton(nodeId) {
    var button = $('<button>');
    button.attr('id', 'languageButton')
    button.html('Lägg till språk');
    button.click(function() {
        addLanguageRelationship(nodeId, '#languageButton');
    });
    return button;
}

function addWorkExperienceButton(nodeId) {
    var button = $('<button>');
    button.attr('id', 'addWorkExperienceButton')
    button.html('Lägg till tidigare befattning');
    button.click(function() {
        addWorkExperienceRelationship(nodeId, '#addWorkExperienceButton');
    });
    return button;
}

function addMilitaryServiceButton(nodeId) {
    var button = $('<button>');
    button.attr('id', 'addMilitaryServiceButton')
    button.html('Lägg till Militärtjänst');
    button.click(function() {
        addMilitaryServiceRelationship(nodeId, '#addMilitaryServiceButton');
    });
    return button;
}

function addExistingValues(nodeId, type, formGeneratingFunction, divToPrepend) {
    $.getJSON("fairview/ajax/get_relationship_endnodes.do", {_nodeId: nodeId, _type: type}, function(data) {
        if (!$.isEmptyObject(data.list)) {
            var array = data.list["org.neo4j.kernel.impl.core.NodeProxy"];
            if (array.length > 1) {
                $.each(array, function(count, object) {
                    formGeneratingFunction.call(this, object.id, object).prependTo(divToPrepend);
                });
            }
            else { //an array containing only one entry is a single object
                formGeneratingFunction.call(this, array.id, array).prependTo(divToPrepend);
            }
        }
    });
}

function addCertificateRelationship(nodeId, insertBeforeThisDiv) {
    $.getJSON("neo/ajax/create_relationship.do", {_startNodeId:nodeId, _type:"HAS_CERTIFICATE" }, function(data) {
        var div = generateCertificateForm(data.relationship.endNode);
        div.insertBefore(insertBeforeThisDiv);
    });
}

function addEducationRelationship(nodeId, insertBeforeThisDiv) {
    $.getJSON("neo/ajax/create_relationship.do", {_startNodeId:nodeId, _type:"HAS_EDUCATION" }, function(data) {
        var div = generateEducationForm(data.relationship.endNode);
        div.insertBefore(insertBeforeThisDiv);
    });
}

function addLanguageRelationship(nodeId, insertBeforeThisDiv) {
    $.getJSON("neo/ajax/create_relationship.do", {_startNodeId:nodeId, _type:"HAS_LANGUAGESKILL" }, function(data) {
        var div = generateLanguageForm(data.relationship.endNode);
        div.insertBefore(insertBeforeThisDiv);
    });
}

function addWorkExperienceRelationship(nodeId, insertBeforeThisDiv) {
    $.getJSON("neo/ajax/create_relationship.do", {_startNodeId:nodeId, _type:"HAS_WORK_EXPERIENCE" }, function(data) {
        var div = generateWorkExperienceForm(data.relationship.endNode);
        div.insertBefore(insertBeforeThisDiv);
    });
}

function addMilitaryServiceRelationship(nodeId, insertBeforeThisDiv) {
    $.getJSON("neo/ajax/create_relationship.do", {_startNodeId:nodeId, _type:"HAS_MILITARY_SERVICE" }, function(data) {
        var div = generateMilitaryServiceForm(data.relationship.endNode);
        div.insertBefore(insertBeforeThisDiv);
    });
}

function generateOption(value, savedValue, text) {
    var option = $('<option>');
    option.attr('value', value);
    option.html(text);
    if (value == savedValue)
        option.attr('selected', 'true');
    return option;
}

function updateTableCallback(datatable) {
    if (datatable != null)
        return function response() {
            updateTable(datatable);
        }
}

function generateSaveButton(callback) {
    var saveButton = $('<button>');
    saveButton.html('Spara');
    saveButton.addClass('saveButton');
    saveButton.attr('disabled', 'disabled');
    saveButton.click(function() {
        disableSaveButton();
        saveButton.html('Sparar...');
        setTimeout(closePopup, 500);
        var forms = $('form');
        $.each(forms, function(i, form) {
            $('#' + form.id).ajaxSubmit(function() {
                if (typeof callback == 'function' && i == 0) //only make the callback once
                    callback.call();
            });
        });


    });
    return saveButton;
}

function generateCancelButton() {
    var cancelButton = $('<button>');
    cancelButton.html('Avbryt');
    cancelButton.attr('id', 'cancelButton');
    cancelButton.click(function() {
        if (formChanged == true) {
            generateCancelDialog();
        } else {
            closePopup();
        }
    });
    return cancelButton;
}

function generateCancelDialog() {
    var cancelDialog = $('<div>');
    cancelDialog.attr('title', 'Är du säker?');
    cancelDialog.html('Du har osparade ändringar. Är du säker på att du vill stänga formuläret?');
    cancelDialog.dialog({
        resizable: false,
        height:140,
        modal: true,
        buttons: {
            "Ja": function() {
                $(this).dialog("close");
                closePopup();
            },
            "Avbryt": function() {
                $(this).dialog("close");
            }
        }
    });
}


function enableSaveButton() {
    $('.saveButton').removeAttr('disabled');
}

function disableSaveButton() {
    $('.saveButton').attr('disabled', 'disabled');
}
function footerButtonsComponent(callback) {
    var saveDiv = $('<div>');
    saveDiv.addClass('saveDiv');
    var saveButton = generateSaveButton(callback);
    var cancelButton = generateCancelButton();
    saveDiv.append(saveButton, cancelButton);
    return saveDiv;
}

function addFunctionOptions(functionInputElement, unitId, assignedFunctionId) {
    var func = getFunctions(unitId);

    if (func.map.entry == null) { // True if the unit has no assigned function, and no functions are available
        var nooneavailableOption = $('<option>');
        nooneavailableOption.html('Inga lediga funktioner finns.');
        nooneavailableOption.attr('selected', 'true');
        nooneavailableOption.attr('value', -1);
        functionInputElement.append(nooneavailableOption);
    } else {
        if (assignedFunctionId == -1) {
            var chooseOption = $('<option>');
            chooseOption.html('Välj...');
            chooseOption.attr('selected', 'true');
            chooseOption.attr('value', -1);
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
}

function addGenderOptions(gender, genderInputElement) {
    var optionMan = $('<option>');
    optionMan.attr('value', 'M');
    optionMan.html('Man');
    var optionFemale = $('<option>');
    optionFemale.attr('value', 'F');
    optionFemale.html('Kvinna');
    if (gender == 'M')
        optionMan.attr('selected', 'true');
    else if (gender == 'F')
        optionFemale.attr('selected', 'true');
    else {
        var optionChooseGender = $('<option>');
        optionChooseGender.html('Välj...');
        optionChooseGender.attr('value', '');
        genderInputElement.append(optionChooseGender, optionMan, optionFemale);
        return;
    }
    genderInputElement.append(optionMan, optionFemale)
}

function addEmploymentOptions(employment, employmentInputElement) {

    var employmentOptions = new Array('Tills vidare', 'Provanställning', 'Visstidsanställning', 'Projektanställning', 'Säsongsanställning',
        'Timanställning');

    if (propValue(employment) == '' || propValue(employment) == 'Välj...') {
        var optionChoose = $('<option>');
        optionChoose.html('Välj...');
        optionChoose.attr('selected', 'true');
        employmentInputElement.append(optionChoose)
    }

    $.each(employmentOptions, function(i, data) {
        var optionDiv = $('<option>');
        optionDiv.attr('value', data);
        optionDiv.html(data);
        if (propValue(employment) == data)
            optionDiv.attr('selected', 'true');
        employmentInputElement.append(optionDiv);
    });
}

function makeBirthdate(civicnumber) {
    if (civicnumber.toString().length > 6)
        return civicnumber.toString().substr(0, 6);
    else
        return civicnumber;
}

function generateTabHeader(name) {
    $('#popup-header').empty().append(name);
}

function fieldLabelBox() {
    return $('<div class="field-label-box">');
}
function fieldBox() {
    return $('<div class="field-box">');
}
function formIsValid(formId) {
    return $('#' + formId).valid();
}
function makeInputRequired(label, input) {
    label.append(' (* Obligatoriskt fält.)');
    input.addClass('required');
}
function textInputComponent(labelText, inputName, value, formId, required) {
    var inputDiv = fieldBox();
    var inputLabel = fieldLabelBox();
    inputLabel.append(labelText);
    var textInput = $('<input type="text">');
    textInput.addClass("text-field");
    textInput.attr("id", inputName + "-field");
    textInput.attr("name", inputName);
    textInput.val(value);
    textInput.change(function() {
        formChanged = true;
    });
    textInput.keyup(function() {
        validateForm(formId);
    });
    if (required == true) {
        makeInputRequired(inputLabel, textInput);
    }
    inputDiv.append(inputLabel, textInput);
    return inputDiv;
}

function civicInputComponent(labelText, inputName, value, formId, required) {
    var inputDiv = fieldBox();
    var inputLabel = fieldLabelBox();
    inputLabel.append(labelText);
    var textInput = $('<input type="text">');
    textInput.addClass("text-field");
    textInput.attr("id", inputName + "-field");
    textInput.attr("name", inputName);
    textInput.val(value);
    textInput.keyup(function() {
        validateForm(formId);
    });
    textInput.change(function() {
        formChanged = true;
        $('#birthday-field').val(makeBirthdate(this.value));
    });
    if (required == true) {
        makeInputRequired(inputLabel, textInput);
    }
    inputDiv.append(inputLabel, textInput);
    return inputDiv;
}
function hiddenField(name, value) {
    var hiddenField = $('<input type="hidden">');
    hiddenField.attr("name", name);
    hiddenField.val(value);
    hiddenField.attr("id", name + "-field");
    return hiddenField;
}
function propValue(prop) {
    if ($.isEmptyObject(prop))
        return "";
    else
        return prop.value;
}
function boolPropValue(prop) {
    if ($.isEmptyObject(prop))
        return "false";
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
    textareaInput.val(value);
    textareaInput.change(function() {
        formChanged = true;
    });
    textareaInput.keyup(function() {
        validateForm(formId);
    });
    textareaDiv.append(textareaLabel, textareaInput, $('<br>'));
    return textareaDiv;
}

function validateForm(formId) {
    if (formIsValid(formId))
        enableSaveButton();
    else
        disableSaveButton();
}
function selectInputComponent(labelText, inputName, divId, formId, required) {
    var selectDiv = fieldBox();
    selectDiv.attr("id", divId);
    var selectLabel = fieldLabelBox();
    selectLabel.append(labelText);
    var selectInput = $('<select>');
    selectInput.attr("name", inputName);
    selectInput.attr("id", inputName + "-field");
    selectInput.change(function() {
        formChanged = true;
        validateForm(formId);
    });
    if (required == true) {
        makeInputRequired(selectLabel, selectInput);
    }
    selectDiv.append(selectLabel, selectInput, $('<br>'));
    return selectDiv;
}

function functionSelectInputComponent(labelText, inputName, divId, formId, required) {
    var selectDiv = fieldBox();
    selectDiv.attr("id", divId);
    var selectLabel = fieldLabelBox();
    selectLabel.append(labelText);
    var selectInput = $('<select>');
    selectInput.attr("name", inputName);
    selectInput.attr("id", inputName + "-field");
    selectInput.change(function() {
        validateForm(formId);
        formChanged = true;
    });
    selectDiv.append(selectLabel, selectInput, $('<br>'));
    return selectDiv;
}

function editTreeNamesOnChange(newVal, unitId) {
    $('#unitsettings-general-tablink[name=unitsettings-general-tablink' + unitId + ']').empty().append(newVal);
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

function generateSingleAddressComponent(data) {
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

function assignFunction(unitId, functionId, callback) {
    $.getJSON("fairview/ajax/unassign_function.do", {_nodeId: unitId}, function() {
        $.getJSON("neo/ajax/create_relationship.do", {_startNodeId:unitId, _type:"HAS_EMPLOYMENT" }, function(dataEmployment) {
            $.getJSON("fairview/ajax/assign_function.do", {employment:dataEmployment.relationship.endNode, "function:relationship":functionId, percent:100}, callback);
        });
    });
}