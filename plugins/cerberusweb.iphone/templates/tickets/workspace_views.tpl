<ul title="{$current_workspace}">
	{foreach from=$workspace_views item=workspace_view key=idx name=workspace_views}
    <li>
        <a href="{$smarty.const.DEVBLOCKS_WEBPATH}ajax.php?c=iphone&a=main&a2=showView&view_id={$workspace_view->id}">{$workspace_view->list_view->title}</a>
    </li>
	{/foreach}
</ul>
