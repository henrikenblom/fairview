/**
 * Created by IntelliJ IDEA.
 * User: fairview
 * Date: 8/24/11
 * Time: 9:18 AM
 * To change this template use File | Settings | File Templates.
 */
function openPopupTab(tabnumber) {
    $('#popup-dialog').show(0, function() {
        $("#popup-tabs").tabs('select', tabnumber);
    });
    $('#modalizer').fadeTo(400, 0.8);
}

function fadeOutModalizer() {
    $('#modalizer').fadeOut(500);
}

function setupModalizerClickEvents(reloadPage) {
    $('#modalizer').click(function() {
        $('#popup-dialog').hide(0);
        $('#modalizer').fadeOut(500);
        if (reloadPage == 'true')
            location.reload();
    });
}

function createTabs() {
    $("#popup-tabs").tabs();
}