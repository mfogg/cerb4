<H1>Reset Password</H1>
<form action="{devblocks_url}{/devblocks_url}" method="post">
<input type="hidden" name="c" value="login">
<input type="hidden" name="a" value="doRecoverStep3">
You may now choose a new password.<br>
<br>

<b>New password:</b><br>
<input type="password" name="password" size="25" value=""><br>
<br>

<b>New password (confirm):</b><br>
<input type="password" name="confirm" size="25" value=""><br>
<br>
<input type="submit" value="Set Password">
</form>