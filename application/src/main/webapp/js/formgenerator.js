/**
 * Created by IntelliJ IDEA.
 * User: fairview
 * Date: 7/7/11
 * Time: 11:09 AM
 * To change this template use File | Settings | File Templates.
 */

var CITY_CATEGORY = 'cities';
var LANGUAGE_CATEGORY = 'languages';
var COUNTRY_CATEGORY = 'countries';
var POSTALCODE_CATEGORY = 'postalcodes';
var NATIONALITY_CATEGORY = 'nationalities';
var CERTIFICATE_NAME_CATEGORY = 'certificate_names';
var CERTIFICATE_GRADE_CATEGORY = 'certificate_grades';
var EDUCATION_NAME_CATEGORY = 'education_names';
var EDUCATION_DIRECTION_CATEGORY = 'education_directions';
var EDUCATION_SCOPE_CATEGORY = 'education_scopes';
var WORKEXPERIENCE_NAME_CATEGORY = 'workexperience_names';
var WORKEXPERIENCE_COMPANY_CATEGORY = 'workexperience_companies';
var WORKEXPERIENCE_TRADE_CATEGORY = 'workexperience_trades';
var MILITARYSERVICE_NAME_CATEGORY = 'militaryservice_names';
var EMPLOYMENT_TITLE_CATEGORY = 'employment_titles';
var EMPLOYMENT_COMPANYCAR_CATEGORY = 'employment_companycars';
var EMPLOYMENT_PENSIONINSURANCE_CATEGORY = 'employment_pensioninsurances';


function generateBaseUnitEditForm(data, datatable) {

    var unitId = data.node.id;
    var formId = getOrganizationFormId();
    var properties = data.node.properties;

    var updateForm = buildUpdateForm(formId);

    var fieldSet = $('<fieldset>');

    var descriptionString = '';
    var nameString = '';
    var phoneString = '';
    var emailString = '';
    var faxString = '';
    var webString = '';
    if (properties != null) {
        descriptionString = propValue(properties.description);
        nameString = propValue(properties.name);
        phoneString = propValue(properties.phone);
        faxString = propValue(properties.fax);
        emailString = propValue(properties.email);
        webString = propValue(properties.web);
    }

    var hiddenField_id = hiddenField('_nodeId', unitId);
    var hiddenField_strict = hiddenField('_strict', 'true');
    var hiddenField_username = hiddenField('_username', 'admin');
    var hiddenField_nodeClass = hiddenField('nodeclass', 'unit');

    var descriptionDiv = textAreaInputComponent('Beskrivning', 'description', descriptionString, formId, 'descriptionDiv');

    var nameDiv = textInputComponent('Namn', 'name', nameString, formId, true);

    var phoneDiv = textInputComponent('Telefonnummer', 'phone', phoneString, formId, false);
    var faxDiv = textInputComponent('Faxnummer', 'fax', faxString, formId, false);
    var emailDiv = textInputComponent('E-post', 'email', emailString, formId, false);
    var webDiv = textInputComponent('Hemsida', 'web', webString, formId, false);

    //adds the elements to the fieldset -> the order of the elements appended equals the order of the elements displayed on the page
    fieldSet.append(hiddenField_id, hiddenField_strict, hiddenField_username, hiddenField_nodeClass, nameDiv, '<br/>', descriptionDiv, '<br/>', phoneDiv, faxDiv,
        emailDiv, webDiv);
    updateForm.append(fieldSet);
    updateForm.validate();
    return updateForm;
}

function getSubUnitCreationFormId() {
    var formId = 'subunitform';
    return formId;
}
function generateSubunitCreationForm() {
    var formId = getSubUnitCreationFormId();
    var form = buildUpdateForm(formId);
    var fieldSet = $('<fieldset>');

    var hiddenField_id = hiddenField('_nodeId', null);
    var hiddenField_strict = hiddenField('_strict', 'true');
    var hiddenField_nodeClass = hiddenField('nodeclass', 'unit');

    var descriptionDiv = textAreaInputComponent('Beskrivning', 'description', '', formId, 'descriptionDiv');

    var nameDiv = textInputComponent('Namn', 'name', '', formId, true);
    var phoneDiv = textInputComponent('Telefonnummer', 'phone', '', formId, false);
    var faxDiv = textInputComponent('Faxnummer', 'fax', '', formId, false);
    var emailDiv = textInputComponent('E-post', 'email', '', formId, false);
    var webDiv = textInputComponent('Hemsida', 'web', '', formId, false);

    var addressDiv = textInputComponent('Adress', 'address', '', getSubUnitCreationFormId());
    var postnummerDiv = typeaheadInputComponent('Postnummer', 'postalcode', '', getSubUnitCreationFormId(), POSTALCODE_CATEGORY);
    var cityDiv = typeaheadInputComponent('Ort', 'city', '', getSubUnitCreationFormId(), CITY_CATEGORY);
    var countryDiv = typeaheadInputComponent('Land', 'country', '', getSubUnitCreationFormId(), COUNTRY_CATEGORY);

    fieldSet.append(hiddenField_id, hiddenField_strict, hiddenField_nodeClass, nameDiv, '<br/>', descriptionDiv, phoneDiv, faxDiv, emailDiv,
        webDiv, addressDiv, postnummerDiv, cityDiv, countryDiv);
    form.append(fieldSet);
    form.validate();
    return form;
}

