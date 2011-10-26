/**
 * Created by IntelliJ IDEA.
 * User: fairview
 * Date: 9/8/11
 * Time: 10:30 AM
 * To change this template use File | Settings | File Templates.
 */

$.fn.dataTableExt.oApi.fnReloadAjax = function (oSettings, sNewSource, fnCallback, bStandingRedraw) {
    //documentation: http://datatables.net/plug-ins/api#fnReloadAjax
    if (typeof sNewSource != 'undefined' && sNewSource != null) {
        oSettings.sAjaxSource = sNewSource;
    }
    this.oApi._fnProcessingDisplay(oSettings, true);
    var that = this;
    var iStart = oSettings._iDisplayStart;

    oSettings.fnServerData(oSettings.sAjaxSource, [], function(json) {
        /* Clear the old information from the table */
        that.oApi._fnClearTable(oSettings);

        /* Got the data - add it to the table */
        for (var i = 0; i < json.aaData.length; i++) {
            that.oApi._fnAddData(oSettings, json.aaData[i]);
        }

        oSettings.aiDisplay = oSettings.aiDisplayMaster.slice();
        that.fnDraw();

        if (typeof bStandingRedraw != 'undefined' && bStandingRedraw === true) {
            oSettings._iDisplayStart = iStart;
            that.fnDraw(false);
        }

        that.oApi._fnProcessingDisplay(oSettings, false);

        /* Callback user function - for event handlers etc */
        if (typeof fnCallback == 'function' && fnCallback != null) {
            fnCallback(oSettings);
        }
    }, oSettings);
}

function initEmploymentCell(data, cell) {
    $(cell).unbind();
    $(cell).css('cursor', 'pointer');

    $(cell).click(function() {
        createEmploymentTab(data);
        openEmploymentForm();
    });

    if ($(cell).html().length < 1) {
        $(cell).html('Lägg till');
    }

}

function initFunctionCell(data, cell, popupIndex) {
    $(cell).unbind();
    $(cell).css('cursor', 'pointer');

    $(cell).click(function() {
        createFunctionTab(data);
        openFunctionForm(data, popupIndex);
    });
}

function intExperienceProfileCell(data, cell, popupIndex){
    $(cell).unbind();
    $(cell).css('cursor', 'pointer');
    $(cell).click(function(){
        createExperienceProfileTab(data);
        openExperienceProfileForm(data, popupIndex);
    });
}

function initEmployeeCell(data, cell) {
    if (data.employee_id != "") {
        $(cell).unbind();
        $(cell).css('cursor', 'pointer');
        $(cell).click(function() {
            createEmployeeTab(data);
            openEmployeeForm();
        })
    }
}

function initTaskCell(data, cell, popupIndex) {
    $(cell).unbind();
    $(cell).css('cursor', 'pointer');

    $(cell).click(function() {
        createFunctionTab(data);
        openFunctionForm(data, popupIndex)
    });
}

function initUnitCell(unitId, cell) {
    if (unitId != "") {
        $(cell).unbind();
        $(cell).css('cursor', 'pointer');
        $(cell).click(function() {
            openUnitForm(unitId);
        })
    }
}

function updateTable(datatable) {
    datatable.fnReloadAjax(null, null, true);
}

function clearProfileForm() {
    $('#profile-general').empty();
    $('#profile-education').empty();
}

function getContainer(id, headerLabel) {
    var container = $('<div>');
    var formsDiv = $('<div>');
    formsDiv.attr('id', id);
    formsDiv.addClass('groupedFormsContainer');
    var headerDiv = $('<div>');
    var header = $('<h3>');
    header.html(headerLabel);
    headerDiv.append(header);
    headerDiv.addClass("education-header");
    container.append(headerDiv, formsDiv);
    return container;
}
function getContainers() {
    var languageContainer = getContainer('languages', 'Språk');
    var certificateContainer = getContainer('certificates', 'Certifikat');
    var educationContainer = getContainer('educations', 'Utbildningar');
    var workExperienceContainer = getContainer('workexperiences', 'Tidigare befattningar');
    var militaryServiceContainer = getContainer('militaryservices', 'Militärtjänst');
    var otherExperiencesContainer = getContainer('otherexperiences', 'Annan Erfarenhet');
    return {languageContainer:languageContainer, certificateContainer:certificateContainer,
        educationContainer:educationContainer, workExperienceContainer:workExperienceContainer,
        militaryServiceContainer:militaryServiceContainer, otherExperiencesContainer:otherExperiencesContainer};
}
function addProfileFormContainers() {
    var containers = getContainers();
    $('#profile-education').append(containers.languageContainer, containers.certificateContainer, containers.educationContainer);
    $('#profile-experience').append(containers.workExperienceContainer, containers.militaryServiceContainer, containers.otherExperiencesContainer);
}

