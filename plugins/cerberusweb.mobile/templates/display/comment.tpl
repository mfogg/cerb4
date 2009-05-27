{assign var=comment_address value=$comment->getAddress()}
<div class="convo_block_container">

		<ul class="convo_block_headers">
			<li class="from_comment"><span>[{$translate->_('common.comment')|lower}] {if empty($comment_address->first_name) && empty($comment_address->last_name)}&lt;{$comment_address->email|escape}&gt;{else}{$comment_address->getName()}{/if}</span></li>
			{if isset($comment->created)}<li><span>{$translate->_('message.header.date')|capitalize}:</span> {$comment->created|devblocks_date}</li>{/if}
		</ul>

		<div class="convo_block_pane">
			<div class="convo_block_content">
				{$comment->comment|trim|escape|makehrefs|nl2br}
			</div>
		</div>
		<div class="block_info">
			<span class="propId prop">{$comment->id}</span>
		</div>		
</div>


