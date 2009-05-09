{include file="$path/display/top_nav.tpl"}
<div id="toolbar">
	<div id="tb_display" class="tb">
		<a href="javascript:none();" id="tb_btn_back_display2"><img src="{devblocks_url}c=resource&p=cerberusweb.iphone&f=images/24x24/arrow_left_green.png{/devblocks_url}" align="top"></a>		
			{assign var="tb_closed_class" value=""}
			{assign var="tb_spam_class" value=""}
			{assign var="tb_deleted_class" value=""}
			{assign var="tb_take_class" value=""}			

			{if $ticket->is_deleted } 
				{assign var="tb_closed_class" value=" tb_link_grayed"}
				{assign var="tb_spam_class" value=" tb_link_grayed"}
				{assign var="tb_deleted_class" value=" tb_link_grayed"}
				
			{else}

				{if !$ticket->is_closed AND !$active_worker->hasPriv('core.ticket.actions.close')}
					{assign var="tb_closed_class" value=" tb_link_grayed"}
				{/if}
				{if !$active_worker->hasPriv('core.ticket.actions.delete')}
					{assign var="tb_deleted_class" value=" tb_link_grayed"}
				{/if}
				
				{if !empty($ticket->spam_training) OR !$active_worker->hasPriv('core.ticket.actions.spam')}
					{assign var="tb_spam_class" value=" tb_link_grayed"}
				{/if}
				
			{/if}
			
			{if !empty($ticket->next_worker_id) AND $ticket->next_worker_id != $active_worker->id}
				{assign var="tb_take_class" value=" tb_link_grayed"}
			{/if}

			{if $ticket->is_closed}
				<a href="javascript:none();" id="tb_btn_reopen" class="tb_prop_link{$tb_closed_class}"><img src="{devblocks_url}c=resource&p=cerberusweb.iphone&f=images/24x24/folder_out.png{/devblocks_url}" align="top"></a>
			{else}
				<a href="javascript:none();" id="tb_btn_close" class="tb_prop_link{$tb_closed_class}"><img src="{devblocks_url}c=resource&p=cerberusweb.iphone&f=images/24x24/folder_ok.png{/devblocks_url}" align="top"></a>
			{/if}
			
			<a href="javascript:none();" id="tb_btn_spam" class="tb_prop_link{$tb_spam_class}"><img src="{devblocks_url}c=resource&p=cerberusweb.iphone&f=images/24x24/spam.png{/devblocks_url}" align="top"></a>

			<a href="javascript:none();" id="tb_btn_delete" class="tb_prop_link{$tb_deleted_class}"><img src="{devblocks_url}c=resource&p=cerberusweb.iphone&f=images/24x24/delete.png{/devblocks_url}" align="top"></a>
		
			{if $ticket->next_worker_id == $active_worker->id}
				<a href="javascript:none();" id="tb_btn_release" class="tb_prop_link{$tb_take_class}"><img src="{devblocks_url}c=resource&p=cerberusweb.iphone&f=images/24x24/flag_yellow.png{/devblocks_url}" align="top"></a>
			{else}
				<a href="javascript:none();" id="tb_btn_take" class="tb_prop_link{$tb_take_class}"><img src="{devblocks_url}c=resource&p=cerberusweb.iphone&f=images/24x24/hand_paper.png{/devblocks_url}" align="top"></a>
			{/if}
			
	</div>

	<div id="tb_display_right" class="tb tb_right">
		<a href="javascript:none();" id="tb_btn_back_display"><img src="{devblocks_url}c=resource&p=cerberusweb.iphone&f=images/24x24/export2.png{/devblocks_url}" align="top"></a>		
	</div>


	<div id="tb_reply" class="tb">
		<a href="javascript:none();" id="tb_btn_back_display"><img src="{devblocks_url}c=resource&p=cerberusweb.iphone&f=images/24x24/arrow_left_green.png{/devblocks_url}" align="top"></a>		
	</div>
	
	<div id="tb_home" class="tb">
		<select onchange="workspaceChanged(this.value);">
			<!-- <option>Notifications</option> -->
		{foreach from=$workspaces item=workspace name=workspaces}
			<option value="{$workspace|escape}">{$workspace}</option>
		{/foreach}
		</select>
	</div>
	
</div>


<div id="display">

	<div id="convo_tab">
		<div id="display_top">
			<h1>{$ticket->subject}</h1>
		</div> 
		
		
		<div id="properties">
			<table border="0" cellspacing="0" cellpadding="0">
				<tr>
					<td class="label">Status:</td>
					<td colspan="4" id="dispropStatus">{if $ticket->is_deleted}{$translate->_('status.deleted')}{elseif $ticket->is_closed}{$translate->_('status.closed')}{elseif $ticket->is_waiting}{$translate->_('status.waiting')}{else}{$translate->_('status.open')}{/if}</td>
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
				<tr>
					<td class="label">Worker:</td>
					<td>{$ticket->next_worker_id}</td>
					<td width="30"></td>
					<td class="label"></td>
					<td></td>
				</tr>
				
			</table>
			<div class="dval nextWorkerId">{$ticket->next_worker_id}</div>
			<div class="dval ticketIdDval">{$ticket->id}</div>
		</div>
		
		<div id="conversation"></div>
	</div>
	
	
	
	<div id="reply">
		{include file="$path/display/reply.tpl"}
	</div>
	
	<div id="properties_tab">
		{include file="$path/display/properties.tpl"}
	</div>

</div>


<div id="worklists"></div>
