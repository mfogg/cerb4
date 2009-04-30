<div id="reply_pane">
	<div><h1 id="reply_pane_title">Reply</h1></div>
	<input type="hidden" name="message_id" value="">
	<input type="hidden" name="ticket_id" value="{$ticket->id}">
	<table class="forward_only">
		<tr>
			<td width="0%" nowrap="nowrap"><b>{$translate->_('message.header.to')|capitalize}: </b></td>
			<td width="100%" align="left">
				<input type="text" size="45" id="replyForm_to" name="to" value="">
			</td>
		</tr>
	</table>
	<table class="reply_only">
		<tr>
			<td>{$translate->_('ticket.requesters')|capitalize}: </td>
		</tr>
		<tr>
			<td>
				<select name="requesters" multiple style="width: 100%;">
					{foreach from=$requesters item=requester}
						<option selected>{$requester->email}</option>
					{/foreach}
				</select>
			</td>
		</tr>
	</table>
	<table>
		<tbody>
		<tr>
			<td width="30">{$translate->_('message.header.cc')|capitalize}: </td>
			<td><input type="text" name="cc" autocorrect="off" autocapitalize="off"/></td>
		</tr>
		</tbody>
	</table>
	
	<table>
		<tr>
			<td width="30">{$translate->_('message.header.bcc')|capitalize}: </td>
			<td><input type="text" name="bcc" autocorrect="off" autocapitalize="off"/></td>
		</tr>
	</table>
	
	<table>
		<tr>
			<td width="50">{$translate->_('message.header.subject')|capitalize}: </td>
			<td><input type="text" name="subject" value="{$ticket->subject|escape}"/></td>
		</tr>
	</table>
	<table>
		<tr>
			<td>
{* <textarea rows="7" name="reply_body"></textarea>	 *}
{if $is_forward}
<textarea name="content" rows="20" cols="80" id="reply_{$message->id}" class="reply" style="width:98%;border:1px solid rgb(180,180,180);padding:5px;">
{if !empty($signature)}{$signature}{/if}

{$translate->_('display.reply.forward.banner')}
{if isset($headers.subject)}{$translate->_('message.header.subject')|capitalize}: {$headers.subject|escape|cat:"\n"}{/if}
{if isset($headers.from)}{$translate->_('message.header.from')|capitalize}: {$headers.from|escape|cat:"\n"}{/if}
{if isset($headers.date)}{$translate->_('message.header.date')|capitalize}: {$headers.date|escape|cat:"\n"}{/if}
{if isset($headers.to)}{$translate->_('message.header.to')|capitalize}: {$headers.to|escape|cat:"\n"}{/if}

{$message->getContent()|trim|escape}
</textarea>
{else}
<textarea name="content" rows="20" cols="80" id="reply_{$message->id}" class="reply" style="width:98%;border:1px solid rgb(180,180,180);padding:5px;">
{if !empty($signature) && $signature_pos}

{$signature}{*Sig above, 2 lines necessary whitespace*}


{/if}{assign var=reply_date value=$message->created_date|devblocks_date}{'display.reply.reply_banner'|devblocks_translate:$reply_date:$headers.from}
{$message->getContent()|trim|escape|indent:1:'> '}

{if !empty($signature) && !$signature_pos}{$signature}{/if}{*Sig below*}
</textarea>
{/if}			
			
			</td>
		</tr>
	</table>
	
	<div id="reply_next_actions">
	<table>
	<tr>
	<td id="reply_next_actions_bar"></td>
	<td>
	
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
		<table>
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
			      		{if $active_worker->id==$ticket->next_worker_id || 0==$ticket->next_worker_id || $active_worker->hasPriv('core.ticket.actions.assign')}<option value="0" {if 0==$ticket->next_worker_id}selected{/if}>{$translate->_('common.anybody')|capitalize}{/if}
			      		{foreach from=$workers item=worker key=worker_id name=workers}
							{if ($worker_id==$active_worker->id && !$ticket->next_worker_id) || $worker_id==$ticket->next_worker_id || $active_worker->hasPriv('core.ticket.actions.assign')}
				      			{if $worker_id==$active_worker->id}{assign var=next_worker_id_sel value=$smarty.foreach.workers.iteration}{/if}
				      			<option value="{$worker_id}" {if $worker_id==$ticket->next_worker_id}selected{/if}>{$worker->getName()}
							{/if}
			      		{/foreach}
					</select>
			      	{if $active_worker->hasPriv('core.ticket.actions.assign') && !empty($next_worker_id_sel)}
			      		<button type="button" id="reply_me_button" name="me_button" class="btn_short">{$translate->_('common.me')|lower}</button>
			      		<button type="button" id="reply_anybody_button" name="anybody_button" class="btn_short">any</button>
			      	{/if}
				</td>
			</tr>
		</table>
	
		<table class="reply_surrender" style="display:{if $ticket->next_worker_id}block{else}none{/if};">
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

			<button type="button" id="discard_reply"><img src="{devblocks_url}c=resource&p=cerberusweb.core&f=images/delete.gif{/devblocks_url}" align="top"> {$translate->_('display.ui.discard')|capitalize}</button>
			{* <button type="button" onclick="clearDiv('reply{$message->id}');genericAjaxGet('','c=display&a=discardAndSurrender&ticket_id={$ticket->id}');"><img src="{devblocks_url}c=resource&p=cerberusweb.core&f=images/flag_white.gif{/devblocks_url}" align="top"> {$translate->_('display.ui.discard_surrender')}</button>*}
		</div>
		</td>
		</tr>
		</table>
		
		
		
	</div>


</div>