function generateProfileGeneralForm(data) {
    var formId = 'new_person_form';

    var idString = '';
    var birthdayString = '';
    var authorizationString = '';

    var firstNameString = '';
    var lastNameString = '';
    var nationalityString = '';
    var civicString = '';
    var addressString = '';
    var postalString = '';
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
        formId = 'person_form' + idString;
        birthdayString = makeBirthdate(propValue(properties.civic));
        authorizationString = boolPropValue(properties.authorization);
        firstNameString = propValue(properties.firstname);
        lastNameString = propValue(properties.lastname);
        nationalityString = propValue(properties.nationality);
        civicString = propValue(properties.civic);
        addressString = propValue(properties.address);
        postalString = propValue(properties.postalcode);
        cityString = propValue(properties.city);
        countryString = propValue(properties.country);
        phoneString = propValue(properties.phone);
        cellString = propValue(properties.cell);
        emailString = propValue(properties.email);
        additionalInfoString = propValue(properties.additional__info);
        genderString = propValue(properties.gender);
    }

    var form = buildUpdateForm(formId);
    var fieldSet = $('<fieldset>');

    var hiddenField_id = hiddenField('_nodeId', idString);
    var hiddenField_strict = hiddenField('_strict', 'false');
    var hiddenField_birthday = hiddenField('birthday', civicString);
    var hiddenField_authorization = hiddenField('authorization', authorizationString);
    var hiddenField_nodeClass = hiddenField('nodeclass', 'employee');

    var firstNameDiv = textInputComponent('Förnamn', 'firstname', firstNameString, formId, true);
    var lastNameDiv = textInputComponent('Efternamn', 'lastname', lastNameString, formId, true);
    var nationalityDiv = typeaheadInputComponent('Nationalitet', 'nationality', nationalityString, formId, NATIONALITY_CATEGORY, false);
    var civicDiv = civicInputComponent('Personnummer', 'civic', civicString, formId, false);

    var addressDiv = textInputComponent('Adress', 'address', addressString, formId, false);
    var postalcodeDiv = typeaheadInputComponent('Postnummer', 'postalcode', postalString, formId, POSTALCODE_CATEGORY, false);

    var cityDiv = typeaheadInputComponent('Postort', 'city', cityString, formId, CITY_CATEGORY, false);
    var countryDiv = typeaheadInputComponent('Land', 'country', countryString, formId, COUNTRY_CATEGORY, false);
    var phoneDiv = textInputComponent('Telefon', 'phone', phoneString, formId, false);
    var cellDiv = textInputComponent('Mobiltelefon', 'cell', cellString, formId, false);
    var emailDiv = textInputComponent('E-post', 'email', emailString, formId, false);

    var additional_infoDiv = textAreaInputComponent('Övrigt', 'additional_info', additionalInfoString, formId, 'additional_infoDiv');

    var genderDiv = selectInputComponent('Kön', 'gender', 'genderDiv', formId, true);
    addGenderOptions(genderString, genderDiv.children('#gender-field'));

    fieldSet.append(hiddenField_id, hiddenField_strict, hiddenField_birthday, hiddenField_authorization, hiddenField_nodeClass,
        firstNameDiv, '<br/>', lastNameDiv, '<br/>', genderDiv, '<br/>', nationalityDiv, civicDiv, emailDiv, phoneDiv, cellDiv, '<br/>', addressDiv,
        postalcodeDiv, cityDiv, countryDiv, '<br/>', additional_infoDiv, '<br/>');

    form.append(fieldSet);
    form.validate();

    return form;
}

function addManager(formId, unitId) {
    var managerDiv = selectInputComponent('Chef', 'HAS_MANAGER:relationship', 'manager-field', formId, false);
    addManagerOptions(unitId, managerDiv.children('select'));
    return managerDiv;
}

