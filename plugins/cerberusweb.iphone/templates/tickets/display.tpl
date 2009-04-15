<div id="display">

<div id="display_top">
	<h1>{$ticket->subject}</h1>
</div> 


{*
<div id="ticket_actions_container">
<ul class="ticket_actions" style="background-color: green;">
	<li><button type="button"><img src="{devblocks_url}c=resource&p=cerberusweb.core&f=images/folder_out.gif{/devblocks_url}" align="top"></button></li>
	<li><button type="button">Spam</button></li>
</ul>
<ul class="ticket_actions" style="background-color: orange;">
	<li><button type="button">Delete</button></li>
	<li><button type="button">Take</button></li>
</ul>
</div>
*}

<div id="ticket_action_links_container">
	<ul id="ticket_action_links">
			{if !$ticket->is_deleted}
				{if $ticket->is_closed}
					<li><a href="javascript:none();"><img src="{devblocks_url}c=resource&p=cerberusweb.iphone&f=images/folder_out.png{/devblocks_url}" align="top"></a></li>
				{else}
					{if $active_worker->hasPriv('core.ticket.actions.close')}<li><a title="{$translate->_('display.shortcut.close')}" href="javascript:none();"><img src="{devblocks_url}c=resource&p=cerberusweb.iphone&f=images/folder_ok.png{/devblocks_url}" align="top"></a></li>{/if}
				{/if}
				
				{if empty($ticket->spam_training)}
					{if $active_worker->hasPriv('core.ticket.actions.spam')}<li><a title="{$translate->_('display.shortcut.spam')}" href="javascript:none();"><img src="{devblocks_url}c=resource&p=cerberusweb.iphone&f=images/spam.png{/devblocks_url}" align="top"></a></li>{/if}
				{/if}
			{/if}

			{if $ticket->is_deleted}
				<li><a href="javascript:none();"><img src="{devblocks_url}c=resource&p=cerberusweb.iphone&f=images/delete_gray.gif{/devblocks_url}" align="top"></a></li>
			{else}
				{if $active_worker->hasPriv('core.ticket.actions.delete')}<li><a href="javascript:none();" title="{$translate->_('display.shortcut.delete')}"><img src="{devblocks_url}c=resource&p=cerberusweb.iphone&f=images/delete.png{/devblocks_url}" align="top"></a></li>{/if}
			{/if}
		
		
			{if empty($ticket->next_worker_id)}<li><a href="javascript:none();" title="{$translate->_('display.shortcut.take')}"><img src="{devblocks_url}c=resource&p=cerberusweb.iphone&f=images/hand_paper.png{/devblocks_url}" align="top"></a></li>{/if}
			{if $ticket->next_worker_id == $active_worker->id}<li><a href="javascript:none();" title="{$translate->_('display.shortcut.surrender')}"><img src="{devblocks_url}c=resource&p=cerberusweb.iphone&f=images/flag_yellow.png{/devblocks_url}" align="top"></a></li>{/if}
			
			<li id="top_button_reply">
				<a href="javascript:none();" onclick="replyButton(event);"><img src="{devblocks_url}c=resource&p=cerberusweb.iphone&f=images/export2.png{/devblocks_url}" align="top"></a>
			</li>

		
	</ul>
	
</div>			 


<div id="properties">
	<table border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td class="label">Status:</td>
			<td colspan="4">{if $ticket->is_deleted}{$translate->_('status.deleted')}{elseif $ticket->is_closed}{$translate->_('status.closed')}{elseif $ticket->is_waiting}{$translate->_('status.waiting')}{else}{$translate->_('status.open')}{/if}</td>
		</tr>
		<tr>
			<td class="label">Group:</td>
			<td>{$teams.$ticket_team_id->name}</td>
			<td width="30"></td>
			<td class="label">Bucket:</td>
			<td>{if !empty($ticket_category_id)}{$ticket_category->name}{else}{$translate->_('common.inbox')|capitalize}{/if}</td>
		</tr>
		<tr>
			<td class="label">Mask:</td>
			<td>{$ticket->mask}</td>
			<td width="30"></td>
			<td class="label">ID:</td>
			<td>{$ticket->id}</td>
		</tr>
		
	</table>
	
</div>

<div id="conversation">
	{if !empty($convo_timeline)}
		{foreach from=$convo_timeline item=convo_set name=items}
			{if $convo_set.0=='m'}
				{assign var=message_id value=$convo_set.1}
				{assign var=message value=$messages.$message_id}
{*				<div id="{$message->id}t" style="background-color:rgb(255,255,255);"> *}
					{assign var=expanded value=false}
					{if $expand_all || $latest_message_id==$message_id || isset($message_notes.$message_id)}{assign var=expanded value=true}{/if}
					{include file="$path/tickets/message.tpl" expanded=$expanded}
{*				</div> *}
				
			{elseif $convo_set.0=='c'}
				{assign var=comment_id value=$convo_set.1}
				{assign var=comment value=$comments.$comment_id}
				<div id="comment{$comment->id}" style="background-color:rgb(255,255,255);">
					{include file="$path/tickets/comment.tpl"}
				</div>
			{/if}
			
		{/foreach}
	{/if}
</div>




</div>

<div id="reply">
	{include file="$path/tickets/reply.tpl"}
</div>
