<?php
$db = DevblocksPlatform::getDatabaseService();
$datadict = NewDataDictionary($db); /* @var $datadict ADODB_DataDict */ // ,'mysql' 

$tables = $datadict->MetaTables();
$tables = array_flip($tables);

// ===========================================================================
// Add namespaces to community tool properties and clean up unused entries

if(isset($tables['community_tool_property'])) {
	// Drop deprecated
	$db->Execute("DELETE FROM community_tool_property WHERE property_key = 'base_url'");
	$db->Execute("DELETE FROM community_tool_property WHERE property_key = 'theme'");
	$db->Execute("DELETE FROM community_tool_property WHERE property_key = 'kb_enabled'");
	$db->Execute("DELETE FROM community_tool_property WHERE property_key = 'fnr_sources'");
	
	// Update to new style property keys w/ namespaces
	$db->Execute("UPDATE community_tool_property SET property_key = 'common.logo_url' WHERE property_key = 'logo_url'");
	$db->Execute("UPDATE community_tool_property SET property_key = 'common.page_title' WHERE property_key = 'page_title'");
	$db->Execute("UPDATE community_tool_property SET property_key = 'common.style_css' WHERE property_key = 'style_css'");
	$db->Execute("UPDATE community_tool_property SET property_key = 'common.footer_html' WHERE property_key = 'footer_html'");
	$db->Execute("UPDATE community_tool_property SET property_key = 'common.allow_logins' WHERE property_key = 'allow_logins'");
	$db->Execute("UPDATE community_tool_property SET property_key = 'common.enabled_modules' WHERE property_key = 'enabled_modules'");

	$db->Execute("UPDATE community_tool_property SET property_key = 'announcements.rss' WHERE property_key = 'home_rss'");
	
	$db->Execute("UPDATE community_tool_property SET property_key = 'contact.captcha_enabled' WHERE property_key = 'captcha_enabled'");
	$db->Execute("UPDATE community_tool_property SET property_key = 'contact.allow_subjects' WHERE property_key = 'allow_subjects'");
	$db->Execute("UPDATE community_tool_property SET property_key = 'contact.situations' WHERE property_key = 'dispatch'");
	
	$db->Execute("UPDATE community_tool_property SET property_key = 'kb.roots' WHERE property_key = 'kb_roots'");
}

// ===========================================================================
// Add nicknames for community tool instances

$columns = $datadict->MetaColumns('community_tool');
$indexes = $datadict->MetaIndexes('community_tool',false);

if(!isset($columns['NAME'])) {
    $sql = $datadict->AddColumnSQL('community_tool', "name C(128) DEFAULT '' NOTNULL");
    $datadict->ExecuteSQLArray($sql);
	
	$db->Execute("UPDATE community_tool SET name = 'Support Center' WHERE name = '' AND extension_id = 'sc.tool'");
}

// ===========================================================================
// Convert standalone KB + CFB tools to SC instances w/ specific modules

if(isset($tables['community_tool'])) {
	// Load KB + CFB profiles
	$sql = "SELECT id,code,extension_id FROM community_tool WHERE extension_id IN ('support.tool','kb.tool')";
	$rs = $db->Execute($sql);
	
	while(!$rs->EOF) {
		$code = $rs->fields['code'];
		$tool_extension_id = $rs->fields['extension_id'];
		
		// Look up the existing properties for this tool
		$sql = sprintf("SELECT property_key, property_value FROM community_tool_property WHERE tool_code = '%s'",$code);
		$rs_props = $db->Execute($sql);
		
		$name = '';
		$props = array();

		// Create a hash of properties		
		while(!$rs_props->EOF) {
			$k = $rs_props->fields['property_key'];
			$v = $rs_props->fields['property_value'];
			$props[$k] = $v;
			$rs_props->MoveNext();
		}
		
		// Drop existing properies to replace
		$db->Execute(sprintf("DELETE FROM community_tool_property WHERE tool_code = '%s'",$code));
		
		// Override a few community tool properties to fine tune the migration
		switch($tool_extension_id) {
			case 'support.tool':
				$name = 'Contact Form';
				$props['common.allow_logins'] = '0';
				$props['common.enabled_modules'] = 'sc.controller.contact';
				break;
				
			case 'kb.tool':
				$name = 'Knowledgebase';
				$props['common.allow_logins'] = '0';
				$props['common.enabled_modules'] = 'cerberusweb.kb.sc.controller';
				unset($props['contact.captcha_enabled']);
				break;
		}

		// Insert the new properties
		if(is_array($props))
		foreach($props as $k => $v) {
			$sql = sprintf("INSERT IGNORE INTO community_tool_property (tool_code, property_key, property_value) ".
				"VALUES (%s, %s, %s)",
				$db->qstr($code),
				$db->qstr($k),
				$db->qstr($v)
			);
			$db->Execute($sql);
		}
		
		// Update extension_id to 'sc.tool' in old community_tool
		$db->Execute(sprintf("UPDATE community_tool SET name = %s, extension_id = 'sc.tool' WHERE code = %s", 
			$db->qstr($name),
			$db->qstr($code)
		));
		
		unset($props);
		
		$rs->MoveNext();
	}
}

// ===========================================================================
// Default enabled_modules property on sc.tool instances (migration)

if(isset($tables['community_tool'])) {
	$sql = "SELECT c.code, p.property_key FROM community_tool c LEFT JOIN community_tool_property p ON (c.code=p.tool_code AND p.property_key = 'common.enabled_modules') WHERE c.extension_id='sc.tool' AND p.property_key IS NULL";
	$rs = $db->Execute($sql);
	
	while(!$rs->EOF) {
		$code = $rs->fields['code'];
		$db->Execute(sprintf("INSERT INTO community_tool_property (tool_code, property_key, property_value) ".
			"VALUES (%s,%s,%s)",
			$db->qstr($code),
			$db->qstr('common.enabled_modules'),
			$db->qstr('sc.controller.home,sc.controller.announcements,cerberusweb.kb.sc.controller,sc.controller.contact,sc.controller.history,sc.controller.register,sc.controller.account')
		));
		$rs->MoveNext();
	}
}

// ===========================================================================
// Change 'community_tool_property' values to X (text) rather than B (blob)

if(isset($tables['community_tool_property'])) {
	$columns = $datadict->MetaColumns('community_tool_property');
	
	if(isset($columns['PROPERTY_VALUE'])) {
		if(0==strcasecmp('longblob',$columns['PROPERTY_VALUE']->type)) {
			$sql = sprintf("ALTER TABLE community_tool_property CHANGE COLUMN `property_value` `property_value` TEXT");
			$db->Execute($sql);
		}
	}
}

return TRUE;