function addExperienceProfileFormContainers() {
    var containers = getContainers();
    
    $('#experience-profile-education').append(containers.languageContainer, containers.certificateContainer, containers.educationContainer);
    $('#experience-profile-experience').append(containers.workExperienceContainer, containers.militaryServiceContainer, containers.otherExperiencesContainer);
}

function loadFormValues(unitId) {
    addExistingValuesOrCreateEmptyForms(unitId, 'HAS_LANGUAGESKILL', generateLanguageForm, '#languages');
    addExistingValuesOrCreateEmptyForms(unitId, 'HAS_EDUCATION', generateEducationForm, '#educations');
    addExistingValuesOrCreateEmptyForms(unitId, 'HAS_CERTIFICATE', generateCertificateForm, '#certificates');
    addExistingValuesOrCreateEmptyForms(unitId, 'HAS_WORK_EXPERIENCE', generateWorkExperienceForm, '#workexperiences');
    addExistingValuesOrCreateEmptyForms(unitId, 'HAS_MILITARY_SERVICE', generateMilitaryServiceForm, '#militaryservices');
    addExistingValuesOrCreateEmptyForms(unitId, 'HAS_OTHER_EXPERIENCE', generateOtherExperienceForm, '#otherexperiences');
}

function loadFirstFunctionForm(functionId){
    addExistingValuesOrCreateEmptyForms(functionId, 'HAS_TASK', generateTaskForm, '#function-task');
}

function addTypeValidation() {
    var intInputs = $('input[name*=":int"]');

    $.each(intInputs, function(count, object) {
        $(object).rules("add", {
            number: true
        });
    });

    var dateInputs = $('input[name*=":date"]');

    $.each(dateInputs, function(count, object) {
        $(object).rules("add", {
            dateISO: true
        });
    });
}
function generateEmploymentForm(data) {
    $('#employment-general').empty().append(generateEmploymentCreationForm(data));
    $('#employment-general').append(footerButtonsComponent(data.employee_id, updateTableCallback(oTable)));
    addTypeValidation();
    /*typeValidation was placed here rather than at input-creation level because that caused errors for some reason*/
}

function appendLanguageAndExperienceForms(nodeId, educationTabId, experienceTabId) {
    $('#languages').append(anotherFormButton('languageButton', 'HAS_LANGUAGESKILL', generateLanguageForm));
    $('#educations').append(anotherFormButton('educationButton', 'HAS_EDUCATION', generateEducationForm));
    $('#certificates').append(anotherFormButton('certificateButton', 'HAS_CERTIFICATE', generateCertificateForm));
    $(educationTabId).append(footerButtonsComponent(nodeId, updateTableCallback(oTable)));

    $('#workexperiences').append(anotherFormButton('workExperienceButton', 'HAS_WORK_EXPERIENCE', generateWorkExperienceForm));
    $('#militaryservices').append(anotherFormButton('militaryServiceButton', 'HAS_MILITARY_SERVICE', generateMilitaryServiceForm));
    $('#otherexperiences').append(anotherFormButton('otherExperienceButton', 'HAS_OTHER_EXPERIENCE', generateOtherExperienceForm));
    $(experienceTabId).append(footerButtonsComponent(nodeId, updateTableCallback(oTable)));
}
function generateProfileForm(nodeId, newEmployee) {
    var data;
    clearProfileForm();

    if (!$.isEmptyObject(nodeId)) {
        data = getUnitData(nodeId);
    }
    $.getJSON("fairview/ajax/has_image.do", {_nodeId: nodeId}, function(hasImage) {
        addProfileFormContainers();
        loadFormValues(nodeId);

        $('#profile-general').append(generateProfileGeneralForm(data));

        if (newEmployee != true)
            $('#profile-general').append(generateSmallImage(nodeId, hasImage));

        $('#profile-general').append(footerButtonsComponent(nodeId, updateTableCallback(oTable)));
        appendLanguageAndExperienceForms(nodeId, '#profile-education', '#profile-experience');
        $('#profile-image').append(generateImageForm(nodeId, hasImage));
    });
}

function generateEducationExperienceForExperienceProfileForm(nodeId) {
    var data;
    addExperienceProfileFormContainers();
    loadFormValues(nodeId);

    if (!$.isEmptyObject(nodeId)) {
        data = getUnitData(nodeId);
    }
    appendLanguageAndExperienceForms(nodeId, '#experience-profile-education', '#experience-profile-experience');
}

