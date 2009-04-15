<?php
class UmScAccountController extends Extension_UmScController {
	
	function isVisible() {
		$umsession = $this->getSession();
		$active_user = $umsession->getProperty('sc_login', null);
		return !empty($active_user);
	}
	
	function writeResponse(DevblocksHttpResponse $response) {
		$tpl = DevblocksPlatform::getTemplateService();
		$tpl_path = dirname(dirname(dirname(dirname(__FILE__)))) . '/templates/';
		
		$umsession = $this->getSession();
		$active_user = $umsession->getProperty('sc_login', null);
		
		$address = DAO_Address::get($active_user->id);
		$tpl->assign('address',$address);
		
		$tpl->display("file:".$tpl_path."portal/sc/internal/account/index.tpl");
	}

	function saveAccountAction() {
		@$first_name = DevblocksPlatform::importGPC($_REQUEST['first_name'],'string','');
		@$last_name = DevblocksPlatform::importGPC($_REQUEST['last_name'],'string','');
		@$change_password = DevblocksPlatform::importGPC($_REQUEST['change_password'],'string','');
		@$change_password2 = DevblocksPlatform::importGPC($_REQUEST['change_password2'],'string','');
		
		$tpl = DevblocksPlatform::getTemplateService();
		$umsession = $this->getSession();
		$active_user = $umsession->getProperty('sc_login', null);
		
		if(!empty($active_user)) {
			$fields = array(
				DAO_Address::FIRST_NAME => $first_name,
				DAO_Address::LAST_NAME => $last_name
			);
			DAO_Address::update($active_user->id, $fields);
			$tpl->assign('account_success', true);
			
			if(!empty($change_password)) {
				if(0 == strcmp($change_password,$change_password2)) {
					DAO_AddressAuth::update(
						$active_user->id,
						array(
							DAO_AddressAuth::PASS => md5($change_password)
						)
					);
				} else {
					$tpl->assign('account_error', "The passwords you entered did not match.");
				}
			}
		}
		
		DevblocksPlatform::setHttpResponse(new DevblocksHttpResponse(array('portal',$this->getPortal(),'account')));
	}
	
}