<div id="properties_container">
	<div>
		<div>
			<h3>Subject:</h3>
			<span><input type="text" name="subject" maxlength="255" value="{$ticket->subject|escape}" autocorrect="off" autocapitalize="off"></span>
		</div>

		<div><h3>Status:</h3>
			<ul>
				<li><label><input type="radio" name="status" value="0"{if !$ticket->is_closed && !$ticket->is_waiting} checked{/if}/>Open</label></li>
				<li><label><input type="radio" name="status" value="2"{if !$ticket->is_closed && $ticket->is_waiting} checked{/if}/>Waiting</label></li>
				{if $active_worker->hasPriv('core.ticket.actions.close') || ($ticket->is_closed && !$ticket->is_deleted)}<li><label><input type="radio" name="status" value="1"/>Closed</label></li>{/if}
				{if $active_worker->hasPriv('core.ticket.actions.delete') || ($ticket->is_deleted)}<li><label><input type="radio" name="status" value="3"/>Deleted</label></li>{/if}
			</ul>
		</div>
		
		
		<div class="properties_resume"  style="display:{if $ticket->next_worker_id}block{else}none{/if};">
			<h3>When to resume? <span class="eg">(e.g. "Friday", "7 days", "Tomorrow 11:15AM", "Dec 31")</span></h3>
			<span><input type="text" name="ticket_reopen" value="{if !empty($ticket->due_date)}{$ticket->due_date|devblocks_date}{/if}" autocorrect="off" autocapitalize="off"/></span>
		</div>
		
		<div>
			<h3>Who should handle the next reply?</h3>
			<span>
				<select name="next_worker" >
		      		{if $active_worker->id==$ticket->next_worker_id || 0==$ticket->next_worker_id || $active_worker->hasPriv('core.ticket.actions.assign')}<option value="0" {if 0==$ticket->next_worker_id}selected{/if}>{$translate->_('common.anybody')|capitalize}{/if}
		      		{foreach from=$workers item=worker key=worker_id name=workers}
						{if ($worker_id==$active_worker->id && !$ticket->next_worker_id) || $worker_id==$ticket->next_worker_id || $active_worker->hasPriv('core.ticket.actions.assign')}
			      			{if $worker_id==$active_worker->id}{assign var=next_worker_id_sel value=$smarty.foreach.workers.iteration}{/if}
			      			<option value="{$worker_id}" {if $worker_id==$ticket->next_worker_id}selected{/if}>{$worker->getName()}
						{/if}
		      		{/foreach}
				</select>
		      	{if $active_worker->hasPriv('core.ticket.actions.assign') && !empty($next_worker_id_sel)}
		      		<button type="button" id="properties_me_button" name="me_button" class="btn_short">{$translate->_('common.me')|lower}</button>
		      		<button type="button" id="properties_anybody_button" name="anybody_button" class="btn_short">any</button>
		      	{/if}
			</span>
		</div>
		
		<div class="properties_surrender" style="display:{if $ticket->next_worker_id}block{else}none{/if};">
			<h3>Allow anybody to handle the next reply after:</h3>
			<span>
				<input type="text" name="unlock_date" value="{if $ticket->unlock_date}{$ticket->unlock_date|devblocks_date}{/if}" autocorrect="off" autocapitalize="off"/>
			</span>
		</div>

		{if $active_worker->hasPriv('core.ticket.actions.move')}		
		<div>
			<h3>Bucket:</h3>
			<span>
				<select name="bucket_id">
				<option value="">-- move to --</option>
				{if empty($ticket->category_id)}{assign var=t_or_c value="t"}{else}{assign var=t_or_c value="c"}{/if}
				<optgroup label="Inboxes">
				{foreach from=$teams item=team}
					<option value="t{$team->id}">{$team->name}{if $t_or_c=='t' && $ticket->team_id==$team->id} (*){/if}</option>
				{/foreach}
				</optgroup>
				{foreach from=$team_categories item=categories key=teamId}
					{assign var=team value=$teams.$teamId}
					{if !empty($active_worker_memberships.$teamId)}
						<optgroup label="-- {$team->name} --">
						{foreach from=$categories item=category}
						<option value="c{$category->id}">{$category->name}{if $t_or_c=='c' && $ticket->category_id==$category->id} (current bucket){/if}</option>
						{/foreach}
						</optgroup>
					{/if}
				{/foreach}
				</select>
			</span>
		</div>
		{/if}

		{if '' == $ticket->spam_training && $active_worker->hasPriv('core.ticket.actions.spam')}
		<div>
			<h3>Spam Training: </h3>
			<ul>
				<li><label><input type="radio" name="spam_training" value="" checked="checked"> Unknown</label></li>
				<li><label><input type="radio" name="spam_training" value="S"> Spam</label></li>
				<li><label><input type="radio" name="spam_training" value="N"> Not Spam</label></li>
			</ul>
		</div>
		{/if}

		
		<div>
			<button type="button" id="save_properties_button" name="save_properties_button">Save</button>
		</div>
{*		
		<table>
			<tr>
				<td>Status:</td>
				
			</tr>
			<tr>
				<td><input type="radio" name="status" value="0"/>Open</td>
			</tr>
			<tr>
				<td><input type="radio" name="status" value="1" checked/>Waiting</td>
			</tr>
			<tr>
				<td><input type="radio" name="status" value="2"/>Closed</td>
			</tr>
			<tr>
				<td><input type="radio" name="status" value="3"/>Deleted</td>
			</tr>
			<tr>
				<td>Subject: </td>
			</tr>
			<tr>
				<td>
					<input type="text" name="subject" maxlength="255" value="{$ticket->subject|escape}" autocorrect="off" autocapitalize="off">
				</td>
			</tr>
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
				<td colspan="2">Allow anybody to handle the next reply after:</td>
			</tr>
			<tr>
				<td>
					<input type="text" name="unlock_date" autocorrect="off" autocapitalize="off"/>
				</td>
			</tr>

		</table>
		<table>
			{if $active_worker->hasPriv('core.ticket.actions.move')}
			<tr>
				<td>Bucket: </td>
				<td>
					<select name="bucket_id">
					<option value="">-- move to --</option>
					{if empty($ticket->category_id)}{assign var=t_or_c value="t"}{else}{assign var=t_or_c value="c"}{/if}
					<optgroup label="Inboxes">
					{foreach from=$teams item=team}
						<option value="t{$team->id}">{$team->name}{if $t_or_c=='t' && $ticket->team_id==$team->id} (*){/if}</option>
					{/foreach}
					</optgroup>
					{foreach from=$team_categories item=categories key=teamId}
						{assign var=team value=$teams.$teamId}
						{if !empty($active_worker_memberships.$teamId)}
							<optgroup label="-- {$team->name} --">
							{foreach from=$categories item=category}
							<option value="c{$category->id}">{$category->name}{if $t_or_c=='c' && $ticket->category_id==$category->id} (current bucket){/if}</option>
							{/foreach}
							</optgroup>
						{/if}
					{/foreach}
					</select>
				</td>
			</tr>
			{/if}				
		</table>
	
	
	
	<table cellpadding="0" cellspacing="2" border="0" width="98%">
		<tr>
			<td width="0%" nowrap="nowrap">{$translate->_('ticket.status')|capitalize}: </td>
			<td width="100%">
				<label><input type="radio" name="closed" value="0" onclick="toggleDiv('ticketClosed','none');" {if !$ticket->is_closed && !$ticket->is_waiting}checked{/if}>{$translate->_('status.open')|capitalize}</label>
				<label><input type="radio" name="closed" value="2" onclick="toggleDiv('ticketClosed','block');" {if !$ticket->is_closed && $ticket->is_waiting}checked{/if}>{$translate->_('status.waiting')|capitalize}</label>
				{if $active_worker->hasPriv('core.ticket.actions.close') || ($ticket->is_closed && !$ticket->is_deleted)}<label><input type="radio" name="closed" value="1" onclick="toggleDiv('ticketClosed','block');" {if $ticket->is_closed && !$ticket->is_deleted}checked{/if}>{$translate->_('status.closed')|capitalize}</label>{/if}
				{if $active_worker->hasPriv('core.ticket.actions.delete') || ($ticket->is_deleted)}<label><input type="radio" name="closed" value="3" onclick="toggleDiv('ticketClosed','none');" {if $ticket->is_deleted}checked{/if}>{$translate->_('status.deleted')|capitalize}</label>{/if}
			</td>
		</tr>
		<tr>
			<td width="0%" nowrap="nowrap">Subject: </td>
			<td width="100%">
				<input type="text" name="subject" size="45" maxlength="255" value="{$ticket->subject|escape}">
			</td>
		</tr>
		<tr>
			<td width="0%" nowrap="nowrap">Next Worker: </td>
			<td width="100%">
				<select name="next_worker_id">
					{if $active_worker->id==$ticket->next_worker_id || 0==$ticket->next_worker_id || $active_worker->hasPriv('core.ticket.actions.assign')}<option value="0" {if 0==$ticket->next_worker_id}selected{/if}>Anybody{/if}
					{foreach from=$workers item=worker key=worker_id}
						{if $worker_id==$ticket->next_worker_id || $active_worker->hasPriv('core.ticket.actions.assign')}
						<option value="{$worker_id}" {if $worker_id==$ticket->next_worker_id}selected{/if}>{$worker->getName()}
						{/if}
					{/foreach}
				</select>
			</td>
		</tr>
		
		{if $active_worker->hasPriv('core.ticket.actions.move')}
		<tr>
			<td width="0%" nowrap="nowrap">Bucket: </td>
			<td width="100%">
				<select name="bucket_id">
				<option value="">-- move to --</option>
				{if empty($ticket->category_id)}{assign var=t_or_c value="t"}{else}{assign var=t_or_c value="c"}{/if}
				<optgroup label="Inboxes">
				{foreach from=$teams item=team}
					<option value="t{$team->id}">{$team->name}{if $t_or_c=='t' && $ticket->team_id==$team->id} (*){/if}</option>
				{/foreach}
				</optgroup>
				{foreach from=$team_categories item=categories key=teamId}
					{assign var=team value=$teams.$teamId}
					{if !empty($active_worker_memberships.$teamId)}
						<optgroup label="-- {$team->name} --">
						{foreach from=$categories item=category}
						<option value="c{$category->id}">{$category->name}{if $t_or_c=='c' && $ticket->category_id==$category->id} (current bucket){/if}</option>
						{/foreach}
						</optgroup>
					{/if}
				{/foreach}
				</select>
			</td>
		</tr>
		{/if}
		
		{if '' == $ticket->spam_training && $active_worker->hasPriv('core.ticket.actions.spam')}
		<tr>
			<td width="0%" nowrap="nowrap" align="right">Spam Training: </td>
			<td width="100%">
				<label><input type="radio" name="spam_training" value="" checked="checked"> Unknown</label>
				<label><input type="radio" name="spam_training" value="S"> Spam</label>
				<label><input type="radio" name="spam_training" value="N"> Not Spam</label> 
			</td>
		</tr>
		{/if}
	</table>

	</div>
*}	

</div>