function generateExperienceProfileForm(nodeId) {
    var data;

    if (!$.isEmptyObject(nodeId)) {
        data = getUnitData(nodeId);
    }
    $('#experience-profile-general').append(generateExperienceProfileGeneralForm(data));
    $('#experience-profile-education');
    $('#experience-profile-experience');
}

function generateFunctionForm(nodeId) {
    var data;
    loadFirstFunctionForm(nodeId);

    if (!$.isEmptyObject(nodeId)) {
        data = getUnitData(nodeId);
    }
    $('#function-general').append(generateFunctionGeneralForm(data));
    $('#function-task').append(anotherFormButton('taskButton', 'HAS_TASK', generateTaskForm));
    $('#function-task').append(footerButtonsComponent(nodeId, updateTableCallback(oTable)));
}

//---Delete
function getEmployeeDeleteButton(obj) {
    return "<a title='ta bort person' onclick='deleteAlertEmployee(" + obj.aData.employee_id + ");' class='imageonly-button'><img src='images/delete.png'></a>";
}

function getFunctionDeleteButton(obj) {
    return "<a title='ta bort funktion' onclick='deleteAlertFunction(" + obj.aData.function_id + ");' class='imageonly-button'><img src='images/delete.png'></a>";
}

function getExperienceProfileDeleteButton(obj) {
    return "<a title='ta bort kompetensprofil' onclick='deleteAlertExperienceProfile(" + obj.aData.id + ");' class='imageonly-button'><img src='images/delete.png'></a>";
}

function deleteAlertEmployee(id) {
    generateAlertDialog('Borttagning av person', 'Är du säker på att du vill ta bort personen?',
        deleteRow, id);
}

function deleteAlertFunction(id) {
    generateAlertDialog('Borttagning av funktion', 'Är du säker på att du vill ta bort funktionen?',
        deleteRow, id);
}

function deleteAlertExperienceProfile(id) {
    generateAlertDialog('Borttagning av kompetensprofil', 'Är du säker på att du vill ta bort kompetensprofilen?',
        deleteRow, id);
}

function deleteAlertEmployment(id) {
    generateAlertDialog('Borttagning av anställning', 'Är du säker på att du vill ta bort anställningen?',
        deleteRow, id);
}

function deleteRow(id) {
    $.getJSON("neo/ajax/delete_node.do", {_nodeId: id}, function() {
        updateTable(oTable);
    });
}

function getEmploymentDeleteButton(obj) {
    return "<a title='ta bort anställning' onclick='deleteAlertEmployment(" + obj.aData.employment_id + ");' class='imageonly-button'><img src='images/delete.png'></a>";
}

function createEmploymentTab(data) {
    var linkData = [
        ['employment-general', 'Anställningsvillkor'],
        ['employment-requirements','Krav']
    ];
    $('#popup-dialog').empty().append(generateTabs(linkData));
    bindEmployeeTabs();
    generateEmploymentForm(data);
}

function createEmployeeTab(data, newEmployee) {

    if (newEmployee == true) {
        var linkData = [
            ['profile-general', 'Personuppgifter'],
            ['profile-education', 'Utbildning'],
            ['profile-experience', 'Erfarenhet']
        ];
    } else {
        var linkData = [
            ['profile-general', 'Personuppgifter'],
            ['profile-education', 'Utbildning'],
            ['profile-experience', 'Erfarenhet'],
            ['profile-image', 'Bild']
        ];
    }

    $('#popup-dialog').empty().append(generateTabs(linkData));
    bindEmployeeTabs();
    generateProfileForm(data.employee_id, newEmployee);
}

function createExperienceProfileTab(data) {
    var linkData = [
        ['experience-profile-general','Kompetensprofil'],
        ['experience-profile-education', 'Utbildning'],
        ['experience-profile-experience', 'Erfarenhet']
    ];

    $('#popup-dialog').empty().append(generateTabs(linkData));
    bindExperienceProfileTabs();
    generateExperienceProfileForm(data.id);
    generateEducationExperienceForExperienceProfileForm(data.id);
}

function createFunctionTab(data) {
    var linkData = [
        ['function-general', 'Funktion'],
        ['function-task', 'Uppgifter']
    ];

    $('#popup-dialog').empty().append(generateTabs(linkData));
    bindFunctionTabs();
    generateFunctionForm(data.function_id);
}

function hasRole(role) {
    if ($.inArray(role, ROLELIST) > -1)
        return true;
    else
        return false;
}