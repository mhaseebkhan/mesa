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
//= require turbolinks
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

  function show_last_col(show_col)
  {
	
	$("#mesa_detail").hide();
	$("#user_detail").hide();
	$("#team_assembling").hide();
	$("#mesa_col2_2").show();
	$("#mesa_col2_3").hide();
        $(show_col).show();
        show_next_step(".third_col",".fourth_col");
	
  }

  function show_prev_searched_results()
  {
	
	$("#mesa_detail").hide();
	$("#user_detail").hide();
	$("#team_assembling").hide();
	$("#mesa_col2_2").show();
	$("#mesa_col2_3").hide();
        $("#team_assembling").show();
        enable_prev_step(".fifth_col",".fourth_col");
	
	
  }

  function show_mesa_user_detail(user_id){
     var mesa_type = $('#hidden_mesa_type').val();
     var mesa_id = $('#hidden_mesa_id').val();
     var url = '/get_user';
	    $.ajax({
		url:url,
		type:'get',
		data : {user_id: user_id,mesa_type: mesa_type, mesa_id: mesa_id },
		success:function (data) {
		    {
			
				$("#user_detail").html(data).show();
				show_last_col("#user_detail");
			
		    }
		}
	    });
   }

 function show_mesa_searched_user_detail(user_id){
     event.stopPropagation();
     var mesa_type = $('#hidden_mesa_type').val();
     var mesa_id = $('#hidden_mesa_id').val();
     var url = '/get_user';
	    $.ajax({
		url:url,
		type:'get',
		data : {user_id: user_id,mesa_type: mesa_type, mesa_id: mesa_id },
		success:function (data) {
		    {
			
				$("#searched_user_detail").html(data).show();
				$("#mesa_detail").hide();
				$("#user_detail").hide();
				$("#team_assembling").hide();
				$("#mesa_col2_2").hide();
				$("#mesa_col2_3").show();
				//$("#user_detail").show();
				show_next_step(".fourth_col",".fifth_col");
			
		    }
		}
	    });
   }


function show_user_detail(user_id){
     var url = '/get_user';
	    $.ajax({
		url:url,
		type:'get',
		data : {user_id: user_id },
		success:function (data) {
		    {
			$("#user_detail").html(data).show();
			show_last_col("#user_detail");
   		    }
		}
	    });

       
   }


 function delete_user(user_id,event){
        event.stopPropagation();
        $.confirm({
            'title': 'WARNING!',
            'message': 'Are You sure you want to remove this?',
            'buttons': {
                'Yes': {
                    'class': 'blue',
                    'action': function () {
                         var url = '/users/delete_user';
			    $.ajax({
				url:url,
				type:'get',
				data : {user_id: user_id },
				success:function (data) {
				    {
					$("#user_primary_info_"+user_id).hide();
		   		    }
				}
			    });
                
                    }
                },
                'No': {
                    'class': 'gray',
                    'action': function () {
                    }    // Nothing to do in this case. You can as well omit the action property.
                }
            }
        });
    }



