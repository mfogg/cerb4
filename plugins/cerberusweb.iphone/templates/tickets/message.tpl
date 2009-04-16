{assign var=headers value=$message->getHeaders()}
<div id="mcon_{$message->id}" class="message_container">
      			{assign var=sender_id value=$message->address_id}
      			{if isset($message_senders.$sender_id)}
      				{assign var=sender value=$message_senders.$sender_id}
      				{assign var=sender_org_id value=$sender->contact_org_id}
      				{assign var=sender_org value=$message_sender_orgs.$sender_org_id}
      				{assign var=is_outgoing value=$message->worker_id}
      			{/if}
      
	  <ul class="message_headers">
	  	{if is_outgoing}
			{assign var="from_style" value="from_outgoing"}
		{else}
			{assign var="from_style" value="from_incoming"}
		{/if}
		
	      {if isset($headers.from)}<li class="{$from_style}"><span>{$translate->_('message.header.from')|capitalize}:</span> <span>{$headers.from|escape|nl2br}</span></li>{/if}
	      {if isset($headers.to)}<li class="extra_header"><span>{$translate->_('message.header.to')|capitalize}:</span> {$headers.to|escape|nl2br}</li>{/if}
	      {if isset($headers.cc)}<li class="extra_header"><span>{$translate->_('message.header.cc')|capitalize}:</span> {$headers.cc|escape|nl2br}</li>{/if}
	      {if isset($headers.bcc)}<li class="extra_header"><span>{$translate->_('message.header.bcc')|capitalize}:</span> {$headers.bcc|escape|nl2br}</li>{/if}      
	      {if isset($headers.subject)}<li class="extra_header"><span>{$translate->_('message.header.subject')|capitalize}:</span> {$headers.subject|escape|nl2br}</li>{/if}
	      {if isset($headers.date)}<li><span>{$translate->_('message.header.date')|capitalize}:</span> {$headers.date|escape|nl2br}</li>{/if}
      </ul>
      
      <div class="message_pane" >
      	
			<div class="message_content">
    	  		{if $expanded}
				{$message->getContent()|trim|escape|makehrefs|nl2br}
				{/if}
			</div>
	      	<ul class="message_buttons">
		      	{if $active_worker->hasPriv('core.display.actions.reply')}<li><button {if $latest_message_id==$message->id}id="btnReplyFirst"{/if} type="button"> <img src="{devblocks_url}c=resource&p=cerberusweb.iphone&f=images/24x24/export2.png{/devblocks_url}" align="top"><br/>{$translate->_('display.ui.reply')|capitalize}</button></li>{/if}
		      	{if $active_worker->hasPriv('core.display.actions.forward')}<li><button type="button" onclick="displayAjax.reply('{$message->id}',1);"><img src="{devblocks_url}c=resource&p=cerberusweb.iphone&f=images/24x24/document_out.png{/devblocks_url}" align="top"> <br/>{$translate->_('display.ui.forward')|capitalize}</button></li>{/if}
		      	{if $active_worker->hasPriv('core.display.actions.note')}<li><button type="button" onclick="displayAjax.addNote('{$message->id}');"><img src="{devblocks_url}c=resource&p=cerberusweb.iphone&f=images/24x24/document_plain.png{/devblocks_url}" align="top"> <br/>Note</button></li>{/if}
	      	</ul>
		
		</div>
		
		<div class="message_info">
			<span class="propMid prop">{$message->id}</span>
		</div>
</div>
{*
<div id="{$message->id}notes" style="background-color:rgb(255,255,255);">
	{include file="$core_tpl/display/modules/conversation/notes.tpl"}
</div>
*}
