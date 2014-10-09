$(document).ready(function(){
    HackLu.init();
});

/**
 * Static class containing utility functions for everything global to the
 * application.
 */
var HackLu = {

    init: function() {
        HackLu.bindEvents();
    },

    bindEvents: function() {
        $("#delete-avatar").click(HackLu.confirmAvatarDelete);
    },

    confirmAvatarDelete: function() {
        return confirm("Are you sure you want to delete your avatar?");
    },
};
