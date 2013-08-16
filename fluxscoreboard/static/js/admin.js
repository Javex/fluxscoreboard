$(document).ready(function() {
    Admin.init();
});

var Admin = {
    init: function() {
        Admin.bindEvents();
    },

    bindEvents: function() {
        $(".confirm-delete").click(Admin.onDeleteConfirm);
    },

    onDeleteConfirm: function() {
        var answer = confirm("Really delete this entry?");
        if(!answer)
            $(this).parents(".dropdown-menu:eq(0)").dropdown("toggle");
        return answer;
    },
};
