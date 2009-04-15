
function sayHi() {
	alert('hi');
	
}

$(document).ready(function(){
		//alert('hi');
		
	
//	$("div div:message_pane").toggle();	
		
		
	$('.message_container').click(function(event) {
		//alert('click');
		event.preventDefault();
		
		//alert(this);
		//$(this).html("<div>blahblahblah</div>");
		var container = $(this);
		var msgId = $("div.message_info span.propMid", $(this)).text();


		var message_pane = $("div.message_pane div.message_content", container);

		
		$("ul.message_headers li.extra_header", $(this)).slideToggle();
		
		if(message_pane.html().trim().length > 0) {
			message_pane.parent().slideToggle();
		}
		else {
			$.get("/cerb4/ajax.php", 
					{c: "iphone", a: "display", a2: "retrieveMessage", msgid: msgId}, 
					function(xml) {
						//var message_pane = $("div.message_pane div.message_content", container);
						message_pane.html(xml).parent().slideToggle();
						
				//		message_pane.children("message_content").html(xml).parent().children("message_buttons").toggle().parent().slideToggle();
						
						
						
						//message_pane.html(xml).parent().fadeIn("slow");
					});
		}
	});

	$('#conversation').find("ul.message_buttons li:first-child button").click(function(event) { replyButton(event)});


				
		//$(".div1").draggable();
		
		// $("a").addClass("test");
		// // Your code here
		// $("a").click(function(event) {
		// 	event.preventDefault();
		// 	//$(this).hide("slow");
		// 	$("a").addClass("test").show().html("foo");
		//  
		// });
		
	});
	


//$(document).ready(function(){
//		alert('hi');
		
//	$('.message_pane').click(function(event) {
//
//		event.preventDefault();
//		this.html("blahblahblah");
//	});

				
		//$(".div1").draggable();
		
		// $("a").addClass("test");
		// // Your code here
		// $("a").click(function(event) {
		// 	event.preventDefault();
		// 	//$(this).hide("slow");
		// 	$("a").addClass("test").show().html("foo");
		//  
		// });
		
//	});

	//$.get('myhtmlpage.html', myCallBack);


function replyButton(event) {
//console.log(event);
	
	event.stopPropagation();
	event.preventDefault();
	
	scrollTo(0,0);
//	 $(this).animate({"height": 100}, "slow");  
//	$("#display").animate({"width": 0}, "slow");
//	$("#reply").animate({"width": 330},"slow");
	
	$("#display").fadeOut("slow");
	$("#reply").fadeIn("slow");
}


function bindHandlers() {
//	$("")
}
