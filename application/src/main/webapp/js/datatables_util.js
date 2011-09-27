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

function initEmploymentCell(employmentId, nodeId, unitId, cell) {
        $(cell).unbind();
        $(cell).css('cursor', 'pointer');

        $(cell).click(function() {
            createEmployeeTab(nodeId, employmentId, unitId);

            openEmploymentForm(employmentId, nodeId);
        });

        if ($(cell).html().length < 1) {
            $(cell).html('Lägg till');
        }

}

function initEmployeeCell(nodeId, employmentId, cell, datatable) {
    if (nodeId != "") {
        $(cell).unbind();
        $(cell).css('cursor', 'pointer');
        $(cell).click(function() {
            createEmployeeTab(nodeId, employmentId);
            openEmployeeForm();
        })
    }
}

function initUnitCell(unitId, cell, datatable) {
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