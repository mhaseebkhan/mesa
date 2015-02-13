// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require foundation
//= require turbolinks
//= require tag-it
//= require_tree .
//= bootstarp

function enable_prev_step(hide_col,show_col)
{
$(hide_col).hide();
$(hide_col).addClass('disabled_step');
$(show_col).removeClass('opacity-05');
$(show_col).removeClass('disabled_step');
}

function show_next_step(hide_col,show_col)
{
$(hide_col).addClass('opacity-05');
$(hide_col).addClass('disabled_step');
$(show_col).show();
$(show_col).removeClass('disabled_step');
}

$(window).load(function(){
    $(".scrollbar").mCustomScrollbar({
        theme:"minimal-dark"
    });
});
