
var currentContent = "convo_tab";

function none() {};

$(document).ready(function(){
	//workspace init
	var workspaceName = $('#tb_workspaces select').val();
	workspaceChanged(workspaceName);
	
	console.log($('#top_nav .top_tabs_display li a'));
	$('#top_nav .top_tabs_display li a').click(function(event) {tabClick(event.target)});
	
	$('#toolbar #tb_reply #tb_btn_back_display').click(function(event) { 	tabChangeSubscreen('Conv', 'convo_tab', true); });
	$('#toolbar #tb_display #tb_btn_back_display2').click(function(event) {	showHome(event); });	
	$('#toolbar #tb_display_right').click(function() {tabChangeSubscreen('Conv', 'reply_pane', true);});

	initTabState();
	initPropertiesTab();
	initReplyPane();
});


function initTabState() {
	var tabMap = [];
	tabMap['Conv'] = {key: "Conv",current_sub:"convo_tab",subscreens: {convo_tab: {tb: "tb_display,tb_display_right"}, reply_pane: {tb: "tb_reply"}}, callback: function(screen) {$('#tb_display_right').toggle($("#reply_pane input[name=message_id]").val()!='' && screen=='convo_tab')	}};
	tabMap['Props'] = {key: "Props",current_sub:"properties_container",subscreens: {properties_container: {tb: null}}, callback: function(screen) {initPropertiesTabForTicket();}};
	
	cerb4.displayTab = "Conv";
	cerb4.tabMap = tabMap;	
}

function tabClick(tabLink) {
	tabClick(tabLink, null);
}

function tabClick(tabLink, contentDivName) {console.log(tabLink+'-'+contentDivName);
	var tabMap = cerb4.tabMap;
	var tabObj = $(tabLink).parent();
	var tabName = $(tabLink).text();
	
	//update tabs
	$("#top_nav .top_tabs_display li.top_tabs_selected").removeClass('top_tabs_selected');
	tabObj.addClass('top_tabs_selected');
	
	
	tabChangeSubscreen(tabName, null);
	cerb4.displayTab = tabName;
}

function tabChangeSubscreen(tabName, subscreen) {tabChangeSubscreen(tabName, subscreen, false)};
function tabChangeSubscreen(tabName, subscreen, fade) {
	var tabMap = cerb4.tabMap;
	var oldTabName = cerb4.displayTab;
	
	//if no subscreen specified, use the last accessed as default
	if(subscreen == null) {
		subscreen = tabMap[tabName].current_sub;
	}
	
	var toolbars = [];
	var toolbarsStr = tabMap[tabName].subscreens[subscreen].tb;
	if(toolbarsStr != null) {
		toolbars = toolbarsStr.split(',');
	}
	var oldSubscreen = tabMap[oldTabName].current_sub;
	
	//hide the toolbars from before
	var oldToolbars = [];
	var oldToolbarsStr = tabMap[oldTabName].subscreens[oldSubscreen].tb;
	if (oldToolbarsStr != null) {
		oldToolbars = oldToolbarsStr.split(',');
		for (var a in oldToolbars) {
			$("#" + oldToolbars[a]).hide();
		}
	}
	//this might be better for hiding than the loop above:
	//$("#toolbar div").hide();

	//show the new current toolbars
	for(var a in toolbars) {
		$("#"+toolbars[a]).show();
	}

	//each tab is allowed to specify a callback function.  call it here
	console.log(tabMap[tabName].callback);
	if (tabMap[tabName].callback != null) {
		tabMap[tabName].callback(subscreen);
	}

//	//update content
	if (fade) {
		$("#" + oldSubscreen).fadeOut("slow", function(){
			scrollTo(0, 0);
			$("#" + subscreen).fadeIn("slow");
		});
	}
	else {
		$("#"+oldSubscreen).hide();
		$("#"+subscreen).show();
	}
	//set the map to point to the new current subscreen
	tabMap[tabName].current_sub = subscreen;

}

function doConvoBlockToggle(container) {
	if(!container.hasClass("convo_block_container")) {
		container = container.parents("div.convo_block_container");
	}

	var convo_block_pane = $("div.convo_block_pane", container);
	var convo_block_content = $("div.convo_block_content", convo_block_pane);
	
	$("ul.convo_block_headers li.extra_header", container).slideToggle();
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
			ajaxParams = {c: "mobile", a: "display", a2: "retrieveMessage", msgid: blockId};
		}
		else {
			//ajaxParams = {c: "mobile", a: "display", a2: "retrieveComment", commentid: blockId};
			//comments now always get their content when the conversation is loaded...no need to ajax
			return;
		}
		
		$.get(DevblocksAppPath + "ajax.php", 
				ajaxParams, 
				function(xml) {
					if (isMessage) {
						cerb4.ticket.messages[blockId].content = xml;
					}
					else {
						cerb4.ticket.comments[blockId].content = xml;
					}
					convo_block_content.html(xml).parent().slideToggle();
					container.toggleClass("convo_block_expanded");
					container.removeClass("convo_block_expanded_init");

				}, 'text');
	}
	
}