function generateEmploymentCreationForm(data) {

    var properties = new Array();
    var employeeId = data.employee_id;
    var employmentId = data.employment_id;
    var unitId = data.unit_id;
    var EmploymentData;

    var formId = 'new_employment_form';
    if (employeeId != null && employmentId != null && employmentId != '')
        formId = 'employment_form' + employeeId;

    var form = buildUpdateForm(formId);

    var fieldSet = $('<fieldset>');

    if (employmentId != null
        && employmentId.length > 0) {

        EmploymentData = getUnitData(employmentId);
        fieldSet.append(hiddenField('_nodeId', EmploymentData.node.id));
        properties = EmploymentData.node.properties;

    }

    var hiddenField_type = hiddenField('_type', 'node');
    var hiddenField_strict = hiddenField('_strict', 'false');
    var hiddenField_username = hiddenField('_username', 'admin');
    var hiddenField_nodeClass = hiddenField('nodeclass', 'employment');

    var employedPersonDiv = $('<div>');
    employedPersonDiv.append('Anställd: ');
    employedPersonDiv.append(data.firstname + ' ' + data.lastname);

    var titleDiv = typeaheadInputComponent('Titel', 'title', propValue(properties.title), formId, EMPLOYMENT_TITLE_CATEGORY, false);
    var workPhoneDiv = textInputComponent('Arbetstelefon', 'workphone', propValue(properties.workphone), formId, false);
    var workingHoursDiv = textInputComponent('Arbetstider', 'workhours', propValue(properties.workhours), formId, false);
    var responsibilitys = [
        ['managementteam', 'Ledningsgrupp', boolPropValue(properties.managementteam)],
        ['budgetresponsibility', 'Budgetansvar', boolPropValue(properties.budgetresponsibility)],
        ['ownresultresponsibility', 'Eget resultatansvar', boolPropValue(properties.ownresultresponsibility)],
        ['authorizationright', 'Attesträtt', boolPropValue(properties.authorizationright)]
    ];
    var responsibilityDiv = checkboxInputComponent('Ansvar/Befogenheter', formId, responsibilitys);
    var attestationRightsDiv = textInputComponent('Attesträtt belopp', 'authorizationamount:int', propValue(properties.authorizationamount), formId, false);

    var paymentFormDiv = selectInputComponent('Löneform', 'paymentform', 'paymentFormDiv', formId, false);
    addPaymentFormOption(properties.paymentform, paymentFormDiv.children('#paymentform-field'));

    var unitDiv = createUnitSelect('Enhet', 'BELONGS_TO:relationship', 'unitDiv', formId, false, unitId);

    var salaryDiv = textInputComponent('Aktuell lön', 'salary:int', propValue(properties.salary), formId, false);
    var overtimeCompensationDiv = radioButtonInputComponent('Övertidsersättning', 'overtimecompensation:boolean', formId, yesNo(), propValue(properties.overtimecompensation));
    var travelCompensationDiv = radioButtonInputComponent('Reseersättning', 'travelcompensation:boolean', formId, yesNo(), propValue(properties.travelcompensation));
    var vacationDaysDiv = textInputComponent('Semesterrätt', 'vacationdays', propValue(properties.vacationdays), formId, false);
    var dismissalPeriodEmployeeDiv = selectInputComponent('Uppsägningstid (anställd)', 'dismissalperiodemployee:int', 'dismissalPeriodEmployeeDiv', formId, false);
    addDismissalPeriod(properties.dismissalperiodemployee, dismissalPeriodEmployeeDiv.children('#dismissalperiodemployee-field'));
    var dismissalPeriodEmployerDiv = selectInputComponent('Uppsägningstid (företag)', 'dismissalperiodemployer:int', 'dismissalPeriodEmployerDiv', formId, false);
    addDismissalPeriod(properties.dismissalperiodemployer, dismissalPeriodEmployerDiv.children('#dismissalperiodemployer-field'));
    var companyCarDiv = typeaheadInputComponent('Tjänstebil', 'companycar', propValue(properties.companycar), formId, EMPLOYMENT_COMPANYCAR_CATEGORY, false);
    var fromDiv = dateInputComponent('Från och med', 'from:date:yyyy-MM-dd', propValue(properties.from), formId, false);
    var toDiv = dateInputComponent('Till och med', 'to:date:yyyy-MM-dd', propValue(properties.to), formId, false);

    var pensionInsurancesDiv = typeaheadInputComponent('Pension och försäkringar', 'pensioninsurances', propValue(properties.pensioninsurances), formId, EMPLOYMENT_PENSIONINSURANCE_CATEGORY, false);
    fieldSet.append(hiddenField_type,
        hiddenField_strict,
        hiddenField_username,
        hiddenField_nodeClass,
        employedPersonDiv, '<br />',
        titleDiv, unitDiv, '<br />',
        fromDiv, toDiv, '<br />',
        workPhoneDiv,
        workingHoursDiv,
        responsibilityDiv, '<br />',
        paymentFormDiv,
        salaryDiv, '<br />',
        overtimeCompensationDiv,
        travelCompensationDiv, '<br />',
        dismissalPeriodEmployeeDiv,
        dismissalPeriodEmployerDiv,
        vacationDaysDiv,
        companyCarDiv,
        pensionInsurancesDiv,
        attestationRightsDiv);
    form.append(fieldSet);
    form.validate();
    return form;
}

