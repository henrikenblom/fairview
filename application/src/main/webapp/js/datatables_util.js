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

function generateProfileForm(unitId) {
    var data;

    clearProfileForm();

    if (!$.isEmptyObject(unitId)) {
        data = getUnitData(unitId);
    }

    addFormContainers();
    loadFormValues(unitId);


    $('#profile-general').append(generateImageForm());
    createUploader();
    $('#profile-general').append(generateProfileGeneralForm(data));

    $('#profile-general').append(footerButtonsComponent(unitId, updateTableCallback(oTable)));

    $('#languages').append(addLanguageButton(unitId));
    $('#educations').append(addEducationButton(unitId));
    $('#certificates').append(addCertificateButton(unitId));
    $('#profile-education').append(footerButtonsComponent(unitId, updateTableCallback(oTable)));


    $('#workexperiences').append(addWorkExperienceButton(unitId));
    $('#militaryservices').append(addMilitaryServiceButton(unitId));
    $('#profile-experience').append(footerButtonsComponent(unitId, updateTableCallback(oTable)));
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

function createEmployeeTab(data) {

            var linkData = [
                ['profile-general', 'Personuppgifter'],
                ['profile-education', 'Utbildning'],
                ['profile-experience', 'Erfarenhet']
            ];
            $('#popup-dialog').empty().append(generateTabs(linkData));
            bindTabs();
            generateProfileForm(data.employee_id);
        }

function hasRole(role) {
    if ($.inArray(role, ROLELIST) > -1)
        return true;
    else
        return false;
}

function createUploader() {
            var uploader = new qq.FileUploader({
                element: document.getElementById('imageUploadDiv'),
                action: '/fairview/ajax/submit_profileimage.do',
                debug: true
            });
        }