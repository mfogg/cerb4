
function none() {};

$(document).ready(function(){
	var displayToolLinks = $('#toolbar #tb_display a.tb_prop_link');
	var displayToolGrayedLinks = displayToolLinks.filter('.tb_link_grayed');

	//link non disabled ticket property toolbar buttons
	displayToolLinks.filter(":not(.tb_link_grayed)").click(function(event) {updateTicket(event) });
	
	//the delete button is the only one that still works when grayed
	displayToolGrayedLinks.filter('[id!=tb_btn_delete]').removeAttr("href");
	$('#tb_btn_delete.tb_link_grayed').click(function(event) {updateTicket(event)});
	
	
	$('#toolbar #tb_reply #tb_btn_back_display').click(function(event) {	showDisplay(event); });
	
	$('#conversation div.convo_block_container').click(function(event) {
		event.preventDefault();
		doConvoBlockToggle($(this));
	});

	$('#conversation').find("ul.message_buttons li button").click(function(event) { replyButton(event)});
	
	$('div#reply_pane button#reply_me_button').click(function(event) { replyMePressed(event);});
	$('div#reply_pane button#reply_anybody_button').click(function(event) { replyAnyPressed(event);});
	$('div#reply_pane select[name=next_worker]').change(function(event) { nextWorkerChanged();});
	$('#reply_pane #send_button').click(function(event) { sendReply(); });
	$('#reply_pane #discard_reply').click(function(event) { showDisplay()});
});

function doConvoBlockToggle(container) {
	if(!container.hasClass("convo_block_container")) {
		container = container.parents("div.convo_block_container");
	}
	

	var convo_block_pane = $("div.convo_block_pane", container);
	var convo_block_content = $("div.convo_block_content", convo_block_pane);
	
	$("ul.convo_block_headers li.extra_header", container).slideToggle();
	//console.log(convo_block_content.html());
	if(convo_block_content.html().trim().length > 0) {
		convo_block_pane.slideToggle();
		container.toggleClass("convo_block_expanded");
		container.removeClass("convo_block_expanded_init");
		
	}
	else {
		var blockId = $("div.block_info span.propId", container).text();
		var isMessage = container.hasClass("message_container")
		var ajaxParams = null;

		if(isMessage) {
			ajaxParams = {c: "iphone", a: "display", a2: "retrieveMessage", msgid: blockId};
		}
		else {
			ajaxParams = {c: "iphone", a: "display", a2: "retrieveComment", commentid: blockId};
		}
		
		$.get(DevblocksAppPath + "ajax.php", 
				ajaxParams, 
				function(xml) {
					convo_block_content.html(xml).parent().slideToggle();
					container.toggleClass("convo_block_expanded");
					container.removeClass("convo_block_expanded_init");

				});
	}
	
}

function replyButton(event) {
	event.stopPropagation();
	event.preventDefault();
	
	var button = $(event.target);
	
	//sometimes the event target is the image inside the button, so get the parent button in that case
	if(button.parent().is("button")) {
		button = button.parent();
	}
	
	var messageContainer = button.parents(".message_container");
	
	var subject = $("ul.convo_block_headers li.msg_subject span.header_val", messageContainer).text();
	var content = $("div.convo_block_pane div.convo_block_content", messageContainer).text();
	
	var replyPane = $("div#reply_pane");
	var isForward = button.is(".btnForward");
	var heading="";
	var subjectPrefix = "";
	if(isForward) {
		heading="Forward";
		subjectPrefix = "Fwd: ";

		replyPane.find("table.forward_only").show();
		replyPane.find("table.reply_only").hide();		
	}
	else {
		heading="Reply";
		subjectPrefix = "Re: ";

		replyPane.find("table.forward_only").hide();
		replyPane.find("table.reply_only").show();
		replyPane.find("select[name=requesters] *").attr('selected','selected');
		content = "> " + content.replace(/[\n]/gi, "\n> ") + "\n\n";
	}
	
	subject = subjectPrefix + subject;
	
	replyPane.find("textarea[name=content]").val(content);
	replyPane.find("h1#reply_pane_title").text(heading);
	replyPane.find("input[name=subject]").val(subject);
	replyPane.find("input[name=cc]").text("");
	replyPane.find("input[name=bcc]").text("");
	
	var messageId = messageContainer.find("div.block_info .propId").text();
	replyPane.find("input[name=message_id]").val(messageId);
	
	var nextWorkerId = $("div#properties div.nextWorkerId").text();
	//console.log(nextWorkerId);
	replyPane.find("select[name=next_worker]").val(nextWorkerId);
	
	$("div#toolbar div#tb_display").hide();
	$("div#toolbar div#tb_reply").show();
	
	$("#display").fadeOut("slow", function() {
		scrollTo(0,0);
		$("#reply").fadeIn("slow");	
	});
	
}

function replyAnyPressed(event) {
	$('#reply_pane select[name=next_worker]').val("0");
	nextWorkerChanged();
}
function replyMePressed(event) {
	$('#reply_pane select[name=next_worker]').val(activeWorkerId);
	nextWorkerChanged();
}

function nextWorkerChanged() {
	var isNextWorkerUnset = (parseInt($('#reply_pane select[name=next_worker]').val()) == 0);
	if(isNextWorkerUnset) {
		$("#reply_pane table.reply_surrender").fadeOut();
	}
	else {
		$("#reply_pane table.reply_surrender").fadeIn();
	}
}

function showDisplay() {
	showDisplay(null);
}

