{assign var=headers value=$message->getHeaders()}
<div class="block">
<table style="text-align: left; width: 98%;" border="0" cellpadding="2" cellspacing="0">
  <tbody>
    <tr>
      <td>
      <table cellspacing="0" cellpadding="0" width="100%" border="0">
      	<tr>
      		<td>
      			{if isset($headers.from)}
      				{if $expanded}
      					<h3>From: {$headers.from|escape:"htmlall"|nl2br}</h3>
      				{else}
      					<b style="color:rgb(50,120,50);">From: {$headers.from|escape:"htmlall"|nl2br}</b>
      				{/if}
      			{/if}
      		</td>
      		<td align="right">
		      {if !$expanded}
				<a href="javascript:;" onclick="genericAjaxGet('{$message->id}t','c=display&a=getMessage&id={$message->id}');">retrieve full message</a>
			  {else}
			  	<a href="javascript:;" onclick="toggleDiv('{$message->id}sh');toggleDiv('{$message->id}h');">show full headers</a>
      		  {/if}
      		</td>
      	</tr>
      </table>
      
	  <div id="{$message->id}sh" style="display:block;">      
      {if isset($headers.to)}<b>To:</b> {$headers.to|escape:"htmlall"|nl2br}<br>{/if}
      {if isset($headers.date)}<b>Date:</b> {$headers.date|escape:"htmlall"|nl2br}<br>{/if}
      </div>

	  <div id="{$message->id}h" style="display:none;">      
      	{if is_array($headers)}
      	{foreach from=$headers item=headerValue key=headerKey}
      		<b>{$headerKey|capitalize}:</b>
      		{* 
      		{if is_array($headerValue)}
      			{foreach from=$headerValue item=subHeader}
      				&nbsp;&nbsp;&nbsp;{$subHeader|escape:"htmlall"|nl2br}<br>
      			{/foreach}
      		{else}
      		{/if}
      		*}
   			{$headerValue|escape:"htmlall"|nl2br}<br>
      	{/foreach}
      	{/if}
      </div>
      
      <div style="display:block;">
      	{if $expanded}
      	<br>
    	  	{$message->getContent()|trim|escape:"htmlall"|makehrefs|nl2br} <br>
    	  	
    	  	<br>
	      	<table width="100%" cellpadding="0" cellspacing="0" border="0">
	      		<tr>
	      			<td align="left">
				      	<button type="button" onclick="displayAjax.reply('{$message->id}');"><img src="{devblocks_url}c=resource&p=cerberusweb.core&f=images/message_edit.gif{/devblocks_url}" align="top"> Reply</button>
				      	<button type="button" onclick="displayAjax.addNote('{$message->id}');"><img src="{devblocks_url}c=resource&p=cerberusweb.core&f=images/note_edit.gif{/devblocks_url}" align="top"> Add Note</button>
				      	<!-- <a href="javascript:;">more &raquo;</a> -->
	      			</td>
	      			<td align="right">
	      				<!-- <a href="#top">top</a> -->
	      			</td>
	      		</tr>
	      	</table>
	      	
	      	{assign var=attachments value=$message->getAttachments()}
	      	{if !empty($attachments)}
	      	<br>
	      	<b>Attachments:</b><br>
	      	<ul style="margin-top:0px;margin-bottom:5px;">
	      		{foreach from=$attachments item=attachment name=attachments}
					<li>
						<a href="{devblocks_url}c=files&p={$attachment->id}&name={$attachment->display_name}{/devblocks_url}" target="_blank" style="font-weight:bold;color:rgb(50,120,50);">{$attachment->display_name}</a>
						{assign var=bytes value=$attachment->file_size}
						( 
						{if !empty($attachment->file_size)} 
							{if $bytes > 1024000}
								{math equation="round(x/1024000)" x=$attachment->file_size} MB
							{elseif $bytes > 1048}
								{math equation="round(x/1048)" x=$attachment->file_size} KB
							{else}
								{$attachment->file_size} bytes
							{/if}
							- 
						{/if}
						{if !empty($attachment->mime_type)}{$attachment->mime_type}{else}unknown format{/if}
						 )
					</li>
				{/foreach}<br>
			</ul>
			{/if}
      	{/if}
		
		</div> <!-- end visible -->
      </td>
    </tr>
  </tbody>
</table>
</div>
<div id="{$message->id}b"></div>
<div id="{$message->id}notes" style="background-color:rgb(255,255,255);">
	{include file="$path/display/modules/conversation/notes.tpl.php"}
</div>
<form id="reply{$message->id}" action="{devblocks_url}{/devblocks_url}" method="POST" enctype="multipart/form-data"></form>
<br>