function replyButton(event) {
	event.stopPropagation();
	event.preventDefault();
	
	var c4 = cerb4;
	var ticket = c4.ticket;
	var workers = c4.workers;

	var button = $(event.target);
	
	//sometimes the event target is the image inside the button, so get the parent button in that case
	if(button.parent().is("button")) {
		button = button.parent();
	}
	
	var messageContainer = button.parents(".message_container");
	
	var messageId = messageContainer.find("div.block_info .propId").text();

	var content = $("div.convo_block_pane div.convo_block_content", messageContainer).text();
	//probably should get content the way below, but the above makes use of smarty conveniences modifiers
	//var content = c4.ticket.messages[messageId].content;

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
		//subjectPrefix = "Re: ";

		replyPane.find("table.forward_only").hide();
		replyPane.find("table.reply_only").show();

		var requesters = ticket.requesters;
		var requesterStr = '';
		var firstTime = true;
		for(var a in requesters) {
			if (!firstTime) {
				requesterStr += ', ';
			}
			else firstTime = false;
			requesterStr += requesters[a].email ;
		}
		replyPane.find('#requesters').text(requesterStr);
		
		//TODO put the 'ON <date>,<email> wrote:' here
		content = "> " + content.replace(/[\n]/gi, "\n> ") + "\n\n";
	}
	
	//set subject
	subject = subjectPrefix + ticket.subject;

	//set status
	var statusInput = replyPane.find("input[name=status]");
	var statusVal = getTicketStatusValue();
	
	statusInput.filter('[value='+statusVal+']').attr('checked','checked');

	//show/hide the 'resume' div based on status
	if (ticket.due_date > 0) {
		replyPane.find("input[name=ticket_reopen]").val(c4Date(ticket.due_date));
	}
	propertiesToggleResumeDiv('reply');

	//set next worker
	var workerSelect = replyPane.find('select[name=next_worker]');
	workerSelect.val(ticket.next_worker_id);

	if (ticket.unlock_date != 0) {
		replyPane.find("input[name=unlock_date]").val(c4Date(ticket.unlock_date));
	}
	//show/hide 'release after x' div based on next worker
	propertiesNextWorkerChanged('properties');

	//set reply related fields
	replyPane.find("textarea[name=content]").val(content);
	replyPane.find("h1#reply_pane_title").text(heading);
	replyPane.find("input[name=subject]").val(subject);
	replyPane.find("input[name=cc]").text("");
	replyPane.find("input[name=bcc]").text("");
	replyPane.find("input[name=message_id]").val(messageId);
	
	
	tabChangeSubscreen('Conv', 'reply_pane', true);
	
}

function createWorkerOptions(selectControl) {
	var c4 = cerb4;
	var workers = c4.workers;
	var workerOptionStr = '<option value="0">Anybody</option>';
	var initVal='';
	var selectedFlag='';
	for(var a in workers) {
		if (c4.ticket != null) {
			selectedFlag = (workers[a].id == c4.ticket.next_worker_id) ? ' selected' : '';
			initVal = c4.ticket.next_worker_id;
		}
		workerOptionStr += '<option value="'+ a + '"' + selectedFlag +'>'+workers[a].first_name + ' ' + workers[a].last_name + '</option>';
	}
	selectControl.html(workerOptionStr).val(initVal);
}

