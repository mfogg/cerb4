<div id="reply_pane">
	<div><h1>Reply</h1></div>
	<table>
		<tr>
			<td>Requesters:</td>
		</tr>
		<tr>
			<td>
				<select multiple style="width: 100%;">
					<option selected>mikeyfogg@gmail.com</option>
					<option>mike@extraice.com</option>					
				</select>
</td>
		</tr>
	</table>
	<table>
		<tbody>
		<tr>
			<td width="30">Cc:</td>
			<td><input type="text" name="cc"/></td>
		</tr>
		</tbody>
	</table>
	
	<table>
		<tr>
			<td width="30">Bcc:</td>
			<td><input type="text" name="bcc"/></td>
		</tr>
	</table>
	
	<table>
		<tr>
			<td width="50">Subject:</td>
			<td><input type="text" name="subject"/></td>
		</tr>
	</table>
	<table>
		<tr>
			<textarea rows="7" name="reply_body"></textarea>	
		</tr>
	</table>
	
	<div id="reply_next_actions">
	<table>
	<tr>
	<td id="reply_next_actions_bar"></td>
	<td>
	
		<table>
			<tr>
				<td colspan="2">Next:</td>
				
			</tr>
			<tr>
				<td style="width: 20px;"><input type="radio" name="status" value="0"/></td>
				<td>Open</td>
			</tr>
			<tr>
				<td><input type="radio" name="status" value="1"/></td>
				<td>Waiting</td>
			</tr>
			<tr>
				<td><input type="radio" name="status" value="2"/></td>
				<td>Closed</td>
			</tr>
		</table>
		<table>
			<tr>
				<td>When to resume? <span class="eg">(e.g. "Friday", "7 days", "Tomorrow 11:15AM", "Dec 31")</span></td>
			</tr>
			<tr>
				<td><input type="text" name="resume"/></td>
			</tr>
		</table>
		<table>
			<tr>
				<td>Who should handle the next reply?</td>
			</tr>
			<tr>
				<td>
					<select>
						<option>Mike Fogg</option>
						<option>Christopher Moltisanti</option>					
					</select>
					<button name="me_button" class="btn_short">me</button>
					<button name="anybody_button" class="btn_short">any</button>
				</td>
			</tr>
		</table>
	
		<table>
			<tr>
				<td>Allow anybody to handle the next reply after:</td>
			</tr>
			<tr>
				<td>
					<input type="text" name="subject"/>
				</td>
			</tr>
		</table>
		
		</td>
		</tr>
		</table>
		
	</div>


</div>