function generateLanguageForm(form_Id, languageNode) {
    var formId = form_Id;

    var languageString = '';
    var spokenString = '';
    var writtenString = '';
    var idString;
    if (!$.isEmptyObject(languageNode)) {
        var properties = languageNode.properties;
        languageString = propValue(properties.language);
        spokenString = propValue(properties.spoken);
        writtenString = propValue(properties.written);
        idString = languageNode.id;
    }


    var languageForm = buildUpdateForm(formId);
    var languageDiv = $('<div>');
    languageDiv.addClass('delimitedForm');

    var hiddenField_id = hiddenField('_nodeId', idString);
    var hiddenField_strict = hiddenField('_strict', 'false');
    var hiddenField_nodeClass = hiddenField('nodeclass', 'languageskill');

    var language = typeaheadInputComponent('Språk', 'language', languageString, formId, LANGUAGE_CATEGORY, false);

    var written = selectInputComponent('Skriftligt', 'written', 'written-field:byte', formId, false);
    written.children('#written-field').append(generateOption('1', writtenString, 'Viss'));
    written.children('#written-field').append(generateOption('2', writtenString, 'God'));
    written.children('#written-field').append(generateOption('3', writtenString, 'Advancerad'));

    var spoken = selectInputComponent('Muntligt', 'spoken', 'spoken-field:byte', formId, false);
    spoken.children('#spoken-field').append(generateOption('1', spokenString, 'Viss'));
    spoken.children('#spoken-field').append(generateOption('2', spokenString, 'God'));
    spoken.children('#spoken-field').append(generateOption('3', spokenString, 'Advancerad'));

    languageForm.append(hiddenField_id, hiddenField_strict, hiddenField_nodeClass,
        language, written, spoken);
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
    var idString = '';
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
        idString = educationNode.id;
    }


    var educationForm = buildUpdateForm(formId);
    var educationDiv = $('<div>');
    educationDiv.addClass('delimitedForm');

    var hiddenField_id = hiddenField('_nodeId', idString);
    var hiddenField_strict = hiddenField('_strict', 'false');
    var hiddenField_nodeClass = hiddenField('nodeclass', 'education');

    var nameComponent = typeaheadInputComponent('Benämning', 'name', nameString, formId, EDUCATION_NAME_CATEGORY, false);
    var directionComponent = typeaheadInputComponent('Inriktning', 'direction', directionString, formId, EDUCATION_DIRECTION_CATEGORY, false);
    var scopeComponent = typeaheadInputComponent('Omfattning', 'scope', scopeString, formId, EDUCATION_SCOPE_CATEGORY, false);
    var fromComponent = dateInputComponent('Från och med', 'from:date:yyyy-MM-dd', fromString, formId, false);
    var toComponent = dateInputComponent('Till och med', 'to:date:yyyy-MM-dd', toString, formId, false);
    var countryComponent = typeaheadInputComponent('Land', 'country', countryString, formId, COUNTRY_CATEGORY, false);
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

    educationForm.append(hiddenField_id, hiddenField_strict, hiddenField_nodeClass, nameComponent,
        levelComponent, directionComponent, scopeComponent, fromComponent, toComponent,
        countryComponent, descriptionComponent);
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
    var idString = '';
    if (!$.isEmptyObject(certificateNode)) {
        var properties = certificateNode.properties;
        nameString = propValue(properties.name);
        descriptionString = propValue(properties.description);
        gradeString = propValue(properties.grade);
        fromString = propValue(properties.from);
        toString = propValue(properties.to);
        idString = certificateNode.id;
    }

    var certificateForm = buildUpdateForm(formId);
    var certificateDiv = $('<div>');
    certificateDiv.addClass('delimitedForm');

    var hiddenField_id = hiddenField('_nodeId', idString);
    var hiddenField_strict = hiddenField('_strict', 'false');
    var hiddenField_nodeClass = hiddenField('nodeclass', 'certificate');

    var nameComponent = typeaheadInputComponent('Namn', 'name', nameString, formId, CERTIFICATE_NAME_CATEGORY, false);
    var descriptionComponent = textInputComponent('Beskrivning', 'description', descriptionString, formId, false);
    var fromComponent = dateInputComponent('Från och med', 'from:date:yyyy-MM-dd', fromString, formId, false);
    var toComponent = dateInputComponent('Till och med', 'to:date:yyyy-MM-dd', toString, formId, false);
    var gradeComponent = typeaheadInputComponent('Betyg', 'grade', gradeString, formId, CERTIFICATE_GRADE_CATEGORY, false);

    certificateForm.append(hiddenField_id, hiddenField_strict, hiddenField_nodeClass,
        nameComponent, descriptionComponent, fromComponent, toComponent
        , gradeComponent);
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
    var idString = '';
    if (!$.isEmptyObject(workExperienceNode)) {
        var properties = workExperienceNode.properties;
        nameString = propValue(properties.name);
        companyString = propValue(properties.company);
        tradeString = propValue(properties.trade);
        countryString = propValue(properties.country);
        fromString = propValue(properties.from);
        toString = propValue(properties.to);
        assignmentsString = propValue(properties.assignment);
        idString = workExperienceNode.id;
    }

    var form = buildUpdateForm(formId);
    var div = $('<div>');
    div.addClass('delimitedForm');

    var hiddenField_id = hiddenField('_nodeId', idString);
    var hiddenField_strict = hiddenField('_strict', 'false');
    var hiddenField_nodeClass = hiddenField('nodeclass', 'workexperience');

    var nameComponent = typeaheadInputComponent('Tidigare befattning', 'name', nameString, formId, WORKEXPERIENCE_NAME_CATEGORY, false);
    var companyComponent = typeaheadInputComponent('Företag', 'company', companyString, formId, WORKEXPERIENCE_COMPANY_CATEGORY, false);
    var tradeComponent = typeaheadInputComponent('Bransch', 'trade', tradeString, formId, WORKEXPERIENCE_TRADE_CATEGORY, false);
    var countryComponent = typeaheadInputComponent('Land', 'country', countryString, formId, COUNTRY_CATEGORY, false);
    var fromComponent = dateInputComponent('Från och med', 'from:date:yyyy-MM-dd', fromString, formId, false);
    var toComponent = dateInputComponent('Till och med', 'to:date:yyyy-MM-dd', toString, formId, false);
    var assignmentComponent = textAreaInputComponent('Uppgifter', 'assignment', assignmentsString, formId, 'assignment-field');

    form.append(hiddenField_id, hiddenField_strict, hiddenField_nodeClass,
        nameComponent, companyComponent, tradeComponent, countryComponent,
        fromComponent, toComponent, assignmentComponent);
    div.append(form);
    return div;
}

function generateMilitaryServiceForm(form_Id, militaryServiceNode) {
    var formId = form_Id;

    var nameString = '';
    var descriptionString = '';
    var idString;
    if (!$.isEmptyObject(militaryServiceNode)) {
        var properties = militaryServiceNode.properties;
        nameString = propValue(properties.name);
        descriptionString = propValue(properties.description);
        idString = militaryServiceNode.id;
    }

    var form = buildUpdateForm(formId);
    var div = $('<div>');
    div.addClass('delimitedForm');

    var hiddenField_id = hiddenField('_nodeId', idString);
    var hiddenField_strict = hiddenField('_strict', 'false');
    var hiddenField_nodeClass = hiddenField('nodeclass', 'militaryservice');

    var nameComponent = typeaheadInputComponent('Militärtjänst', 'name', nameString, formId, MILITARYSERVICE_NAME_CATEGORY, false);
    var descriptionComponent = textAreaInputComponent('Beskrivning', 'description', descriptionString, formId, 'description-field');

    form.append(hiddenField_id, hiddenField_strict, hiddenField_nodeClass,
        nameComponent, '<br/>', descriptionComponent);
    div.append(form);
    return div;
}

function addEducationButton(nodeId) {
    var button = $('<button>');
    button.attr('id', 'educationButton')
    button.html('Lägg till utbildning');
    button.click(function() {
        var formId = getFormId("HAS_EDUCATION", 0);
        generateEducationForm(formId).insertBefore("#educationButton");
    });
    return button;
}

function addCertificateButton(nodeId) {
    var button = $('<button>');
    button.attr('id', 'certificateButton')
    button.html('Lägg till certifikat');
    button.click(function() {
        var formId = getFormId("HAS_CERTIFICATE", 0);
        generateCertificateForm(formId).insertBefore('#certificateButton');
    });
    return button;
}

