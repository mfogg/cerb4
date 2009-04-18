	<ul class="worklist">
		{foreach from=$worklists item=worklist name=worklists}
		<li class="worklist_item">
			<div class="worklist_container">
				<div class="worklist_header">{$worklist->list_view->title}</div>
				<div class="worklist_content"></div>
				
				<div class="view_paging">
					<div class="view_paging_links">
						<span><a href="javascript:none();" class="view_page_link_first">&lt;&lt;</a></span>
						<span><a href="javascript:none();" class="view_page_link_prev">&lt;{$translate->_('common.previous_short')|capitalize}</a></span>
						<span><a href="javascript:none();" class="view_page_link_next">{$translate->_('common.next')|capitalize}&gt;</a></span>
						<span><a href="javascript:none();" class="view_page_link_last">&gt;&gt;</a></span>
					</div>
					<div class="view_paging_text"></div>

				</div>

				<div class="dval dval_viewid">{$worklist->id}</div>
			</div>
		</li>
		{/foreach}
	</ul>