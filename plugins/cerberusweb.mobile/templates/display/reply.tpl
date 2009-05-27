<div id="reply_pane">
	<div><h1 id="reply_pane_title">Reply</h1></div>
	<input type="hidden" name="message_id" value="">
	<input type="hidden" name="ticket_id" value="">
	<table class="forward_only">
		<tr>
			<td width="0%" nowrap="nowrap"><b>To: </b></td>
			<td width="100%" align="left">
				<input type="text" size="45" id="replyForm_to" name="to" value="">
			</td>
		</tr>
	</table>
	<table class="reply_only">
		<tr>
			<td>Requesters: <span id="requesters"></span></td>
		</tr>
	</table>
	<table>
		<tbody>
		<tr>
			<td width="30">Cc: </td>
			<td><input type="text" name="cc" autocorrect="off" autocapitalize="off"/></td>
		</tr>
		</tbody>
	</table>
	
	<table>
		<tr>
			<td width="30">Bcc: </td>
			<td><input type="text" name="bcc" autocorrect="off" autocapitalize="off"/></td>
		</tr>
	</table>
	
	<table>
		<tr>
			<td width="50">Subject: </td>
			<td><input type="text" name="subject" value=""/></td>
		</tr>
	</table>
	<table>
		<tr>
			<td>
<textarea name="content" rows="20" cols="80" class="reply" style="width:98%;border:1px solid rgb(180,180,180);padding:5px;">
</textarea>
			
			</td>
		</tr>
	</table>
	
	<div id="reply_next_actions">
	<table>
	<tr>
	<td id="reply_next_actions_bar"></td>
	<td>
		<form>
		<table>
			<tr>
				<td colspan="2">Next:</td>
				
			</tr>
			<tr>
				<td style="width: 20px;"><input type="radio" name="status" value="0"/></td>
				<td>Open</td>
			</tr>
			<tr>
				<td><input type="radio" name="status" value="2" checked/></td>
				<td>Waiting</td>
			</tr>
			<tr>
				<td><input type="radio" name="status" value="1"/></td>
				<td>Closed</td>
			</tr>
		</table>
		</form>
		<table class="properties_resume">
			<tr>
				<td>When to resume? <span class="eg">(e.g. "Friday", "7 days", "Tomorrow 11:15AM", "Dec 31")</span></td>
			</tr>
			<tr>
				<td><input type="text" name="ticket_reopen" autocorrect="off" autocapitalize="off"/></td>
			</tr>
		</table>
		<table>
			<tr>
				<td>Who should handle the next reply?</td>
			</tr>
			<tr>
				<td>
					<select name="next_worker">
					</select>
			      		<button type="button" id="reply_me_button" name="me_button" class="btn_short">me</button>
			      		<button type="button" id="reply_anybody_button" name="anybody_button" class="btn_short">any</button>
				</td>
			</tr>
		</table>
	
		<table class="reply_surrender">
			<tr>
				<td>Allow anybody to handle the next reply after:</td>
			</tr>
			<tr>
				<td>
					<input type="text" name="unlock_date" autocorrect="off" autocapitalize="off"/>
				</td>
			</tr>
		</table>

		<div id="reply_buttons">
			<button type="button" id="send_button"><img src="{devblocks_url}c=resource&p=cerberusweb.core&f=images/check.gif{/devblocks_url}" align="top"> Send</button>

			<button type="button" id="discard_reply"><img src="{devblocks_url}c=resource&p=cerberusweb.core&f=images/delete.gif{/devblocks_url}" align="top"> Discard</button>
		</div>
		</td>
		</tr>
		</table>
		
		
		
	</div>


</div>
