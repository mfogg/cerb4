<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title>Cerberus Helpdesk</title>

<meta name="viewport" content="width=320; initial-scale=1.0; maximum-scale=1.0; user-scalable=0;"/>
<style type="text/css" media="screen">@import "{devblocks_url}c=resource&p=cerberusweb.iphone&f=scripts/iui/iui.css{/devblocks_url}";</style>
<script type="text/javascript" src="{devblocks_url}c=resource&p=cerberusweb.iphone&f=scripts/iui/iui.js{/devblocks_url}"></script>
{if !empty($page) && $page->isVisible()}
	{$page->drawResourceTags()}
{/if}

<script>{literal}
String.prototype.trim = function() {
	return this.replace(/^\s+|\s+$/g,"");
}



{/literal}
</script>

</head>
<body>

<div class="toolbar">
<h1 id="pageTitle"></h1>
<a id="backButton" class="button" href="#"></a>
<a class="button" href="#searchForm">Search</a>
</div>

{if !empty($page) && $page->isVisible()}
	{$page->render()}
{else}
	{$translate->_('header.no_page')}
{/if}

</body>
</html>

