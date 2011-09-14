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

function closePopup() {
    $('#popup-dialog').hide(0);
    $('#modalizer').fadeOut(500);
}

function setupModalizerClickEvents(reloadPage) {
    $('#modalizer').click(function() {
        closePopup();
        if (reloadPage == 'true')
            location.reload();
    });
}

function bindTabs() {
    $("#popup-tabs").tabs();
}

function tabLinks(links) {
    var tabList = $('<ul>');
    $.each(links, function(i) {
        var tabListItem = $('<li>');
        var tabLink = $('<a>');
        tabLink.attr('href', '#' + links[i][0]);
        tabLink.html(links[i][1]);
        tabListItem.append(tabLink);
        tabList.append(tabListItem);
    })
    return tabList;
}
function tabBody(id) {
    var tabBody = $('<div>');
    tabBody.attr('id', id);
    return tabBody;
}
function generateTabs(aLinkData) {
    var container = $('<div>');
    container.attr('id', 'popup-tabs');
    container.addClass('unitsettings');
    var linksDiv = tabLinks(aLinkData);
    container.append(linksDiv);

    $.each(aLinkData, function(i) {
        container.append(tabBody(aLinkData[i][0]));
    });

    return container;
}