function createBucketOptions(selectControl) {
	var c4 = cerb4;
	var categories = c4.categories;
	var groups = c4.groups;
	var optionStr = '<option value="">-- move to --</option>';
	optionStr += '<optgroup label="Inboxes">';
	for(var a in groups) {
		optionStr += '<option value="t'+ a + '">'+groups[a].name + '</option>';
	}
	optionStr += '</optgroup>';
	
	for (var a in categories) {
		optionStr += '<optgroup label="-- ' + groups[a].name + ' --">';
		for (var b in categories[a]) {
			optionStr += '<option value="c'+ b + '">'+categories[a][b].name + '</option>';
		}
		optionStr += '</optgroup>';
	}
	selectControl.html(optionStr);
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
	
	var subject = replyPane.find("input[name=subject]").val();
	var nextWorkerId = replyPane.find("select[name=next_worker]").val();
	var closed = replyPane.find("input[name=status]:checked").val();
	
	var ajaxParams = {
		c: "mobile",
		a: "display",
		a2: "sendReply",
		message_id: replyPane.find("input[name=message_id]").val(),
		ticket_id: replyPane.find("input[name=ticket_id]").val(),
		to: to,
		cc: replyPane.find("input[name=cc]").val(),
		bcc: replyPane.find("input[name=bcc]").val(),
		subject: subject,
		content: replyPane.find("textarea[name=content]").val(),
		next_worker_id: nextWorkerId,
		closed: closed,
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
					
					var ticket = cerb4.ticket;

					//after the reply is sent, update the local ticket object properties
					//to reflect the changes.
					if(subject != ticket.subject) {
						$("#display_top > h1").text(subject);
						ticket.subject = subject;
					}
					ticket.nextWorkerId = nextWorkerId;
					
					ticket.is_closed = (closed==1);
					ticket.is_waiting = (closed==2);
					ticket.is_deleted = (closed==3);

					//unlock and reopen dates are embedded hidden in the message since we needed to get phps strtotime on them
					var blockInfo = $(this).find('div.block_info');
					ticket.unlock_date = blockInfo.find('.propUnlock').text();
					ticket.reopen_date = blockInfo.find('.propReopen').text();
					
					if(ticket.unlock_date == '') ticket.unlock_date = 0;
					if(ticket.reopen_date == '') ticket.reopen_date = 0;
					
					//update the visuals (ticket action buttons etc)
					updateTicketActionStates();
				});
			}, "html");

	//clear the id so the screen change function will know to hide the upper right reply link
	replyPane.find("input[name=message_id]").val("");
	tabChangeSubscreen('Conv', 'convo_tab', true);
}

/*
 * Make the actual ajax call for when a user clicks one of the ticket 'actions'
 * from the toolbar of the conversation screen
 */
function performTicketAction(event) {
	var ticket = cerb4.ticket;
	var linkId = $(event.target).parent().attr('id');

	var ajaxParams = {
			c: "mobile",
			a: "display",
			a2: "updateProperties",
			id: ticket.id};
	
	switch(linkId) {
		case "tb_btn_close":
			ticket.is_closed = (ticket.is_closed) ? 0 : 1;
			ajaxParams['closed'] = ticket.is_closed;			
		break;
		case "tb_btn_spam":
			ticket.spam_training = 'Y';
			ajaxParams['spam'] = "1";
		break;
		case "tb_btn_delete":
			ticket.is_deleted = (ticket.is_deleted) ? 0 : 1;
			ajaxParams['deleted'] = ticket.is_deleted;
		break;
		case "tb_btn_take":
			ticket.next_worker_id = (ticket.next_worker_id == activeWorkerId) ? 0 : activeWorkerId;
			ajaxParams['next_worker_id'] = ticket.next_worker_id;
		break;
				
	}
	
	$.post(DevblocksAppPath + "ajax.php", 
			ajaxParams, 
			function(xml) {}, "html");
	
	//update the visuals
	updateTicketActionStates();
}

/*
 * Updates the ticket actions toolbar to corectly reflect their state
 * e.g. fade out buttons that should be 'disabled',
 * swap button images,
 * add/remove click handlers as appropriate
 */
function updateTicketActionStates() {
	$("#tb_display a").each(function() {
		var link = $(this);
		var img = link.children("img");
		var linkId = link.attr("id");
		var imgPath = DevblocksAppPath+"resource/cerberusweb.mobile/images/24x24/";

		
		var ticket = cerb4.ticket;

		var imgName;
		
		switch(linkId) {
		case "tb_btn_close":
			link.unbind('click');
			if(ticket.is_deleted) {
				link.removeAttr("href");
			}
			else {
				link.attr('href','javascript:void(0);');
				link.click(function(event) {performTicketAction(event);})
			}
			link.toggleClass('tb_link_grayed', ticket.is_deleted==1);
			var imgName = ticket.is_closed ? 'folder_out.png' : 'folder_ok.png' ;
			img.attr('src', imgPath+imgName);
			
			var statusDesc = ticket.is_closed ? 'Closed' : 'Open';
			$("#properties #dispropStatus").text(statusDesc);
			
		break;
		case "tb_btn_spam":
			link.unbind('click');
			if(ticket.is_deleted || ticket.spam_training != '') {
				link.addClass('tb_link_grayed');
				link.removeAttr('href');
			}
			else {
				link.removeClass('tb_link_grayed');
				link.attr('href','javascript:void(0);');
				link.click(function(event) {performTicketAction(event);})
			}
		break;
		case "tb_btn_delete":
			link.unbind('click');
			link.click(function(event) {performTicketAction(event);})
			link.toggleClass('tb_link_grayed', ticket.is_deleted==1);
		break;
		case "tb_btn_take":
			link.unbind('click');
			if(ticket.next_worker_id != 0 && ticket.next_worker_id != activeWorkerId) {
				link.removeAttr("href");
				link.addClass('tb_link_grayed');
			}
			else {
				link.attr('href','javascript:void(0);');
				link.click(function(event) {performTicketAction(event);})
				link.removeClass('tb_link_grayed');
			}
			imgName = (ticket.next_worker_id == activeWorkerId) ? 'flag_yellow.png' : 'hand_paper.png' ;
			img.attr('src', imgPath+imgName);			
		break;
					
		}

	});
	
	//update the properties box at the top of the conversation screen
	setTicketPropertiesBox();

}

