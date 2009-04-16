<div id="top_nav">
	<img src="{devblocks_url}c=resource&p=cerberusweb.iphone&f=images/c4_logo_20.gif{/devblocks_url}" align="top">
	<ul id="top_tabs">
		<li class="top_tabs_selected"><a href="{devblocks_url}c=iphone&a=home{/devblocks_url}">home</a></li>{strip}
		{/strip}<li><a href="#">mail</a></li>{strip}
		{/strip}<li><a href="#">activity</a></li>

	</ul>
</div>
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