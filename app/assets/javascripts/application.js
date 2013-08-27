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
//= require_tree .

$(document).ready(function() {
  setTimeout(function() {
    var source = new EventSource('/volumes/events');
    source.addEventListener('js', function(e) {
      var payload = JSON.parse(e.data);
      eval(payload['code']);
    });
  }, 1);

  $('[data-playback-stream]').on('change', function() {  
    var id = $(this).attr('data-playback-stream');
    $.ajax({url: '/volumes/playback_streams/' + id, data: {volume: $(this).val()}, type: 'PUT'});
  });
  
  $('[data-sink]').on('change', function() {  
    var id = $(this).attr('data-sink');
    $.ajax({url: '/volumes/sinks/' + id, data: {volume: $(this).val()}, type: 'PUT'});
  });
});
