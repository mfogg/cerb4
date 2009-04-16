<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title>Cerberus Helpdesk</title>

<meta name="viewport" content="width=320; initial-scale=1.0; maximum-scale=1.0; user-scalable=0;"/>
<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.3.2/jquery.min.js" type="text/javascript"></script>

{* 
<style type="text/css" media="screen">@import "{devblocks_url}c=resource&p=cerberusweb.iphone&f=scripts/iui/iui.css{/devblocks_url}";</style>
<script type="text/javascript" src="{devblocks_url}c=resource&p=cerberusweb.iphone&f=scripts/iui/iui.js{/devblocks_url}"></script>
*}

{if !empty($page) && $page->isVisible()}
	{$page->drawResourceTags()}
{/if}

<script>{literal}
var DevblocksAppPath = '{/literal}{$smarty.const.DEVBLOCKS_WEBPATH}{literal}';
String.prototype.trim = function() {
	return this.replace(/^\s+|\s+$/g,"");
}
{/literal}
</script>

</head>
<body>

{if !empty($page) && $page->isVisible()}
	{$page->render()}
{else}
	{$translate->_('header.no_page')}
{/if}

</body>
</html>

