//= require jquery
//= require modernizr.custom
//= require core/deck.core
//= require extensions/hash/deck.hash
//= require jquery.qtip.min

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
});