function propertiesAnyPressed(type) {
	var container = getPropertiesContainer(type);
	workerSelect = $(container + ' select[name=next_worker]');
	workerSelect.val("0");
	propertiesNextWorkerChanged();
}
function propertiesMePressed(type) {
	var container = getPropertiesContainer(type);
	workerSelect = $(container + ' select[name=next_worker]');
	workerSelect.val(activeWorkerId);
	propertiesNextWorkerChanged();
}

function propertiesNextWorkerChanged(type) {
	var container = getPropertiesContainer(type);
	var isNextWorkerUnset = (parseInt($(container+' select[name=next_worker]').val()) == 0);
	if(isNextWorkerUnset) {
		$(container + " div.properties_surrender").fadeOut();
	}
	else {
		$(container + " div.properties_surrender").fadeIn();
	}
}

function propertiesToggleResumeDiv(type) {
	var containerName = getPropertiesContainer(type);
	var container = $(containerName);
	var resumeDiv = container.find(".properties_resume");
	var statusVal = container.find("input[name=status]:checked").val();
	
	if(container.css("display") == "block") {
		var opacity = (statusVal==1 || statusVal == 2) ? "show" : "hide";
		resumeDiv.animate({opacity: opacity});
	}
	else {
		//this case is used when this function is called in initialization (since the container starts hidden)
		resumeDiv.toggle(statusVal==1 || statusVal==2);
	}
	
}

function getPropertiesContainer(type) {
	var container;
	if(type=='reply') {
		container = '#reply_pane';
	}
	else {
		container = '#properties_container';
	}
	return container;
}

function propertiesSave() {
	var ticket = cerb4.ticket;
	
	var ticketId = ticket.id;
	
	var propertiesContainer = $("#properties_container");
	
	var statusVal = propertiesContainer.find("input[name=status]:checked").val();
	var nextWorkerId = propertiesContainer.find("select[name=next_worker]").val();
	var subject = propertiesContainer.find("input[name=subject]").val();
	var ticketReopen = propertiesContainer.find("input[name=ticket_reopen]").val();
	var unlockDate = propertiesContainer.find("input[name=unlock_date]").val();
	var spamTraining = propertiesContainer.find("input[name=spam_training]:checked").val();
	var bucketId = propertiesContainer.find("select[name=bucket_id]").val();
	var customFieldIds = propertiesContainer.find("input[name=custom_field_id_str]").val();
	
	
	var ajaxParams = {
		c: "mobile",
		a: "display",
		a2: "saveProperties",
		ticket_id: ticketId,
		next_worker_id: nextWorkerId,
		ticket_reopen: ticketReopen,
		unlock_date: unlockDate,
		subject: subject,
		closed: statusVal,
		spam_training: spamTraining,
		bucket_id: bucketId,
		custom_field_id_str: customFieldIds
	};
	
	//TODO readd custom fields save code 
	/*	
	var customFields = customFieldIds.split(",");
	for(var a in customFields) {
		var postKey = "field_"+customFields[a];
		var fieldObj = propertiesContainer.find("[name="+postKey+"]");
		
		var tag = fieldObj.get(0).tagName;
		switch(tag) {
			case "INPUT":
				switch(fieldObj.attr("type")) {
					case "text":
						ajaxParams[postKey] = fieldObj.val();
					break;
					case "radio":
						ajaxParams[postKey] = fieldObj.find(":checked").val();
					break;
					case "checkbox":
						if(fieldObj.length == 1) {
							//single checkbox
							ajaxParams[postKey] = fieldObj.filter(":checked").val();
						} 
						else {
							//multi-checkbox
							var multiVals = [];
							fieldObj.filter(":checked").each(function() {
								multiVals.push($(this).val());
							});
							//console.log("multiVals="+multiVals);
							ajaxParams[postKey] = multiVals.join("|||");
						}
					break;
				}
			break;
			
			case "SELECT":
				var arraySuffix = "";
				if(fieldObj.attr("multiple")) {
					arraySuffix = '[]';
				}
				ajaxParams[postKey+arraySuffix] = fieldObj.val();
			break;			
			case "textarea":
				ajaxParams[postKey] = fieldObj.val();
			break;
		}
		
	}
	*/

	$.post(DevblocksAppPath + "ajax.php", 
			ajaxParams, 
			function(json) {
				var obj = eval(json);
				//most values are updated without waiting for the server's response,
				//however these two dates need strtotime results only php can provide, 
				//so update fields and local model with values from server
				ticket.due_date = obj.time_reopen;
				propertiesContainer.find("input[name=ticket_reopen]").val(c4Date(obj.time_reopen));

				ticket.unlock_date = obj.time_unlock;
				propertiesContainer.find("input[name=unlock_date]").val(c4Date(obj.time_unlock));

			}, "json");


	ticket.next_worker_id = nextWorkerId;
	//ticket.due_date = ticketReopen;
	//ticket.unlock_date = unlockDate;
	ticket.subject = subject;
	ticket.is_closed = (statusVal==1);
	ticket.is_waiting = (statusVal==2);
	ticket.is_deleted = (statusVal==3);
	ticket.spam_training = spamTraining;
	
	var teamOrCat = bucketId.substring(0,1);
	var teamOrCatId = bucketId.substring(1);
	if(teamOrCat == 'c') {
		ticket.category_id = teamOrCatId;
	}
	else {//teamOrCat == 't'
		ticket.team_id = teamOrCatId;		
	}

	updateTicketActionStates();//implicitely updates ticket property box too	

}


