// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require bootstrap
//= require bootstrap-datepicker

jQuery(function($) {

    $('div.btn-group[data-toggle-name], span.btn-group[data-toggle-name]').each(function(){
        var group   = $(this);
        var form    = group.parents('form').eq(0);
        var name    = group.attr('data-toggle-name');
        var hidden  = $('input[name="' + name + '"]', form);
        $('button', group).each(function(){
            var button = $(this);
            button.on('click', function(){
                hidden.val($(this).val());
            });
            if(button.val() == hidden.val()) {
                button.addClass('active');
            }
        });
    });

    $(".item-form #item_date").datepicker({});

    $(".new-face-form #item_date").datepicker({
      beforeShowDay: function(date) {
        var nowTemp = new Date();
        var now = new Date(nowTemp.getFullYear(), nowTemp.getMonth(), nowTemp.getDate(), 0, 0, 0, 0);
        return date.valueOf() < now.valueOf() ? {enabled: false} : {};
      }
    });

  $('a[data-toggle]').click(function() {
    var collapsed = $(this).data('data-target');

    $(collapsed).css('height', '100%');
  });

});

var unlockNavbarIfNecessary = function() {
    var iphone6PlusLandscapeWidth = 736;
    var bottomNavbar = $('div.bottom');
    if ($(window).width() > iphone6PlusLandscapeWidth) {
        bottomNavbar.addClass('navbar-fixed-bottom');
    } else {
        bottomNavbar.removeClass('navbar-fixed-bottom')
    }
};

$(document).ready(function () {
    unlockNavbarIfNecessary();
    $(window).resize(function () {
        unlockNavbarIfNecessary();
    });
});
