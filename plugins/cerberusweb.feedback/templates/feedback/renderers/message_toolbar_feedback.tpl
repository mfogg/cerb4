{if $active_worker->hasPriv('feedback.actions.create')}
<button type="button" onclick="genericAjaxPanel('c=feedback&a=showEntry&source_ext_id=feedback.source.ticket&source_id={$message->ticket_id}&msg_id={$message->id}&quote='+encodeURIComponent(Devblocks.getSelectedText())+'&url='+escape(window.location),null,false,'500px');"><img src="{devblocks_url}c=resource&p=cerberusweb.feedback&f=images/question_and_answer.png{/devblocks_url}" align="top"> {$translate->_('feedback.button.capture')|capitalize}</button>
{/if}