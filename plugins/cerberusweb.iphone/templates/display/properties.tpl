<div id="properties_container">
	<div>
		<div>
			<h3>Subject:</h3>
			<span><input type="text" name="subject" maxlength="255" value="" autocorrect="off" autocapitalize="off"></span>
		</div>

		<form>
		<div><h3>Status:</h3>
			<ul>
				<li><label><input type="radio" name="status" value="0"{if !$ticket->is_closed && !$ticket->is_waiting} checked{/if}/>Open</label></li>
				<li><label><input type="radio" name="status" value="2"{if !$ticket->is_closed && $ticket->is_waiting} checked{/if}/>Waiting</label></li>
				<li><label><input type="radio" name="status" value="1"/>Closed</label></li>
				<li><label><input type="radio" name="status" value="3"/>Deleted</label></li>
			</ul>
		</div>
		</form>
		
		<div class="properties_resume"  style="display: none;">
			<h3>When to resume? <span class="eg">(e.g. "Friday", "7 days", "Tomorrow 11:15AM", "Dec 31")</span></h3>
			<span><input type="text" name="ticket_reopen" value="" autocorrect="off" autocapitalize="off"/></span>
		</div>
		
		<div>
			<h3>Who should handle the next reply?</h3>
			<span>
				<select name="next_worker" >
				</select>
	      		<button type="button" id="properties_me_button" name="me_button" class="btn_short">{$translate->_('common.me')|lower}</button>
	      		<button type="button" id="properties_anybody_button" name="anybody_button" class="btn_short">any</button>
			</span>
		</div>
		
		<div class="properties_surrender" style="display:none;">
			<h3>Allow anybody to handle the next reply after:</h3>
			<span>
				<input type="text" name="unlock_date" value="" autocorrect="off" autocapitalize="off"/>
			</span>
		</div>

		<div>
			<h3>Bucket:</h3>
			<span>
				<select name="bucket_id">
				</select>
			</span>
		</div>

		<div class='spam_training'>
			<h3>Spam Training: </h3>
			<ul>
				<li><label><input type="radio" name="spam_training" value="" checked="checked"> Unknown</label></li>
				<li><label><input type="radio" name="spam_training" value="S"> Spam</label></li>
				<li><label><input type="radio" name="spam_training" value="N"> Not Spam</label></li>
			</ul>
		</div>

{*		
{include file="$path/display/custom_fields.tpl"}
*}	
		
		<div>
			<button type="button" id="save_properties_button" name="save_properties_button">Save</button>
		</div>

</div>