<ul title="Workspaces">
	{foreach from=$workspaces item=workspace key=idx name=results}
    <li>
        <a href="{$smarty.const.DEVBLOCKS_WEBPATH}ajax.php?c=iphone&a=main&a2=showWorkspaceViews&workspace={$workspace|escape:'url'}">{$workspace}</a>
    </li>
	{/foreach}
</ul>