function showDisplay(event){
	if (event != null) {
		event.stopPropagation();
		event.preventDefault();
	}
	

	$("#toolbar div#tb_reply").hide();
	$("#toolbar div#tb_display").show();
	
	$("#reply").fadeOut("slow", function() {
		scrollTo(0,0);
		$("#display").fadeIn("slow");	
	});
		
}

function bindMessageHandlers() {
	var firstBlock = $('#conversation div.convo_block_container:first-child');
	firstBlock.click(function(event) {
		event.preventDefault();
		doConvoBlockToggle($(this));
	});
	
	firstBlock.find("ul.message_buttons li button").click(function(event) { replyButton(event)});

}

function sendReply() {
	var replyPane = $("#reply_pane");
	var isForward = $("#reply_pane_title").text()=="Forward";
	var to="";
	if (isForward) {
		to = replyPane.find("input[name=to]").val();
		if(to.trim().length==0) {
			alert("You must enter a TO address to forward to");
			return;
		}
	}
	
	var ajaxParams = {
		c: "iphone",
		a: "display",
		a2: "sendReply",
		message_id: replyPane.find("input[name=message_id]").val(),
		ticket_id: replyPane.find("input[name=ticket_id]").val(),
		to: to,
		cc: replyPane.find("input[name=cc]").val(),
		bcc: replyPane.find("input[name=bcc]").val(),
		subject: replyPane.find("input[name=subject]").val(),
		content: replyPane.find("textarea[name=content]").val(),
		next_worker_id: replyPane.find("select[name=next_worker]").val(),
		closed: replyPane.find("input[name=status]:checked").val(),
		bucket_id: "",
		ticket_reopen: replyPane.find("input[name=ticket_reopen]").val(),
		unlock_date: replyPane.find("input[name=unlock_date]").val(),
	}
	
	$.post(DevblocksAppPath + "ajax.php", 
			ajaxParams, 
			function(xml) {
				$("#display #conversation").prepend(xml).find("div.convo_block_container:first-child").fadeIn("slow" ,function() {
					doConvoBlockToggle($(this));
					bindMessageHandlers();
				});
			}, "html");
			
	showDisplay();

}

function updateTicket(event) {
	var img = $(event.target);
	var link = img.parent();
	//alert(event.target);

	var linkId = link.attr("id");
	
	var ticketId = $("#properties div.ticketIdDval").text();

	var ajaxParams = {
			c: "iphone",
			a: "display",
			a2: "updateProperties",
			id: ticketId};

	var imgPath = DevblocksAppPath+"resource/cerberusweb.iphone/images/24x24/";

	switch(linkId) {
		case "tb_btn_reopen":
			ajaxParams['closed'] = "0";
			//change closed to folder_ok
			img.attr("src", imgPath+"folder_ok.png");
			link.attr("id", "tb_btn_close");
			$("#properties #dispropStatus").text("Open");
		break;
		case "tb_btn_close":
			ajaxParams['closed'] = "1";
			//change closed to folder_out
			img.attr("src", imgPath+"folder_out.png");
			link.attr("id", "tb_btn_reopen");
			$("#properties #dispropStatus").text("Closed");
		break;		
		case "tb_btn_spam":
			ajaxParams['spam'] = "1";
			//add tb_link_grayed
			doDeletedToolbarState();
		break;
		case "tb_btn_delete":
			if(link.hasClass("tb_link_grayed")) {
				ajaxParams['deleted'] = "0";
				//remove spam tb_link_grayed
				//change closed to folder_ok & remove tb_link_grayed
				//remove delete tb_link_grayed
				var spamLink = $("#tb_btn_spam");
				spamLink.removeClass("tb_link_grayed");
				spamLink.attr("href", "javascript:none();");
				spamLink.click(function(event) { updateTicket(event)});
				
				var closedLink = $("#tb_btn_close");
				if (closedLink.attr('id') == null) {
					closedLink = $("#tb_btn_reopen");
					closedLink.children("img").attr('src', imgPath+"folder_ok.png");
					closedLink.attr("id", 'tb_btn_close');
				}
				closedLink.attr('href', 'javascript:none();');
				closedLink.removeClass('tb_link_grayed');
				closedLink.click(function(event) {updateTicket(event)});
				$("#properties #dispropStatus").text("Open");

				link.removeClass("tb_link_grayed");
			}
			else {
				ajaxParams['deleted'] = "1";
				//add spam tb_link_grayed
				//add closed tb_link_grayed
				//add delete tb_link_grayed
				doDeletedToolbarState();
			}
		break;
		case "tb_btn_release":
			ajaxParams['next_worker_id'] = "0";
			//change image to hand
			img.attr('src', imgPath + "hand_paper.png");
			link.attr('id', 'tb_btn_take');
		break;
		case "tb_btn_take":
			ajaxParams['next_worker_id'] = activeWorkerId;
			//change image to flag
			img.attr('src', imgPath + "flag_yellow.png");
			link.attr('id', 'tb_btn_release');
		break;
		
	}
	
	$.post(DevblocksAppPath + "ajax.php", 
			ajaxParams, 
			function(xml) {}, "html");
	
	
}

function doDeletedToolbarState() {
	var spamLink = $("#tb_btn_spam");
	spamLink.addClass('tb_link_grayed');
	spamLink.removeAttr('href');
	spamLink.unbind('click');
	
	var closedLink = $("#tb_btn_close");
	if(closedLink.attr('id')==null) {
		closedLink = $("#tb_btn_reopen");
	}
	closedLink.removeAttr("href");
	closedLink.addClass("tb_link_grayed");
	closedLink.unbind('click');
	
	var deletedLink = $("#tb_btn_delete");
	deletedLink.addClass('tb_link_grayed');	
	
	$("#properties #dispropStatus").text("Deleted");
}


