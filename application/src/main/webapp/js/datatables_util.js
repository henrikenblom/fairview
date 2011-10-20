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

function initFunctionCell(data, cell){
    $(cell).unbind();
    $(cell).css('cursor', 'pointer');

    $(cell).click(function(){
        createFunctionTab(data);
        openFunctionForm();
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

function addFormContainers() {
    var languageDiv = $('<div>');
    languageDiv.attr('id', 'languages');
    languageDiv.addClass('groupedFormsContainer');
    var certificateDiv = $('<div>');
    certificateDiv.attr('id', 'certificates');
    certificateDiv.addClass('groupedFormsContainer');
    var educationDiv = $('<div>');
    educationDiv.addClass('groupedFormsContainer');
    educationDiv.attr('id', 'educations');

    var workExperienceDiv = $('<div>');
    workExperienceDiv.addClass('groupedFormsContainer');
    workExperienceDiv.attr('id', 'workexperiences');
    var militaryServiceDiv = $('<div>');
    militaryServiceDiv.addClass('groupedFormsContainer');
    militaryServiceDiv.attr('id', 'militaryservices');

    $('#profile-education').append(languageDiv, certificateDiv, educationDiv);
    $('#profile-experience').append(workExperienceDiv, militaryServiceDiv);
}

function loadFormValues(unitId) {
    addExistingValuesOrCreateEmptyForms(unitId, 'HAS_LANGUAGESKILL', generateLanguageForm, '#languages');
    addExistingValuesOrCreateEmptyForms(unitId, 'HAS_EDUCATION', generateEducationForm, '#educations');
    addExistingValuesOrCreateEmptyForms(unitId, 'HAS_CERTIFICATE', generateCertificateForm, '#certificates');
    addExistingValuesOrCreateEmptyForms(unitId, 'HAS_WORK_EXPERIENCE', generateWorkExperienceForm, '#workexperiences');
    addExistingValuesOrCreateEmptyForms(unitId, 'HAS_MILITARY_SERVICE', generateMilitaryServiceForm, '#militaryservices');
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

function generateProfileForm(nodeId, newEmployee) {
    var data;
    clearProfileForm();

    if (!$.isEmptyObject(nodeId)) {
        data = getUnitData(nodeId);
    }
    $.getJSON("fairview/ajax/has_image.do", {_nodeId: nodeId}, function(hasImage) {
        addFormContainers();
        loadFormValues(nodeId);

        $('#profile-general').append(generateProfileGeneralForm(data));


        if (newEmployee != true)
            $('#profile-general').append(generateSmallImage(nodeId, hasImage));

        $('#profile-general').append(footerButtonsComponent(nodeId, updateTableCallback(oTable)));

        $('#languages').append(addLanguageButton(nodeId));
        $('#educations').append(addEducationButton(nodeId));
        $('#certificates').append(addCertificateButton(nodeId));
        $('#profile-education').append(footerButtonsComponent(nodeId, updateTableCallback(oTable)));


        $('#workexperiences').append(addWorkExperienceButton(nodeId));
        $('#militaryservices').append(addMilitaryServiceButton(nodeId));
        $('#profile-experience').append(footerButtonsComponent(nodeId, updateTableCallback(oTable)));

        $('#profile-image').append(generateImageForm(nodeId, hasImage));
    });
}

//---Delete
function getEmployeeDeleteButton(obj) {
    return "<a title='ta bort person' onclick='deleteAlertEmployee(" + obj.aData.employee_id + ");' class='imageonly-button'><img src='images/delete.png'></a>";
}

function deleteAlertEmployee(id) {
    generateAlertDialog('Borttagning av person', 'Är du säker på att du vill ta bort personen?',
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
    bindTabs();
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
    bindTabs();
    generateProfileForm(data.employee_id, newEmployee);
}

function createFunctionTab(data){
    var linkData = [
        ['function-general', 'Funktion'],
        ['function-task', 'Uppgifter']
    ];

    $('#popup-dialog').empty().append(generateTabs(linkData));
    bindTabs();
    generateFunctionForm(data.node_Id);
}

function hasRole(role) {
    if ($.inArray(role, ROLELIST) > -1)
        return true;
    else
        return false;
}