function addLanguageButton(nodeId) {
    var button = $('<button>');
    button.attr('id', 'languageButton')
    button.html('Lägg till språk');
    button.click(function() {
        var formId = getFormId("HAS_LANGUAGESKILL", 0);
        generateLanguageForm(formId).insertBefore('#languageButton');
    });
    return button;
}

function addWorkExperienceButton(nodeId) {
    var button = $('<button>');
    button.attr('id', 'workExperienceButton')
    button.html('Lägg till tidigare befattning');
    button.click(function() {
        var formId = getFormId("HAS_WORK_EXPERIENCE", 0);
        generateWorkExperienceForm(formId).insertBefore('#workExperienceButton');
    });
    return button;
}

function addMilitaryServiceButton(nodeId) {
    var button = $('<button>');
    button.attr('id', 'militaryServiceButton')
    button.html('Lägg till Militärtjänst');
    button.click(function() {
        var formId = getFormId("HAS_MILITARY_SERVICE", 0);
        generateMilitaryServiceForm(formId).insertBefore('#militaryServiceButton');
    });
    return button;
}

function getFormId(formId, count) {
    var form = $('#' + formId + count);
    if (form.val() == null) {
        return formId + count;
    }
    else
        return getFormId(formId, (count + 1));
}

function addExistingValuesOrCreateEmptyForms(nodeId, type, formGeneratingFunction, divToPrepend) {
    if (nodeId == null || nodeId == '') //new person
        formGeneratingFunction.call(this, type).prependTo(divToPrepend);
    else { //existing person
        $.getJSON("fairview/ajax/get_relationship_endnodes.do", {_nodeId: nodeId, _type: type}, function(data) {
            if (!$.isEmptyObject(data.list)) {
                var array = data.list["node"];
                $.each(array, function(count, object) {
                    formGeneratingFunction.call(this, object.id, object).prependTo(divToPrepend);
                });
            }
            else { //no values of the type exists so create empty form
                formGeneratingFunction.call(this, type).prependTo(divToPrepend);
            }
        });
    }
}