/* Home functions */



function workspaceChanged(workspaceName) {
	var ajaxPath = DevblocksAppPath + "ajax.php";
	$.get(ajaxPath, 
			{c: "mobile", a: "display", a2: "showWorklists", workspace: workspaceName}, 
			function(xml) {
				var worklistsDiv = $("div#worklists");
				worklistsDiv.html(xml).show();
				
				//Add click handlers to worklist titles (so they can expand)
				worklistsDiv.find("div.worklist_header").click(function(event) {
					event.preventDefault();
					event.stopPropagation();
					clickView($(this));
				});
				
				//Add click handlers to view nav paging buttons
				worklistsDiv.find("div.view_paging div.view_paging_links").children().each(function() {
					
					$(this).click(function(event) {
						event.preventDefault();
						event.stopPropagation();
						
						var containerDiv = $(this).parent().parent().parent();
						var page = $(this).data("page");
						loadView(containerDiv, page, true);
						//clickPageLink($(this));
					});
					
				});
			});
}

function clickView(headerDiv) {
	var headerText = headerDiv.text();
	var containerDiv = headerDiv.parent();
	
	var viewId = $("div.dval_viewid", containerDiv).text();
	
	var contentDiv = $("div.worklist_content", containerDiv);

	//no need to make ajax request if we're just collapsing the div	
	if (contentDiv.css("display") != "none") {
		contentDiv.slideToggle();
		
		var viewPagingDiv = $("div.view_paging", containerDiv);
		viewPagingDiv.hide();
	}
	else {
		loadView(containerDiv, 0, false);
	}	
}

function loadView(containerDiv, page, isPaging) {
	var headerDiv = containerDiv.children("div.worklist_header");
	var headerText = headerDiv.text();
	var viewId = $("div.dval_viewid", containerDiv).text();
	var contentDiv = $("div.worklist_content", containerDiv);
	
	var ajaxPath = DevblocksAppPath + "ajax.php";
	$.get(ajaxPath, 
			{c: "mobile", a: "display", a2: "showView", view_id: viewId, page: page}, 
			function(xml) {
				contentDiv.fadeOut("normal", function() {
					if (isPaging) {
						contentDiv.html(xml).fadeIn();
					}
					else {
						contentDiv.html(xml).slideToggle();
					}

					containerDiv.find('ul.view_list li.view_list_item').click(function(event) { 
						var li = $(event.target);
						while(li[0].tagName != 'LI') {
							li = li.parent();
						}
						
//						Could find the window scrolltop before this ajax stuff, then set data() and scroll back to it with back button						
//						li.addClass('ticket_view_selection');
//						//console.log(li.scrollTop());
						
						var ticketId = parseInt(li.find('div.dval_ticket_id').text());
						//console.log("ticketId="+ticketId);
						loadDisplay(ticketId); 
					});


					var viewPagingDiv = $("div.view_paging", containerDiv);
					updatePagingLinks(viewPagingDiv);
					if(!isPaging) viewPagingDiv.show(); //on initial view reveal we have to toggle paging buttons display

				});
			}
	);
}


