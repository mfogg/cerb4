
$(document).ready(function(){
		
	$('.message_container').click(function(event) {
		event.preventDefault();
		
		var container = $(this);
		var msgId = $("div.message_info span.propMid", $(this)).text();

		var message_pane = $("div.message_pane div.message_content", container);

		$("ul.message_headers li.extra_header", $(this)).slideToggle();
		
		if(message_pane.html().trim().length > 0) {
			message_pane.parent().slideToggle();
		}
		else {
			var ajaxPath = DevblocksAppPath + "ajax.php";
			$.get(ajaxPath, 
					{c: "iphone", a: "home", a2: "showWorklists", worklist: msgId}, 
					function(xml) {
						message_pane.html(xml).parent().slideToggle();
					});
		}
	});

	var workspaceName = $('div#tb select').val();
	workspaceChanged(workspaceName);
		
});

function workspaceChanged(workspaceName) {
	var ajaxPath = DevblocksAppPath + "ajax.php";
	$.get(ajaxPath, 
			{c: "iphone", a: "home", a2: "showWorklists", workspace: workspaceName}, 
			function(xml) {
				var worklistsDiv = $("div#worklists");
				worklistsDiv.html(xml).show();
				worklistsDiv.find("div.worklist_header").click(function(event) {
					event.preventDefault();
					event.stopPropagation();
					clickView($(this));
				});
			});
}

function clickView(headerDiv) {
	var headerText = headerDiv.text();
	var containerDiv = headerDiv.parent();
	
	var viewId = $("div.dval_viewid", containerDiv).text();
	
	var contentDiv = $("div.worklist_content", headerDiv.parent());
	
	var ajaxPath = DevblocksAppPath + "ajax.php";
	$.get(ajaxPath, 
			{c: "iphone", a: "home", a2: "showView", view_id: viewId}, 
			function(xml) {
				contentDiv.html(xml).slideToggle();
			}
	);
}
