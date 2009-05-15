<div id="top_nav">
	<img src="{devblocks_url}c=resource&p=cerberusweb.iphone&f=images/c4_logo_20.gif{/devblocks_url}" align="top">
	<ul class="top_tabs top_tabs_home">
		<li class="top_tabs_selected"><a href="javascript:void(0);">home</a></li>{strip}
		{/strip}{* <li><a href="javascript:void(0);">mail</a></li>{strip}
		{/strip}*}<li><a href="javascript:void(0);">activity</a></li>

	</ul>
	
	<ul class="top_tabs top_tabs_display">
		<li class="top_tabs_selected"><a href="javascript:none();">Conv</a></li>{strip}
		{/strip}<li><a href="javascript:void(0);">Props</a></li>{strip}
		{/strip}{* <li><a href="javascript:void(0);">Tasks</a></li> *}

	</ul>
</div>

<div id="toolbar">
	
	<div id="tb_workspaces" class="tb">
		<select onchange="workspaceChanged(this.value);">
			<!-- <option>Notifications</option> -->
		{foreach from=$workspaces item=workspace name=workspaces}
			<option value="{$workspace|escape}">{$workspace}</option>
		{/foreach}
		</select>
	</div>
	
	<div id="tb_display" class="tb">
		<a href="javascript:none();" id="tb_btn_back_display2"><img src="{devblocks_url}c=resource&p=cerberusweb.iphone&f=images/24x24/arrow_left_green.png{/devblocks_url}" align="top"></a>		
		<a href="javascript:none();" id="tb_btn_close" class="tb_prop_link"><img src="{devblocks_url}c=resource&p=cerberusweb.iphone&f=images/24x24/folder_ok.png{/devblocks_url}" align="top"></a>
		<a href="javascript:none();" id="tb_btn_spam" class="tb_prop_link"><img src="{devblocks_url}c=resource&p=cerberusweb.iphone&f=images/24x24/spam.png{/devblocks_url}" align="top"></a>
		<a href="javascript:none();" id="tb_btn_delete" class="tb_prop_link"><img src="{devblocks_url}c=resource&p=cerberusweb.iphone&f=images/24x24/delete.png{/devblocks_url}" align="top"></a>
		<a href="javascript:none();" id="tb_btn_take" class="tb_prop_link"><img src="{devblocks_url}c=resource&p=cerberusweb.iphone&f=images/24x24/hand_paper.png{/devblocks_url}" align="top"></a>
	</div>	

	<div id="tb_display_right" class="tb tb_right">
		<a href="javascript:none();" id="tb_btn_reply_display"><img src="{devblocks_url}c=resource&p=cerberusweb.iphone&f=images/24x24/export2.png{/devblocks_url}" align="top"></a>		
	</div>


	<div id="tb_reply" class="tb">
		<a href="javascript:none();" id="tb_btn_back_display"><img src="{devblocks_url}c=resource&p=cerberusweb.iphone&f=images/24x24/arrow_left_green.png{/devblocks_url}" align="top"></a>		
	</div>
	
</div>

<div id="worklists"></div>

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
					<td id="dispropGroup">{$teams.$ticket_team_id->name}</td>
					<td width="30"></td>
					<td class="label">Bucket:</td>
					<td id="dispropCategory">{if !empty($ticket_category_id)}{$ticket_category->name}{else}{$translate->_('common.inbox')|capitalize}{/if}</td>
				</tr>
				<tr>
					<td class="label">Mask:</td>
					<td id="dispropMask">{$ticket->mask}</td>
					<td width="30"></td>
					<td class="label">ID:</td>
					<td id="dispropId">{$ticket->id}</td>
				</tr>
				<tr>
					<td class="label">Worker:</td>
					<td id="dispropWorker">{$ticket->next_worker_id}</td>
					<td width="30"></td>
					<td class="label"></td>
					<td></td>
				</tr>
				
			</table>
			<div class="dval nextWorkerId"></div>
			<div class="dval ticketIdDval"></div>
			
		</div>

		<div id="conversation"></div>


	</div>


		{include file="$path/display/reply.tpl"}
	
		{include file="$path/display/properties.tpl"}

</div>
