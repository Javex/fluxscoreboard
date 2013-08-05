$(document).ready(function(){
	HackLu.init();
});

/**
 * Static class containing utility functions for everything global to the
 * application.
 */
var HackLu = {

	init: function() {
		this.make_select2();
	},
	
	make_select2: function() {
		// select item with class "select2" turns into select to list
		$("select.select2").removeClass('form-control').select2();
	},
};