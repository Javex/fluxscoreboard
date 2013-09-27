$(document).ready(function() {
    Admin.init();
});

var Admin = {
    init: function() {
        Admin.bindEvents();
    },

    bindEvents: function() {
        $(".confirm-delete").click(Admin.onDeleteConfirm);
        $("#team_cleanup").click(Admin.onTeamCleanup);
    },

    onDeleteConfirm: function() {
        var answer = confirm("Really delete this entry?");
        if(!answer)
            $(this).parents(".dropdown-menu:eq(0)").dropdown("toggle");
        return answer;
    },

    onTeamCleanup: function() {
        return confirm("Really delete ALL inactive teams? This cannot be undone!");
    }
};
