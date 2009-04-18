<div>
{assign var=logo_url value=$settings->get('helpdesk_logo_url','')}
{if empty($logo_url)}
<img src="{devblocks_url}c=resource&p=cerberusweb.core&f=images/wgm/logo.gif{/devblocks_url}?v={$smarty.const.APP_BUILD}">
{else}
<img src="{$logo_url}">
{/if}
</div>

<div class="block">
<form action="{devblocks_url}{/devblocks_url}" method="post" id="loginForm">
<h2>{$translate->_('header.signon')|capitalize}</h2>
<input type="hidden" name="c" value="iphone">
<input type="hidden" name="a" value="login">
<input type="hidden" name="a2" value="authenticate">
<input type="hidden" name="original_path" value="{$original_path}">
<input type="hidden" name="original_query" value="{$original_query}">
<table cellpadding="0" cellspacing="2">
{if isset($login_failed)}
<tr>
	<td></td>
	<td valign="middle" style="color:red;">Invalid Login</td>
</tr>
{/if}
<tr>
	<td align="right" valign="middle">E-mail:</td>
	<td><input type="text" name="email" size="25" id="loginForm_email" autocorrect="off" autocapitalize="off"></td>
</tr>
<tr>
	<td align="right" valign="middle">Password:</td>
	<td nowrap="nowrap">
		<input type="password" name="password" size="25" id="loginForm_password"/>
	</td>
</tr>
<tr>
	<td></td>
	<td><a href="{devblocks_url}c=login&a=forgot{/devblocks_url}">forgot your password?</a></td>
</tr>
</table>
<button type="submit">{$translate->_('header.signon')|capitalize}</button>
</form>
</div>

