{assign var=total value=$results[1]}
{assign var=tickets value=$results[0]}

<ul selected="true" class="view_list" title="{$view->name}">

	{* Column Data *}
	{foreach from=$tickets item=result key=idx name=results}

	{assign var=rowIdPrefix value="row_"|cat:$view->id|cat:"_"|cat:$result.t_id}
	{if $smarty.foreach.results.iteration % 2}
		{assign var=tableRowBg value="tableRowBg"}
	{else}
		{assign var=tableRowBg value="tableRowAltBg"}
	{/if}
	
		<li class="view_list_item" onclick="window.location.href='/cerb4/iphone/display/{$result.t_mask}';">
				<b id="subject_{$result.t_id}_{$view->id}">
				{if $result.t_is_closed}<strike>{/if}
				{$result.t_subject|escape|truncate:37:"..."}
				{if $result.t_is_closed}</strike>{/if}
				</b>
			<br />
			<!-- {$smarty.const.DEVBLOCKS_WEBPATH} -->
			<table>
				<tr>
					{* <td width="14"></td> *}
					<td>
						{if $result.t_last_action_code=='O'}
							{assign var=action_worker_id value=$result.t_next_worker_id}
							<span class="view_next_new">New</span> 
							{if isset($workers.$action_worker_id)}for {$workers.$action_worker_id->getName()}{else}from {$result.t_first_wrote|truncate:45:'...':true:true} {/if}
						{elseif $result.t_last_action_code=='R'}
							{assign var=action_worker_id value=$result.t_next_worker_id}
							<span class="view_next_in">In</span> for 
							{if isset($workers.$action_worker_id)}
								{$workers.$action_worker_id->getName()}
							{else}
								Helpdesk
							{/if}
						{elseif $result.t_last_action_code=='W'}
							{assign var=action_worker_id value=$result.t_last_worker_id}
							<span class="view_next_out">Out</span> from 
							{if isset($workers.$action_worker_id)}
								{$workers.$action_worker_id->getName()}
							{else}
								Helpdesk
							{/if}
						{/if}
					</td>
					<!--<td align="right">Support:Trials</td>-->
				</tr>
			</table>
			
			<div class="dval dval_ticket_id">{$result.t_id}</div>
			<div class="dval dval_view_id">{$view->id}</div>
			<div class="dval dval_first_wrote">{$result.t_first_wrote}</div>
			<div class="dval dval_last_wrote">{$result.t_last_wrote}</div>
		</li>
	
	{/foreach}
	
</ul>


<table cellpadding="2" cellspacing="0" border="0" width="100%" class="tableBg" id="{$view->id}_actions">
	<tr>
		<td align="right" valign="top" nowrap="nowrap">
			{math assign=fromRow equation="(x*y)+1" x=$view->renderPage y=$view->renderLimit}
			{math assign=toRow equation="(x-1)+y" x=$fromRow y=$view->renderLimit}
			{math assign=nextPage equation="x+1" x=$view->renderPage}
			{math assign=prevPage equation="x-1" x=$view->renderPage}
			{math assign=lastPage equation="ceil(x/y)-1" x=$total y=$view->renderLimit}
			
			<!-- Sanity checks -->
			{if $toRow > $total}{assign var=toRow value=$total}{/if}
			{if $fromRow > $toRow}{assign var=fromRow value=$toRow}{/if}
			
			{if $view->renderPage > 0}
				<a href="{devblocks_url}c=mobile&a=tickets&a2=overview&filter={$filter}&fid={$fid}&b={$bid}{/devblocks_url}?page=0">&lt;&lt;</a>
				<a href="{devblocks_url}c=mobile&a=tickets&a2=overview&filter={$filter}&fid={$fid}&b={$bid}{/devblocks_url}?page={$prevPage}" >&lt;{$translate->_('common.previous_short')|capitalize}</a>
			{/if}
			({'views.showing_from_to'|devblocks_translate:$fromRow:$toRow:$total})
			{if $toRow < $total}
				<a href="{devblocks_url}c=mobile&a=tickets&a2=overview&filter={$filter}&fid={$fid}&b={$bid}{/devblocks_url}?page={$nextPage}">{$translate->_('common.next')|capitalize}&gt;</a>
				<a href="{devblocks_url}c=mobile&a=tickets&a2=overview&filter={$filter}&fid={$fid}&b={$bid}{/devblocks_url}?page={$lastPage}">&gt;&gt;</a>
			{/if}
		</td>
	</tr>
</table>

