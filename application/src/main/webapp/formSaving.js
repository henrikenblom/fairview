/**
 * Created by IntelliJ IDEA.
 * User: fairview
 * Date: 9/13/11
 * Time: 3:52 PM
 * To change this template use File | Settings | File Templates.
 */
function disableButtonTemporarily(elementId) {
    $(elementId).attr('disabled', true).css({ opacity: 0.5 }).delay('2000').queue(function(n) {
        $(this).removeAttr('disabled').css({ opacity: 1 });
        n();
    });
}

function showMessage(elementId) {
    $(elementId).show().fadeOut(5000);
}

function createSavedSpan() {
    var span = $('<span>');
    span.attr("style", "display: none;");
    span.attr("id", "savedSpan");
    span.attr("class", "savedSpan");
    span.append("Sparad");
    return span;
}