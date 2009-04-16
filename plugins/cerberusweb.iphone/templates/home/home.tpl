{include file="$path/top_nav.tpl"}
<div id="toolbar">
	
	<div id="tb">
	<select onchange="workspaceChanged(this.value);">
		<!-- <option>Notifications</option> -->
	{foreach from=$workspaces item=workspace name=workspaces}
		<option value="{$workspace|escape}">{$workspace}</option>
	{/foreach}
	</select>
	</div>
</div>

<div id="worklists"></div>