function popwin(obj) {
    var w = window.open(obj.href, 'assign', 'height=400,width=400,toolbar=no,scrollbars=yes,resizable=yes');
    w.focus();
    return false;
}

function update_tr (domid, link, cols) {
    var row = $('#'+domid);
    row.html("<td colspan=\"" + cols + "\">Saving...</td>");
    $.get(link, {}, function(data) {
      row.html(data);
    });
    return false;
}