function updatePagingLinks(viewPagingDiv) {
	var viewPagingLinks = viewPagingDiv.find("div.view_paging_links");
	
	
	var viewPagingObjStr = viewPagingLinks.parent().parent().find(".worklist_content_container div.dval_view_paging").text();
	var viewPagingObj =  eval("("+viewPagingObjStr+")");


	var linkFirst = viewPagingLinks.find(".view_page_link_first").parent();
	var linkPrev = viewPagingLinks.find(".view_page_link_prev").parent();
	var linkNext = viewPagingLinks.find(".view_page_link_next").parent();
	var linkLast = viewPagingLinks.find(".view_page_link_last").parent();
	
	var previousVisibility = (parseInt(viewPagingObj.currentPage) > 0) ? "visible" : "hidden";
	var nextVisibility =  ( parseInt(viewPagingObj.toRow) < parseInt(viewPagingObj.total)) ? "visible" : "hidden";
	
	//show or hide the next/prev view links
	linkPrev.css("visibility", previousVisibility);
	linkFirst.css("visibility", previousVisibility);
	
	linkNext.css("visibility", nextVisibility);
	linkLast.css("visibility", nextVisibility);		
	
	//set the page number that will be used when clicked to know what page to fetch for the view
	linkFirst.data("page", 0);
	linkPrev.data("page", viewPagingObj.prevPage);
	linkNext.data("page", viewPagingObj.nextPage);
	linkLast.data("page", viewPagingObj.lastPage);
	
	viewPagingDiv.children("div.view_paging_text").text(viewPagingObj.pageDesc);
}

//////////////////////

function loadDisplay(ticketId) {

		
	var ajaxPath = DevblocksAppPath + "ajax.php";
	$.get(ajaxPath, 
			{c: "mobile", a: "display", a2: "showDisplay", ticket_id: ticketId}, 
			function(json) {
				//get back json
				var dispObj = eval(json);
				
				//show the display tabs
				$("#top_nav .top_tabs_home").hide();
				$("#top_nav .top_tabs_display").show();

				$("#tb_workspaces").hide();
				$("#tb_display").show();
				
				//set ticket properties box
				var ticket = dispObj.ticket;
				cerb4.ticket = ticket; //set within our global variable
				updateTicketActionStates();//implicitely updates ticket property box too
				
				//set the subject title
				$('#display_top > h1').text(ticket.subject);

				//add conversation
				renderConversation(ticket);

				//init reply pane
				//$("#reply_pane[name=ticket_id]").val(ticketId);
				
				window.scrollTo(0, 1);
				
				$("#worklists").hide();
				$("#display").show();
				
			}, "json"
	);		
}

function initReplyPane() {
	var replyPane = $('#reply_pane');
	replyPane.find('button[name=me_button]').click(function(event) { replyMePressed(event);});
	replyPane.find('button[name=anybody_button]').click(function(event) { replyAnyPressed(event);});
	replyPane.find('input[name=status]').change(function(event) { propertiesToggleResumeDiv('reply')});

	var workerSelect = replyPane.find('select[name=next_worker]');
	createWorkerOptions(workerSelect);
	workerSelect.change(propertiesNextWorkerChanged('reply'));

	replyPane.find('#send_button').click(function(event) { sendReply(); });
	$('#reply_pane #discard_reply').click(function(event) { replyPane.find("input[name=message_id]").val("");tabChangeSubscreen('Conv', 'convo_tab', true); });

	propertiesToggleResumeDiv('reply');
}

/*
 * Add event handlers and initialize aspects that don't depent on a specific ticket
 * This is called only once when the app first loads (as opposed to when a ticket is clicked)
 */
function initPropertiesTab() {
	var propContainer = $('#properties_container');
	propContainer.find('button[name=me_button]').click(function(event) {propertiesMePressed('properties')});
	propContainer.find('button[name=anybody_button]').click(function(event) { propertiesAnyPressed('properties');});
	propContainer.find('input[name=status]').change(function(event) { propertiesToggleResumeDiv('properties')});

	var workerSelect = propContainer.find('select[name=next_worker]');
	createWorkerOptions(workerSelect);
	workerSelect.change(function(event) { propertiesNextWorkerChanged('properties');});

	createBucketOptions(propContainer.find('select[name=bucket_id]'));

	propContainer.find('#save_properties_button').click(function(event) { propertiesSave();});	

	propertiesToggleResumeDiv('properties');
}

/*
 * Initializes the properties tab fields to values that apply to the current ticket
 * called whenever the properties tab is clicked
 */
