<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title>Cerberus Helpdesk</title>

<meta name="viewport" content="width=320; initial-scale=1.0; maximum-scale=1.0; user-scalable=0;"/>
<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.3.2/jquery.min.js" type="text/javascript"></script>

{if !empty($page) && $page->isVisible()}
	{$page->drawResourceTags()}
{/if}

<script>{literal}
var DevblocksAppPath = '{/literal}{$smarty.const.DEVBLOCKS_WEBPATH}{literal}';
var activeWorkerId = {/literal}{$active_worker->id}{literal};
String.prototype.trim = function() {
	return this.replace(/^\s+|\s+$/g,"");
}

addEventListener('load', function() { setTimeout(hideAddressBar, 0); }, false);
function hideAddressBar() { window.scrollTo(0, 1); }


{/literal}
</script>

</head>
<body>

{if !empty($page) && $page->isVisible()}
	{$page->render()}
{else}
	{$translate->_('header.no_page')}
{/if}

<div style="visibility: hidden; height: 325px;"></div>

</body>
</html>