function createRelationship(startNodeId, endNodeId, type, callback) {
    $.getJSON("neo/ajax/create_relationship.do", {_startNodeId:startNodeId, _endNodeId: endNodeId,_type:type }, function() {
        if (typeof(callback) == 'function') {
            callback.call();
        }
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

function createNodeWithRelationship(form, nodeId, callback) {
    $(form).ajaxSubmit(function(data) {
        var formId = $(form).attr('id').replace(/\d+/, '');
        switch (formId) {
            case "HAS_MILITARY_SERVICE":
                createRelationship(nodeId, data.node.id, formId, callback);
                break;
            case "HAS_EDUCATION":
                createRelationship(nodeId, data.node.id, formId, callback);
                break;
            case "HAS_LANGUAGESKILL":
                createRelationship(nodeId, data.node.id, formId, callback);
                break;
            case "HAS_CERTIFICATE":
                createRelationship(nodeId, data.node.id, formId, callback);
                break;
            case "HAS_WORK_EXPERIENCE":
                createRelationship(nodeId, data.node.id, formId, callback);
                break;
            case "new_employment_form":
                createRelationship(nodeId, data.node.id, 'HAS_EMPLOYMENT', callback);
                break;
            case "new_person_form":
                $.getJSON("/fairview/ajax/get_organization_node.do", function(organizationNode) {
                    createRelationship(organizationNode.id, data.node.id, 'HAS_EMPLOYEE', callback);
                })
                break;
            default:
                if (typeof(callback) == 'function')
                    callback.call();
        }
    });
}
function createPersonNodeBeforeCreatingOtherNodes(forms, callback) {
    $('#new_person_form').ajaxSubmit(function(createdEmployee) {
        $.getJSON("fairview/ajax/get_organization_node.do", function(organizationNode) {
            $.getJSON("neo/ajax/create_relationship.do",
                {_startNodeId:organizationNode['node'].id, _endNodeId: createdEmployee.node.id,_type:'HAS_EMPLOYEE' },
                function() {
                    var dirtyFormExists = false;
                    $.each(forms, function(i, form) {
                        if ($(form).attr('id') != 'new_person_form' && $(form).data('edited') == 'true') {  //don't create the relationship twice
                            dirtyFormExists = true;
                            if (i == (forms.length - 1))
                                createNodeWithRelationship(form, createdEmployee.node.id, callback);
                            else
                                createNodeWithRelationship(form, createdEmployee.node.id);
                        }
                    });
                    if (!dirtyFormExists) { //if no dirty forms were submitted, no callback was made and thus we make it here instead
                        if (typeof(callback) == 'function')
                            callback.call();
                    }
                });
        });
    });
}
function createNodes(forms, nodeId, callback) {
    $.each(forms, function(i, form) {
        if ($(form).data('edited') == 'true') {
            if (i == (forms.length - 1))
                createNodeWithRelationship(form, nodeId, callback);
            else
                createNodeWithRelationship(form, nodeId);

        }
    });
}
function addWordsToDictionary() {
    var editedCategoryInputs = $('input:data(edited=true)');
    $.each(editedCategoryInputs, function(count, data) {
        var cat = $(data).data('category');
        var val = $(data).val();
        if (cat != null && val != '') {
            $.getJSON("/fairview/ajax/add_word.do", {category: cat, value:val}, function(response) {
            });
        }
    });
}
function generateSaveButton(nodeId, callback) {
    var saveButton = $('<button>');
    saveButton.html('Spara');
    saveButton.addClass('saveButton');
    saveButton.attr('disabled', 'disabled');

    saveButton.click(function() {
        disableSaveButton();
        saveButton.html('Sparar...');
        setTimeout(closePopup, 500);

        var editedForms = $('form:data(edited=true)');
        var newPerson = existsNewPersonForm(editedForms);

        if (newPerson == true) { //in order for other nodes to be created, they need a person node to create a relationship to
            createPersonNodeBeforeCreatingOtherNodes(editedForms, callback);
        }
        else {
            createNodes(editedForms, nodeId, callback);
        }
        addWordsToDictionary();
    });

    return saveButton;
}

function existsNewPersonForm(forms) {
    var newPerson = false;
    $.each(forms, function(i, form) {
        if ($(form).attr('id') == 'new_person_form') {
            newPerson = true;
            return false;
        }
    });
    return newPerson;
}

function generateCancelButton() {
    var cancelButton = $('<button>');
    cancelButton.html('Avbryt');
    cancelButton.attr('id', 'cancelButton');
    cancelButton.click(function() {
        var edited;
        var forms = $('form');
        $.each(forms, function(i, form) {
            if ($(form).data('edited') == 'true') {
                edited = 'true';
            }
        });
        if (edited == 'true') {
            generateAlertDialog('Är du säker?', 'Du har osparade ändringar. Är du säker på att du vill stänga formuläret?',
                closePopup);
        } else {
            closePopup();
        }
    });
    return cancelButton;
}

function generateAlertDialog(title, text, fn, fnArg) {
    var cancelDialog = $('<div>');
    cancelDialog.attr('title', title);
    cancelDialog.html(text);
    cancelDialog.dialog({
        resizable: false,
        height:140,
        modal: true,
        buttons: {
            "Ja": function() {
                $(this).dialog("close");
                if (typeof(fn) == 'function')
                    fn.call(this, fnArg);
            },
            "Nej": function() {
                $(this).dialog("close");
            }
        }
    });
}

function generateDeleteDialog(nodeId) {
    var deleteDialog = $('<div>');
    deleteDialog.attr('title', 'Borttagning av enhet');
    deleteDialog.html('Är du säker på att du vill ta bort enheten?');
    deleteDialog.dialog({
        resizable: false,
        height: 140,
        modal: true,
        buttons:{
            "Ja": function() {
                $(this).dialog("close");
                $.getJSON("fairview/ajax/delete_unit.do", {_nodeId:nodeId}, function() {
                    location.reload();
                });
            },
            "Nej":function() {
                $(this).dialog("close");
            }

        }
    });
}

function generateWarningDialog(title, text) {
    var cancelDialog = $('<div>');
    cancelDialog.attr('title', title);
    cancelDialog.html(text);
    cancelDialog.dialog({
        resizable: false,
        height:140,
        modal: true,
        buttons: {
            "Ok": function() {
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
function footerButtonsComponent(nodeId, callback) {
    var saveDiv = $('<div>');
    saveDiv.addClass('saveDiv');
    var saveButton = generateSaveButton(nodeId, callback);
    var cancelButton = generateCancelButton();
    saveDiv.append(saveButton, cancelButton);
    return saveDiv;
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

function appendManagerOption(node, assignedManagerId, managerInputElement) {
    var option = $('<option>');
    option.attr('value', node.id);
    option.html(propValue(node.properties.firstname) + ' ' + propValue(node.properties.lastname));
    if (assignedManagerId.long == node.id)
        option.attr('selected', 'true');
    managerInputElement.append(option);
}
function createManagerList(assignedManagerId, managerInputElement) {
    $.getJSON("/fairview/ajax/get_persons.do", function(data) {
        var array = data.list['node']
        if (array != null && array.length != null) {
            $.each(array, function(count, node) {
                appendManagerOption(node, assignedManagerId, managerInputElement);
            });
        } else if (array != null) {
            appendManagerOption(array, assignedManagerId, managerInputElement);
        }

    });
}
function addManagerOptions(unitId, managerInputElement) {
    var option = $('<option>');
    option.attr('value', -1);
    option.html('Ingen chef vald');
    managerInputElement.append(option);
    if (unitId == null) {
        createManagerList(-1, managerInputElement);
    } else {
        $.getJSON("/fairview/ajax/get_manager.do", {_unitId: unitId}, function(assignedManagerId) {
            createManagerList(assignedManagerId, managerInputElement);
        });
    }
}

function createUnitSelect(labelText, inputName, divId, formId, required, unitId) {

    var selectDiv = fieldBox();
    selectDiv.attr("id", divId);
    var selectLabel = fieldLabelBox();
    selectLabel.append(labelText);
    var selectInput = $('<select>');
    selectInput.attr("name", inputName);
    selectInput.attr("id", inputName + "-field");
    selectInput.change(function() {
        setFormEdited(formId);
        validateForm(formId);
    });
    if (required == true) {
        makeInputRequired(selectLabel, selectInput);
    }
    selectDiv.append(selectLabel, selectInput, $('<br>'));

    $.ajax({
            dataType: 'json',
            async: false,
            url:'fairview/ajax/get_units.do', success: function(data) {

                try {

                    $.each(data.list.node, function(i) {

                        var option = $('<option>');
                        option.html(data.list.node[i].properties.name.value);
                        option.attr('value', data.list.node[i].id);

                        if (unitId != null && unitId == data.list.node[i].id) {
                            option.attr('selected', 'selected');
                        }
                        selectInput.append(option);
                    });

                } catch(e) {

                    var option = $('<option>');
                    option.html(data.list.node.properties.name.value);
                    option.attr('value', data.list.node.id);
                    option.attr('selected', 'selected');
                    selectInput.append(option);

                }
            }
        }
    );

    return selectDiv;

}

function addPaymentFormOption(paymentForm, paymentFormInputElement) {
    var salaryFormOptions = new Array('Månadslön', 'Tvåveckorslön', 'Veckolön', 'Timlön');

    if (propValue(paymentForm) == '' || propValue(paymentForm) == 'Välj...') {
        var optionChoose = $('<option>');
        optionChoose.html('Välj...');
        optionChoose.attr('selected', 'true');
        paymentFormInputElement.append(optionChoose);
    }

    $.each(salaryFormOptions, function(i, data) {
        var optionDiv = $('<option>');
        optionDiv.attr('value', data);
        optionDiv.html(data);
        if (propValue(paymentForm) == data)
            optionDiv.attr('selected', 'true');
        paymentFormInputElement.append(optionDiv);
    });
}
function addDismissalPeriod(dismissalPeriod, dismissalPeriodInputElement) {
    if (propValue(dismissalPeriod) == '' || propValue(dismissalPeriod) == 'Välj...');
    {
        var optionChoose = $('<option>');
        optionChoose.html('Välj...');
        optionChoose.val(-1);
        optionChoose.attr('selected', 'true');
        dismissalPeriodInputElement.append(optionChoose);
    }
    for (var i = 1; i < 13; i++) {
        var optionDiv = $('<option>');
        optionDiv.attr('value', i);
        if (i == 1)
            optionDiv.html(i + " månad");
        else
            optionDiv.html(i + " månader");
        if (propValue(dismissalPeriod) == i)
            optionDiv.attr('selected', 'true');
        dismissalPeriodInputElement.append(optionDiv);
    }
}

function makeBirthdate(civicnumber) {
    if (civicnumber.toString().length > 6)
        return civicnumber.toString().substr(0, 6);
    else
        return civicnumber;
}

function fieldLabelBox() {
    return $('<div class="field-label-box">');
}
function fieldBox() {
    return $('<div class="field-box">');
}

function fieldCheckboxBox() {
    return $('<div class="field-checkbox-box">')
}

function fieldInputBox() {
    return $('<div class="field-input-box">')
}

function formIsValid(formId) {
    return $('#' + formId).valid();
}
function makeInputRequired(label, input) {
    label.append(' *');
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
        setFormEdited(formId);
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
function setFormEdited(formId) {
    $('#' + formId).data('edited', 'true');
}
function setInputEdited(input) {
    input.data('edited', 'true');
}
function typeaheadInputComponent(labelText, inputName, value, formId, category, required) {
    var inputDiv = fieldBox();
    var inputLabel = fieldLabelBox();
    inputLabel.append(labelText);
    var textInput = $('<input type="text">');
    textInput.addClass("text-field");
    textInput.attr("id", inputName + "-field");
    textInput.attr("name", inputName);
    textInput.val(value);
    textInput.change(function() {
        setFormEdited(formId);
        setInputEdited(textInput);
        validateForm(formId);
    });
    textInput.keyup(function() {
        validateForm(formId);
    });
    textInput.attr('data-category', category);
    $.getJSON("/fairview/ajax/get_words.do", {category:category}, function(response) {
        if (response.sortedset != null) { //if the response is a string, an error has occured
            var tags = response.sortedset.string;
            $.each(tags, function(count, object) {
                tags[count] = object.toString(); //because for some reason, Java Strings representing numbers kept becoming javascript-numbers
            });
            textInput.autocomplete({
                source: tags,
                minLength: 0,
                select: function() {
                    setFormEdited(formId);
                    setInputEdited(textInput);
                    validateForm(formId);
                }
            });
            $("<button type='button'>&nbsp;</button>")
                .attr("tabIndex", -1)
                .attr("title", "Show All Items")
                .insertAfter(textInput)
                .button({
                    icons: {
                        primary: "ui-icon-triangle-1-s"
                    },
                    text: false
                })
                .removeClass("ui-corner-all")
                .addClass("ui-corner-right ui-button-icon")
                .click(function() {
                    // close if already visible
                    if (textInput.autocomplete("widget").is(":visible")) {
                        textInput.autocomplete("close");
                        return;
                    }
                    $(this).blur();
                    textInput.autocomplete("search", "");
                    textInput.focus();
                });
        }
    });


    if (required == true) {
        makeInputRequired(inputLabel, textInput);
    }
    inputDiv.append(inputLabel, textInput);
    return inputDiv;
}

function dateInputComponent(labelText, inputName, value, formId, required) {
    var inputDiv = fieldBox();
    var inputLabel = fieldLabelBox();
    inputLabel.append(labelText);
    var textInput = $('<input type="text">');
    textInput.addClass("datepicker");
    textInput.attr("id", inputName + "_" + formId);
    textInput.attr("name", inputName);
    textInput.val(value.split(' ')[0]);
    textInput.datepicker({  changeYear: true,
        changeMonth:true,
        yearRange: "-50:+1",
        dateFormat: "yy-mm-dd",
        firstDay: 1,
        showMonthAfterYear: true
    });
    textInput.change(function() {
        setFormEdited(formId);
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

function radioButtonInputComponent(labelText, inputName, formId, radioButtonData, selected) {
    var inputDiv = fieldBox();
    var inputLabel = fieldLabelBox();
    var inputBox = fieldInputBox();
    inputLabel.append(labelText);
    inputDiv.append(inputLabel);
    $.each(radioButtonData, function(i) {
        var label = $('<label>');
        label.attr('for', radioButtonData[i][1]);
        label.append(radioButtonData[i][0]);
        var radioButton = $('<input type="radio">');
        radioButton.attr('name', inputName);
        radioButton.attr('id', radioButtonData[i][1]);
        radioButton.attr('value', radioButtonData[i][1]);
        radioButton.click(function() {
            validateForm(formId);
        });
        radioButton.change(function() {
            setFormEdited(formId);
        });
        if (radioButtonData[i][1] == selected)
            radioButton.attr('checked', 'checked');
        radioButton.addClass('radiobutton');
        inputBox.append(label);
        inputBox.append(radioButton);
    });
    inputDiv.append(inputBox);
    return inputDiv;
}

function checkboxInputComponent(labelText, formId, checkboxData) {
    var inputDiv = fieldBox();
    var inputLabel = fieldLabelBox();
    inputLabel.append(labelText);
    inputDiv.append(inputLabel);
    $.each(checkboxData, function(i) {
        var inputBoxDiv = fieldCheckboxBox();
        var hidden = $('<input type="hidden" >');
        hidden.attr('id', checkboxData[i][0] + "-field");
        hidden.attr('name', checkboxData[i][0]);
        hidden.attr('value', (checkboxData[i][2]));
        var label = $('<label>');
        label.attr('for', 'pseudo-' + checkboxData[i][0]);
        label.append(checkboxData[i][1]);
        label.addClass('checkbox');
        var checkbox = $('<input />');
        checkbox.attr('type', 'checkbox');
        checkbox.attr('id', 'pseudo-' + checkboxData[i][0]);
        //checkbox.addClass('checkbox');
        if (checkboxData[i][2] == true)
            checkbox.attr('checked', 'checked');
        checkbox.change(function(event) {
            var checkbox = event.target.id.toString().replace("pseudo-", "");

            $('#' + checkbox + '-field').val(event.target.checked);
        });
        //checkbox.append(checkboxData[i][1]);
        checkbox.click(function() {
            validateForm(formId);
        });
        checkbox.change(function() {
            setFormEdited(formId);
        });

        inputBoxDiv.append(hidden);
        hidden.after(label);
        hidden.after(checkbox);

        inputDiv.append(inputBoxDiv);
    });
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
        setFormEdited(formId);
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
function getUnitData(nodeId) {
    var data = $.parseJSON($.ajax({
        url:"neo/ajax/get_node.do",
        data:{_nodeId:nodeId},
        async:false,
        dataType:"json"
    }).responseText);
    return data;
}
function buildUpdateForm(id, action) {

    if (action == null) {
        action = "neo/ajax/update_node.do";
    }

    var updateForm = $('<form>');
    updateForm.attr("id", id);
    updateForm.attr("action", action);
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
        setFormEdited(formId);
    });
    textareaInput.keyup(function() {
        validateForm(formId);
    });
    textareaDiv.append(textareaLabel, textareaInput, $('<br>'));
    return textareaDiv;
}

function enableCreateUnitButton() {
    $('.addsubunit-button').removeAttr('disabled');
}
function disableCreateUnitButton() {
    $('.addsubunit-button').attr('disabled', 'disabled');
}
function validateForm(formId) {
    if (formIsValid(formId)) {
        enableSaveButton();
        enableCreateUnitButton();
        return true;
    }
    else {
        disableSaveButton();
        disableCreateUnitButton();
        return false;
    }
}
function selectInputComponent(labelText, propertyName, divId, formId, required) {

    var selectDiv = fieldBox();
    selectDiv.attr("id", divId);

    var selectLabel = fieldLabelBox();
    selectLabel.append(labelText);

    var selectInput = $('<select>');

    var inputId = propertyName.split(":")[0];

    selectInput.attr("name", propertyName);
    selectInput.attr("id", inputId + "-field");
    selectInput.change(function() {
        setFormEdited(formId);
        validateForm(formId);
    });
    if (required == true) {
        makeInputRequired(selectLabel, selectInput);
    }
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

    var regnrString = '';
    if (properties != null) {
        regnrString = propValue(properties.regnr);
    }

    var orgnrDiv = textInputComponent('Organisationsnummer', 'regnr', regnrString, getOrganizationFormId());
    return orgnrDiv;
}

function generateImageUrlDiv(data) {
    var properties = data.node.properties;
    var imageurlString = '';
    if (properties != null) {
        imageurlString = propValue(properties.imageurl);
    }
    var imageUrlDiv = textInputComponent('Länk till företagslogotyp', 'imageurl', imageurlString, getOrganizationFormId());
    return imageUrlDiv;
}

function generateSingleAddressComponent(data) {
    var properties = data.node.properties;

    var addressString = '';
    var postalcodeString = '';
    var cityString = '';
    var countryString = '';
    if (properties != null) {
        addressString = propValue(properties.address);
        postalcodeString = propValue(properties.postalcode);
        cityString = propValue(properties.city);
        countryString = propValue(properties.country);
    }

    var addressComponent = $('<div>');
    var addressDiv = textInputComponent('Adress', 'address', addressString, getOrganizationFormId());
    var postnummerDiv = typeaheadInputComponent('Postnummer', 'postalcode', postalcodeString, getOrganizationFormId(), POSTALCODE_CATEGORY);
    var cityDiv = typeaheadInputComponent('Ort', 'city', cityString, getOrganizationFormId(), CITY_CATEGORY);
    var countryDiv = typeaheadInputComponent('Land', 'country', countryString, getOrganizationFormId(), COUNTRY_CATEGORY);

    addressComponent.append(addressDiv, postnummerDiv, cityDiv, countryDiv);
    return addressComponent;
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

function yesNo() {
    return  [
        ['Ja', true],
        ['Nej', false]
    ];
}

function translatePseudoCheckbox(event, form_name) {

    var checkbox = event.target.id.toString().replace("pseudo-", "");

    $('#' + checkbox + '-field').val(event.target.checked);

    if (checkbox == "authorization") {

        if (event.target.checked) {

            $('#authorization-amount-field').show();

        } else {

            $('#authorization-amount-field').hide();

        }

    }

    $('#' + form_name).ajaxSubmit();

}
