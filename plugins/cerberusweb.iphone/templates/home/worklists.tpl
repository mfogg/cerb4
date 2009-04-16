	<ul class="worklist">
		{foreach from=$worklists item=worklist name=worklists}
		<li class="worklist_item">
			<div class="worklist_container">
				<div class="worklist_header">{$worklist->list_view->title}</div>
				<div class="worklist_content"></div>
				<div class="dval dval_viewid">{$worklist->id}</div>
			</div>
		</li>
		{/foreach}
	</ul>