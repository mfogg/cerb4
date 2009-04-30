<table cellpadding="2" cellspacing="1" border="0">
{assign var=last_group_id value=-1}
{foreach from=$custom_fields item=f key=f_id}
{assign var=field_group_id value=$f->group_id}
{if $field_group_id == 0 || $field_group_id == $ticket->team_id}
	{assign var=show_submit value=1}
	{if $field_group_id != $last_group_id}
		<tr>
			<td colspan="2" align="center"><b>{if $f->group_id==0}&nbsp;{else}{$groups.$field_group_id->name}{/if}</b></td>
		</tr>
	{/if}
		<tr>
			<td valign="top" width="1%" align="right" nowrap="nowrap">
				<input type="hidden" name="field_ids[]" value="{$f_id}">
				{$f->name}:
			</td>
			<td valign="top" width="99%">
				{if $f->type=='S'}
					<input type="text" name="field_{$f_id}" size="45" maxlength="255" value="{$custom_field_values.$f_id|escape}"><br>
				{elseif $f->type=='U'}
					<input type="text" name="field_{$f_id}" size="40" maxlength="255" value="{$custom_field_values.$f_id|escape}">
					{if !empty($custom_field_values.$f_id)}<a href="{$custom_field_values.$f_id|escape}" target="_blank">URL</a>{else}<i>(URL)</i>{/if}
				{elseif $f->type=='N'}
					<input type="text" name="field_{$f_id}" size="45" maxlength="255" value="{$custom_field_values.$f_id|escape}"><br>
				{elseif $f->type=='T'}
					<textarea name="field_{$f_id}" rows="4" cols="50" style="width:98%;">{$custom_field_values.$f_id}</textarea><br>
				{elseif $f->type=='C'}
					<input type="checkbox" name="field_{$f_id}" value="1" {if $custom_field_values.$f_id}checked{/if}><br>
				{elseif $f->type=='X'}
					{foreach from=$f->options item=opt}
					<label><input type="checkbox" name="field_{$f_id}[]" value="{$opt|escape}" {if isset($custom_field_values.$f_id.$opt)}checked="checked"{/if}> {$opt}</label><br>
					{/foreach}
				{elseif $f->type=='D'}
					<select name="field_{$f_id}">{* [TODO] Fix selected *}
						<option value=""></option>
						{foreach from=$f->options item=opt}
						<option value="{$opt|escape}" {if $opt==$custom_field_values.$f_id}selected{/if}>{$opt}</option>
						{/foreach}
					</select><br>
				{elseif $f->type=='M'}
					<select name="field_{$f_id}[]" size="5" multiple="multiple">
						{foreach from=$f->options item=opt}
						<option value="{$opt|escape}" {if isset($custom_field_values.$f_id.$opt)}selected="selected"{/if}>{$opt}</option>
						{/foreach}
					</select><br>
					<i><small>(hold CTRL or COMMAND to select multiple options)</small></i>
				{elseif $f->type=='E'}
					<input type="text" name="field_{$f_id}" size="35" maxlength="255" value="{if !empty($custom_field_values.$f_id)}{$custom_field_values.$f_id|devblocks_date}{/if}"><button type="button" onclick="ajax.getDateChooser('dateCustom{$f_id}',this.form.field_{$f_id});">&nbsp;<img src="{devblocks_url}c=resource&p=cerberusweb.core&f=images/calendar.gif{/devblocks_url}" align="top">&nbsp;</button>
					<div id="dateCustom{$f_id}" style="display:none;position:absolute;z-index:1;"></div>
				{elseif $f->type=='W'}
					{if empty($workers)}
						{php}$this->assign('workers', DAO_Worker::getAllActive());{/php}
					{/if}
					<select name="field_{$f_id}">
						<option value=""></option>
						{foreach from=$workers item=worker}
						<option value="{$worker->id}" {if $worker->id==$custom_field_values.$f_id}selected="selected"{/if}>{$worker->getName()}</option>
						{/foreach}
					</select>
				{/if}	
			</td>
		</tr>
	{assign var=last_group_id value=$f->group_id}
{/if}
{/foreach}
</table>
			