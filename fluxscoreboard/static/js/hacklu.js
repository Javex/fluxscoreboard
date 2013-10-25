$(document).ready(function(){
	HackLu.init();
});

/**
 * Static class containing utility functions for everything global to the
 * application.
 */
var HackLu = {

	init: function() {
		HackLu.startTimer();
		HackLu.bindEvents();
	},
	
	bindEvents: function() {
		/*$("div#content>h2").click(HackLu.slideMenu);*/
	},
	
	startTimer: function() {
		var timer = document.getElementById('timer-seconds');
		var interval = null;
		interval = setInterval(function() {
		    var s = parseInt(timer.textContent);
		    if (s) {
		        timer.textContent = parseInt(timer.textContent) - 1;
		    } else {
		        clearInterval(interval);
		    }
		}, 1000);
	},
	
	slideMenu: function() {
		$("div#head-wrap").slideToggle();
	},
};
