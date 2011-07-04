function cmxforms() {
    $('form.cmxform').each(function() {
        cmxform($(this));
    });
}

function cmxform(form) {
    form.hide();
    form.find('p>label:not(.nocmx):not(.error)').each(function() {
        var $this = $(this);
        var labelContent = $this.html();
        var labelWidth = document.defaultView.getComputedStyle(this, '').getPropertyValue('width');
        var labelSpan = $("<span>").css("display", "block").width(labelWidth).html(labelContent);
        $this.css("display", "-moz-inline-box").empty().append(labelSpan);
    });
    form.show();
}