function initPropertiesTabForTicket() {
	var propContainer = $('#properties_container');
	var c4 = cerb4;
	var ticket = c4.ticket;
	
	//set subject
	propContainer.find('input[name=subject]').val(ticket.subject);
	
	//set status
	var statusInput = propContainer.find("input[name=status]");
	var statusVal = getTicketStatusValue();

	statusInput.filter('[value='+statusVal+']').attr('checked','checked');
	
	//set and show/hide 'resume' div based on status
	if (ticket.due_date > 0) {
		propContainer.find("input[name=ticket_reopen]").val(c4Date(ticket.due_date));
	}
	propertiesToggleResumeDiv('properties');
	
	
	//set next worker
	var workerSelect = propContainer.find('select[name=next_worker]');
	workerSelect.val(ticket.next_worker_id);
	
	//set and show/hide 'release after x' div based on next worker
	if (ticket.unlock_date != 0) {
		propContainer.find('input[name=unlock_date]').val(c4Date(ticket.unlock_date));
	}
	propertiesNextWorkerChanged('properties');
	
	//set category/team dropdown
	var catSelect = propContainer.find('select[name=bucket_id]');
	var selVal = null;
	if(ticket.category_id != 0) {
		selVal = 'c' + ticket.category_id;
	}
	else if(ticket.team_id != 0) {
		selVal = 't' + ticket.team_id;
	}
	if (selVal != null) {
		catSelect.val(selVal);
	}
	
	//show/hide spam training if it is not yet set
	propContainer.find('div.spam_training').toggle(ticket.spam_training == '');
}

function showHome() {
	$("#reply_pane input[name=message_id]").val("");

	$("#top_nav .top_tabs_display").hide();
	$("#top_nav .top_tabs_home").show();
	
	$("#tb_display").hide();
	$("#tb_display_right").hide();
	$("#tb_workspaces").show();
	
	var worklists = $("#worklists");
	var selectedLi = worklists.find('li.ticket_view_selection');
	console.log(selectedLi.offset());
	window.scrollTo(0, selectedLi.offset());
	
	selectedLi.removeClass('ticket_view_selection');
	
	$("#display").hide();
	$("#worklists").show();
}

function setTicketPropertiesBox() {
	console.log('setting ticket properties box');
	var c4 = cerb4;
	var ticket = c4.ticket;

	var status = getTicketStatus(ticket);
	$("#dispropStatus").text(status);
	
	var groupName = c4.groups[ticket.team_id].name;
	$("#dispropGroup").text(groupName);
	
	var bucket;
	if(ticket.category_id == 0) {
		bucket = "Inbox";
	}
	else {
		bucket = c4.categories[ticket.team_id][ticket.category_id].name;
	}
	$("#dispropCategory").text(bucket);
	
	$("#dispropMask").text(ticket.mask);	
	$("#dispropId").text(ticket.id);
	
	console.log("nextworker:"+ticket.next_worker_id);
	var worker;
	if(ticket.next_worker_id == 0) {
		worker = "None";
	}
	else {
		worker = c4.workers[ticket.next_worker_id].first_name + ' ' + c4.workers[ticket.next_worker_id].last_name;
	}
	$("#dispropWorker").text(worker);

}

function getTicketStatus(ticket) {
	var status;
	if(ticket.is_deleted) {
		status = "deleted";
	}
	else if(ticket.is_closed) {
		status = "closed";
	}
	else if(ticket.is_waiting) {
		status = "waiting for reply";
	}
	else {
		status = "open";
	}	
	return status;
}

function getTicketStatusValue() {
	var ticket = cerb4.ticket;
	var status;
	if(ticket.is_deleted) {
		status = 3;
	}
	else if(ticket.is_closed) {
		status = 1;
	}
	else if(ticket.is_waiting) {
		status = 2;
	}
	else {
		status = 0;
	}
	return status;
	
}

function renderConversation(ticket) {
	var convo = ticket.conversation;
	var convoHTML = [];
	
	var lastConvoBlock = getLastConvoBlock(convo);
	
	for(var a in convo) {
		var lastConvoId = lastConvoBlock[0] + lastConvoBlock[1];
		var convoId = convo[a][0] + convo[a][1];
		//type (m or c) and id must match for it to be expanded
		var expanded = (convoId==lastConvoId);
		if(convo[a][0] == 'm') {
			var message = ticket.messages[convo[a][1]];
			message.headers = ticket.headers[convo[a][1]]
			convoHTML[convoHTML.length] = renderMessage(message, expanded);
		}
		else {
			var comment = ticket.comments[convo[a][1]];
			convoHTML[convoHTML.length] = renderComment(comment, expanded);
		}
	}
	
	$("#conversation").html(convoHTML.join(""));

	$('#conversation div.convo_block_container').click(function(event) {
		event.preventDefault();
		doConvoBlockToggle($(this));
	});

	//add reply button handler
	$('#conversation').find("ul.message_buttons li button").click(function(event) { replyButton(event)});
	
}

