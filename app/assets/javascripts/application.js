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
//= require jquery.qtip.min
//= require bootstrap-datepicker
//= require_tree .

jQuery(function($) {
    $('.has-qtip').qtip({
        position: {
            viewport: $(window),
            my: 'top middle',
            at: 'bottom middle'
        },
        style: {
            classes: 'ui-tooltip-bootstrap'
        },
        events: {
            render: function(event, api) {
                api.elements.target.click(api.toggle);
                api.elements.tooltip.click(api.hide);
            }
        }
    });


    $('div.btn-group[data-toggle-name=*], span.btn-group[data-toggle-name=*]').each(function(){
        var group   = $(this);
        var form    = group.parents('form').eq(0);
        var name    = group.attr('data-toggle-name');
        var hidden  = $('input[name="' + name + '"]', form);
        $('button', group).each(function(){
            var button = $(this);
            button.live('click', function(){
                hidden.val($(this).val());
            });
            if(button.val() == hidden.val()) {
                button.addClass('active');
            }
        });
    });

    $("#item_date").datepicker({
      show: new Date()
    });
});
