
$(document).ready(function(){
		
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
			{c: "iphone", a: "home", a2: "showView", view_id: viewId, page: page}, 
			function(xml) {
				contentDiv.fadeOut("normal", function() {
					if (isPaging) {
						contentDiv.html(xml).fadeIn();
					}
					else {
						contentDiv.html(xml).slideToggle();
					}

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
	//alert(viewPagingObjStr);
	console.log(new String("("+viewPagingObjStr+")"));
	var viewPagingObj =  eval("("+viewPagingObjStr+")");


	var linkFirst = viewPagingLinks.find(".view_page_link_first").parent();
	var linkPrev = viewPagingLinks.find(".view_page_link_prev").parent();
	var linkNext = viewPagingLinks.find(".view_page_link_next").parent();
	var linkLast = viewPagingLinks.find(".view_page_link_last").parent();
	
	//console.log(viewPagingObj.currentPage + " >= 0");
	console.log(viewPagingObj.toRow + " < "+viewPagingObj.total);
	
	var previousVisibility = (parseInt(viewPagingObj.currentPage) > 0) ? "visible" : "hidden";
	var nextVisibility =  ( parseInt(viewPagingObj.toRow) < parseInt(viewPagingObj.total)) ? "visible" : "hidden";
	//alert(previousVisibility + ":" + nextVisibility);
	console.log(previousVisibility + ":" + nextVisibility);
	
	//show or hide the next/prev view links
	linkPrev.css("visibility", previousVisibility);
	linkFirst.css("visibility", previousVisibility);
	
	console.log("setting linkNext visibility to %s", nextVisibility);
	linkNext.css("visibility", nextVisibility);
	linkLast.css("visibility", nextVisibility);		
	
	//set the page number that will be used when clicked to know what page to fetch for the view
	linkFirst.data("page", 0);
	linkPrev.data("page", viewPagingObj.prevPage);
	linkNext.data("page", viewPagingObj.nextPage);
	linkLast.data("page", viewPagingObj.lastPage);
	
	//console.debug(viewPagingDiv.children("div.view_paging_text"));
	viewPagingDiv.children("div.view_paging_text").text(viewPagingObj.pageDesc);
	//console.debug(viewPagingDiv.children("div.view_paging_text"));
	console.log(viewPagingObj.prevPage + ":"+viewPagingObj.nextPage);
}