function getLastConvoBlock(convo) {
	var latestTime = 0;
	var latestBlock = null;

	for(var a in convo) {
		var blockTime = a.split("_");
		if(blockTime[0] > latestTime) {
			latestTime = parseInt(blockTime[0]);
			latestBlock = convo[a];
		}
	}
	return latestBlock;
}

function renderMessage(message, expanded) {
//	var expanded = message.isLatestMessage;
	var imagePath = DevblocksAppPath + "resource/cerberusweb.mobile/images/";
	var expandedClass = (message.worker_id > 0) ? "from_outgoing" : "from_incoming";
		
	var html = [];
	html[html.length] = "<div class=\"convo_block_container message_container\"";
	if(expanded) {
		html[html.length] = " convo_block_expanded convo_block_expanded_init";
	}
	html[html.length] = "\"><ul class=\"convo_block_headers\">";
	
	var headers = message.headers;
	if(headers.from != null) html[html.length] = getConvoBlockHeaderHtml(expandedClass, "From", headers.from);
	if(headers.to != null) html[html.length] = getConvoBlockHeaderHtml("extra_header", "To", headers.to);
	if(headers.cc != null) html[html.length] = getConvoBlockHeaderHtml("extra_header", "Cc", headers.cc);
	if(headers.bcc != null) html[html.length] = getConvoBlockHeaderHtml("extra_header", "Bcc", headers.bcc);
	if(headers.subject != null) html[html.length] = getConvoBlockHeaderHtml("extra_header msg_subject", "Subject", headers.subject);
	if(headers.date != null) html[html.length] = getConvoBlockHeaderHtml("", "Date", headers.date);
	
	html[html.length] = "</ul><div class=\"convo_block_pane\"><div class=\"convo_block_content\">";
	if (message.content != null) {
		html[html.length] = escape_entities(message.content);
	}
	
	//TODO enforce privileges on these buttons
	html[html.length] = "</div><ul class=\"message_buttons\"><li><button type=\"button\" class=\"btnReply\"><img src=\"";
	html[html.length] = imagePath + "24x24/export2.png";
	html[html.length] = "\" align=\"top\"><br/>Reply</button></li>";
	
	html[html.length] = "<li><button type=\"button\" class=\"btnForward\"><img src=\"";
	html[html.length] = imagePath + "24x24/document_out.png";
	html[html.length] = "\" align=\"top\"><br/>Forward</button></li>";

	html[html.length] = "<li><button type=\"button\" class=\"btnNote\"><img src=\"";
	html[html.length] = imagePath + "24x24/document_plain.png";
	html[html.length] = "\" align=\"top\"><br/>Note</button></li></ul></div><div class=\"block_info\"><span class=\"propId prop\">"+message.id+"</span></div></div>";
	
	
	//html[html.length] = imagePath + "24x24/export2.png";
	
	return html.join("");
	
}

function renderComment(comment, expanded) {
	var html = [];
	html[html.length] = '<div class="convo_block_container"><ul class="convo_block_headers"><li class="from_comment"><span>[comment] ';
	
	if (comment.address.first_name == '' && comment.address.last_name == '') {
		html[html.length] = comment.address.email;
	}
	else {
		html[html.length] = comment.address.first_name + ' ' + comment.address.last_name;
	}
	html[html.length] = '</span></li>';
	if (comment.created > 0) {
		html[html.length] = '<li><span>Date:</span> ';
		html[html.length] = c4Date(comment.created);
		html[html.length] = '</li>';
	}
	html[html.length] = '</ul><div class="convo_block_pane"><div class="convo_block_content">';
	html[html.length] = escape_entities(comment.comment);
	html[html.length] = '</div></div><div class="block_info"><span class="propId prop">';
	html[html.length] = comment.id;
	html[html.length] = '</span></div></div>';
	
	return html.join("");
}

function getConvoBlockHeaderHtml(liClass, headerName, headerVal) {
	if (headerName.toLowerCase() == "from") {
		return "<li class=\"" + liClass + "\"><span class=\"header_name\">" + headerName + ": " + escape_entities(headerVal) + "</span></li>";
	}
	else {
		return "<li class=\"" + liClass + "\"><span class=\"header_name\">" + headerName + ":</span> " + escape_entities(headerVal) + "</li>";
	}
}

function escape_entities(html) {
  return html.
    replace(/&/gmi, '&amp;').
    replace(/"/gmi, '&quot;').
    replace(/>/gmi, '&gt;').
    replace(/</gmi, '&lt;')
}

function c4Date(time) {
	if (time > 0) {
		var date = new Date();
		date.setTime(time*1000);
		return date.toDateString() + ' ' + date.toLocaleTimeString();
	}
	else return '';
}

