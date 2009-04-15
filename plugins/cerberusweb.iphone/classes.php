<?php
/***********************************************************************
| Cerberus Helpdesk(tm) developed by WebGroup Media, LLC.
|-----------------------------------------------------------------------
| All source code & content (c) Copyright 2007, WebGroup Media LLC
|   unless specifically noted otherwise.
|
| This source code is released under the Cerberus Public License.
| The latest version of this license can be found here:
| http://www.cerberusweb.com/license.php
|
| By using this software, you acknowledge having read this license
| and agree to be bound thereby.
| ______________________________________________________________________
|	http://www.cerberusweb.com	  http://www.webgroupmedia.com/
***********************************************************************/
/*
 * IMPORTANT LICENSING NOTE from your friends on the Cerberus Helpdesk Team
 * 
 * Sure, it would be so easy to just cheat and edit this file to use the 
 * software without paying for it.  But we trust you anyway.  In fact, we're 
 * writing this software for you! 
 * 
 * Quality software backed by a dedicated team takes money to develop.  We 
 * don't want to be out of the office bagging groceries when you call up 
 * needing a helping hand.  We'd rather spend our free time coding your 
 * feature requests than mowing the neighbors' lawns for rent money. 
 * 
 * We've never believed in encoding our source code out of paranoia over not 
 * getting paid.  We want you to have the full source code and be able to 
 * make the tweaks your organization requires to get more done -- despite 
 * having less of everything than you might need (time, people, money, 
 * energy).  We shouldn't be your bottleneck.
 * 
 * We've been building our expertise with this project since January 2002.  We 
 * promise spending a couple bucks [Euro, Yuan, Rupees, Galactic Credits] to 
 * let us take over your shared e-mail headache is a worthwhile investment.  
 * It will give you a sense of control over your in-box that you probably 
 * haven't had since spammers found you in a game of "E-mail Address 
 * Battleship".  Miss. Miss. You sunk my in-box!
 * 
 * A legitimate license entitles you to support, access to the developer 
 * mailing list, the ability to participate in betas and the warm fuzzy 
 * feeling of feeding a couple obsessed developers who want to help you get 
 * more done than 'the other guy'.
 *
 * - Jeff Standen, Mike Fogg, Brenan Cavish, Darren Sugita, Dan Hildebrandt
 * 		and Joe Geck.
 *   WEBGROUP MEDIA LLC. - Developers of Cerberus Helpdesk
 */
class ChIPhonePlugin extends DevblocksPlugin {
};

class IPhoneController extends DevblocksControllerExtension {
    const ID = 'cerberusweb.controller.iphone';
	
    public function __construct($manifest) {
        parent::__construct($manifest);
    }
    
	/**
	 * Enter description here...
	 *
	 * @param string $uri
	 * @return string $id
	 */
	public function _getPageIdByUri($uri) {
        $pages = DevblocksPlatform::getExtensions('cerberusweb.iphone.page', false);
        foreach($pages as $manifest) { /* @var $manifest DevblocksExtensionManifest */
            if(0 == strcasecmp($uri,$manifest->params['uri'])) {
                return $manifest->id;
            }
        }
        return NULL;
	}    
    
	public function handleRequest(DevblocksHttpRequest $request) { /* @var $request DevblocksHttpRequest */
		array_push($request->path, $request->query['a2']);
		$path = $request->path;
		$prefixUri = array_shift($path);		// $uri should be "iphone"
		$controller = array_shift($path);	// sub controller to take (login, display, etc)


        $page_id = $this->_getPageIdByUri($controller);

        $pages = DevblocksPlatform::getExtensions('cerberusweb.iphone.page', true);
        @$page = $pages[$page_id]; /* @var $page CerberusPageExtension */

		if(empty($page)) {
			switch($controller) {
//				case "portal":
//					die(); // 404
//					break;
//	        		
				default:
					return; // default page
					break;
			}
		}
		//@$action = array_shift($path) . 'Action';
		@$action_post_var = DevblocksPlatform::importGPC($_POST['a2'],'string', '');
		if($action_post_var == null) {
			@$action_post_var = array_shift($path);
		}
		
		@$action = $action_post_var . 'Action';
		
	    switch($action) {
	        case NULL:
	            // [TODO] Index/page render
	            break;
	            
	        default:
			    // Default action, call arg as a method suffixed with Action
			    if($page->isVisible()) {
					if(method_exists($page,$action)) {
						call_user_func(array(&$page, $action)); // [TODO] Pass HttpRequest as arg?
					}
				} else {
					// if Ajax [TODO] percolate isAjax from platform to handleRequest
					// die("Access denied.  Session expired?");
				}

	            break;
	    }		
	}
	
	public function writeResponse(DevblocksHttpResponse $response) { /* @var $response DevblocksHttpResponse */
	    $path = $response->path;
	    $uri_prefix = array_shift($path); // should be iphone
	    
		// [JAS]: Ajax? // [TODO] Explore outputting whitespace here for Safari
//	    if(empty($path))
//			return;

		$tpl = DevblocksPlatform::getTemplateService();
		$session = DevblocksPlatform::getSessionService();
		$settings = CerberusSettings::getInstance();
		$translate = DevblocksPlatform::getTranslationService();
		$visit = $session->getVisit();

		$controller = array_shift($path);
		$pages = DevblocksPlatform::getExtensions('cerberusweb.iphone.page', true);

		// Default page [TODO] This is supposed to come from framework.config.php
		if(empty($controller)) 
			$controller = 'main';

	    // [JAS]: Require us to always be logged in for Cerberus pages
	    // [TODO] This should probably consult with the page itself for ::authenticated()
		if(empty($visit))
			$controller = 'login';

	    $page_id = $this->_getPageIdByUri($controller); /* @var $page CerberusPageExtension */

	    @$page = $pages[$page_id];
        if(empty($page)) return; // 404
		// [TODO] Reimplement
		if(!empty($visit) && !is_null($visit->getWorker())) {
		    DAO_Worker::logActivity($visit->getWorker()->id, $page->getActivity());
		}
		
		// [JAS]: Listeners (Step-by-step guided tour, etc.)
	    $listenerManifests = DevblocksPlatform::getExtensions('devblocks.listener.http');
	    foreach($listenerManifests as $listenerManifest) { /* @var $listenerManifest DevblocksExtensionManifest */
	         $inst = $listenerManifest->createInstance(); /* @var $inst DevblocksHttpRequestListenerExtension */
	         $inst->run($response, $tpl);
	    }
		
		// [JAS]: Pre-translate any dynamic strings
        $common_translated = array();
        if(!empty($visit) && !is_null($visit->getWorker()))
            $common_translated['header_signed_in'] = vsprintf($translate->_('header.signed_in'), array('<b>'.$visit->getWorker()->getName().'</b>'));
        $tpl->assign('common_translated', $common_translated);
		
        // [JAS]: Variables provided to all page templates
		$tpl->assign('settings', $settings);
		$tpl->assign('session', $_SESSION);
		$tpl->assign('translate', $translate);
		$tpl->assign('visit', $visit);
		$tpl->assign('license',CerberusLicense::getInstance());
		
	    $active_worker = CerberusApplication::getActiveWorker();
	    $tpl->assign('active_worker', $active_worker);
	
	    if(!empty($active_worker)) {
	    	$active_worker_memberships = $active_worker->getMemberships();
	    	$tpl->assign('active_worker_memberships', $active_worker_memberships);
	    }
		
		$tpl->assign('pages',$pages);		
		$tpl->assign('page',$page);

		$tpl->assign('response_uri', implode('/', $response->path));
		$tpl_path = DEVBLOCKS_PLUGIN_PATH . 'cerberusweb.iphone/templates/';
		$tpl->assign('core_tpl', DEVBLOCKS_PLUGIN_PATH . 'cerberusweb.core/templates/');
		
		// Timings
		$tpl->assign('render_time', (microtime(true) - DevblocksPlatform::getStartTime()));
		if(function_exists('memory_get_usage') && function_exists('memory_get_peak_usage')) {
			$tpl->assign('render_memory', memory_get_usage() - DevblocksPlatform::getStartMemory());
			$tpl->assign('render_peak_memory', memory_get_peak_usage() - DevblocksPlatform::getStartPeakMemory());
		}
		$tpl->display($tpl_path.'border.tpl');
	}
};

class C4_IPhoneTicketView extends C4_TicketView {
	
	function render() {
		$tpl = DevblocksPlatform::getTemplateService();
		$tpl->assign('id', $this->id);
		$view_path = DEVBLOCKS_PLUGIN_PATH . 'cerberusweb.iphone/templates/tickets/';
		$tpl->assign('view_path_mobile',$view_path_mobile);
		$tpl->assign('view', $this);

		$visit = CerberusApplication::getVisit();

		$results = self::getData();
		$tpl->assign('results', $results);
		
		@$ids = array_keys($results[0]);
		
		$workers = DAO_Worker::getAll();
		$tpl->assign('workers', $workers);

		$teams = DAO_Group::getAll();
		$tpl->assign('teams', $teams);

		$buckets = DAO_Bucket::getAll();
		$tpl->assign('buckets', $buckets);

		$team_categories = DAO_Bucket::getTeams();
		$tpl->assign('team_categories', $team_categories);

		// [TODO] Is this used here
		$ticket_fields = DAO_CustomField::getBySource(ChCustomFieldSource_Ticket::ID);
		$tpl->assign('ticket_fields', $ticket_fields);
		
		// Undo?
		// [TODO] Is this used here
		$last_action = C4_TicketView::getLastAction($this->id);
		$tpl->assign('last_action', $last_action);
		if(!empty($last_action) && !is_null($last_action->ticket_ids)) {
			$tpl->assign('last_action_count', count($last_action->ticket_ids));
		}

		$tpl->cache_lifetime = "0";
		$tpl->assign('view_fields', $this->getColumns());
		
		$tpl->display('file:' . $view_path . 'ticket_view.tpl');
	}
	
};

class CerberusIPhonePageExtension extends DevblocksExtension {
	function __construct($manifest) {
		$this->DevblocksExtension($manifest,1);
	}
	
	function isVisible() { return true; }
	function render() { }
	
	/**
	 * @return Model_Activity
	 */
	public function getActivity() {
        return new Model_Activity('activity.default');
	}
}

//class ChIPhoneDisplayPage  extends CerberusIPhonePageExtension  {
//    
//	function __construct($manifest) {
//		parent::__construct($manifest);
//	}
//	
//	function isVisible() {
//		return true;
//	}
//	
//	function render() {
//		$tpl = DevblocksPlatform::getTemplateService();
//		$response = DevblocksPlatform::getHttpResponse();
//		@$ticket_id = $response->path[2];
//		@$page_type = DevblocksPlatform::importGPC($_REQUEST['page_type'],'string', 'reply');
//		$message_id = $response->path[3];
//		
//		if (empty($ticket_id)) {
//			$session = DevblocksPlatform::getSessionService();
//			$visit = $session->getVisit();
//			return;
//		}
//		
//		if (!is_numeric($ticket_id)) {
//			$ticket_id = DAO_Ticket::getTicketIdByMask($ticket_id);
//		}
//		
//		$ticket = DAO_Ticket::getTicket($ticket_id);
//		
//		$tpl->assign('ticket', $ticket);
//		$tpl->assign('ticket_id', $ticket_id);
//		$tpl->assign('message_id', $message_id);
//		$tpl->assign('page_type', $page_type);
//
//		if (0 == strcasecmp($message_id, 'full')) {
//			$tpl->display('file:' . dirname(__FILE__) . '/templates/display.tpl');
//		} else {
//			$message = DAO_Ticket::getMessage($message_id);
//			if (empty($message))
//				$message = array_pop($ticket->getMessages());
//			$tpl->assign('message', $message);
//			$tpl->display('file:' . dirname(__FILE__) . '/templates/display_brief.tpl');
//		}
//		
//	}
//	
//	function replyAction() {
//		@$ticket_id = DevblocksPlatform::importGPC($_REQUEST['ticket_id'],'integer',0);
//
//		@$message_id = DevblocksPlatform::importGPC($_REQUEST['message_id'],'integer');
//		@$content = DevblocksPlatform::importGPC($_REQUEST['content'],'content');
//		@$to = DevblocksPlatform::importGPC($_REQUEST['to'],'string'); // used by forward
//		@$page_type = DevblocksPlatform::importGPC($_REQUEST['page_type'],'string');
//		
//		$worker = CerberusApplication::getActiveWorker();
//		
//		if($page_type == 'comment') {
//			$properties = array(
//				DAO_MessageNote::MESSAGE_ID => $message_id,
//				DAO_MessageNote::CREATED => time(),
//				DAO_MessageNote::WORKER_ID => @$worker->id,
//				DAO_MessageNote::CONTENT => $content,
//			);
//			$note_id = DAO_MessageNote::create($properties);
//		}
//		else {
//			$properties = array(
//				'message_id' => $message_id,
//				'content' => $content,
//				'agent_id' => @$worker->id,
//				'to' => $to
//		    );
//			CerberusMail::sendTicketMessage($properties);
//		}
//		
//		DevblocksPlatform::redirect(new DevblocksHttpResponse(array('iphone','display', $ticket_id)));
//	}
//	
//};

class ChIPhoneLoginPage  extends CerberusIPhonePageExtension  {
    const KEY_FORGOT_EMAIL = 'login.recover.email';
    const KEY_FORGOT_SENTCODE = 'login.recover.sentcode';
    const KEY_FORGOT_CODE = 'login.recover.code';
    
	function __construct($manifest) {
		parent::__construct($manifest);
	}
	
	function isVisible() {
		return true;
	}
	
	function render() {
		// draws HTML form of controls needed for login information
		$tpl = DevblocksPlatform::getTemplateService();
		$tpl->cache_lifetime = "0";
		
		// add translations for calls from classes that aren't Page Extensions (iphone plugin, specifically)
		$translate = DevblocksPlatform::getTranslationService();
		$tpl->assign('translate', $translate);
		
		$request = DevblocksPlatform::getHttpRequest();
		$prefix = '';
		$query_str = '';
		foreach($request->query as $key=>$val) {
			$query_str .= $prefix . $key . '=' . $val;
			$prefix = '&';
		}
		
		//$url_service = DevblocksPlatform::getUrlService();
		//$original_url = $url_service->writeDevblocksHttpIO($request);
		
		//$tpl->assign('original_url', $original_url);
		$original_path = (sizeof($request->path)==0) ? 'login' : implode(',',$request->path);
		
		$tpl->assign('original_path', $original_path);
		$tpl->assign('original_query', $query_str);
		
		$tpl->display('file:' . dirname(__FILE__) . '/templates/login/login_form_default.tpl');
	}
	
	function authenticateAction() {
		//echo "authing!";
		@$email = DevblocksPlatform::importGPC($_POST['email']);
		@$password = DevblocksPlatform::importGPC($_POST['password']);
	    
		// pull auth info out of $_POST, check it, return user_id or false
		$worker = DAO_Worker::login($email, $password);
		//echo $email. '-'.$password;print_r($worker);exit();
		if(!is_null($worker)) {
			$session = DevblocksPlatform::getSessionService();
			$visit = new CerberusVisit();
			$visit->setWorker($worker);

			$session->setVisit($visit);
			
			//$devblocks_response = new DevblocksHttpResponse(array('iphone','mytickets'));
			$devblocks_response = new DevblocksHttpResponse(array('iphone','tickets'));
			
		} else {
			$devblocks_response = new DevblocksHttpResponse(array('iphone', 'login'));
			//return false;
		}
		DevblocksPlatform::redirect($devblocks_response);
	}
};


class ChIPhoneMainPage  extends CerberusIPhonePageExtension  {
	function __construct($manifest) {
		parent::__construct($manifest);
	}
	
	function isVisible() {
		return true;
	}
	
	function drawResourceTags() {
		echo "<script></script>";
	}
	
	function render() {
		//echo "<ul title=\"Cerb4\" selected=\"true\"><li href=\"/\">whatever</li></ul>";
		//return;
		
		// draws HTML form of controls needed for login information
		$tpl = DevblocksPlatform::getTemplateService();
		$tpl->cache_lifetime = "0";
		
		// add translations for calls from classes that aren't Page Extensions (iphone plugin, specifically)
		//$translate = DevblocksPlatform::getTranslationService();
		//$tpl->assign('translate', $translate);

		$tpl->display('file:' . dirname(__FILE__) . '/templates/main.tpl');
	}
	
	function showNotificationsAction() {
		
	}
	
	function showWorkspacesAction() {
		$tpl = DevblocksPlatform::getTemplateService();
		$tpl->cache_lifetime = "0";
		
		$workspaces = DAO_WorkerWorkspaceList::getWorkspaces($active_worker->id);
		

//		print_r($workspaces);


		$tpl->assign('workspaces', $workspaces);
		$tpl->display('file:' . dirname(__FILE__) . '/templates/tickets/workspaces.tpl');
		
	}
	
	function showWorkspaceViewsAction() {
		$current_workspace = DevblocksPlatform::importGPC($_REQUEST['workspace'],'string','');

		$db = DevblocksPlatform::getDatabaseService();

		$active_worker = CerberusApplication::getActiveWorker();

		$tpl = DevblocksPlatform::getTemplateService();
		$tpl->cache_lifetime = "0";
		
//		// Fix a bad/old cache
//		if(!empty($current_workspace) && false === array_search($current_workspace,$workspaces))
//			$current_workspace = '';
//		
//		$views = array();
//			
//		if(empty($current_workspace) && !empty($workspaces)) { // custom dashboards
//			$current_workspace = reset($workspaces);
//		}
		
		if(!empty($current_workspace)) {
			
			$lists = DAO_WorkerWorkspaceList::getWhere(sprintf("%s = %d AND %s = %s",
				DAO_WorkerWorkspaceList::WORKER_ID,
				$active_worker->id,
				DAO_WorkerWorkspaceList::WORKSPACE,
				$db->qstr($current_workspace)
			));

			$tpl->assign('workspace_views', $lists);
			$tpl->assign('current_workspace', $current_workspace);
			$tpl->display('file:' . dirname(__FILE__) . '/templates/tickets/workspace_views.tpl');

//	        // Loop through list schemas
//			if(is_array($lists) && !empty($lists))
//			foreach($lists as $list) { /* @var $list Model_WorkerWorkspaceList */
//				
//			}
		}
		
		
	}
	
	function showViewAction() {
		
		$view_id = DevblocksPlatform::importGPC($_REQUEST['view_id'],'integer',0);
		
		$tpl = DevblocksPlatform::getTemplateService();
		$tpl->cache_lifetime = "0";
		
		$list = DAO_WorkerWorkspaceList::get($view_id);
//		print_r($list);
		$view_id = 'cust_'.$list->id;
		if(null == ($view = C4_AbstractViewLoader::getView('',$view_id)) || 1==1) {
			$list_view = $list->list_view; /* @var $list_view Model_WorkerWorkspaceListView */
			
			// Load the workspace sources to map to view renderer
	        $source_manifests = DevblocksPlatform::getExtensions(Extension_WorkspaceSource::EXTENSION_POINT, false);
			
			
			// Make sure we can find the workspace source (plugin not disabled)
			if(!isset($source_manifests[$list->source_extension])
				|| null == ($workspace_source = $source_manifests[$list->source_extension])
				|| !isset($workspace_source->params['view_class'])) {print_r($list);
				echo "there is a problem with the plugin required for this view";
				return;
			}
			
			// Make sure our workspace source has a valid renderer class
			$view_class = $workspace_source->params['view_class'];
//			if(!class_exists($view_class))
//				continue;
//				echo "hi";print_r($workspace_source);
			$view = new C4_IPhoneTicketView;
			$view->id = $view_id;
			$view->name = $list_view->title;
			$view->renderLimit = 10;
			$view->renderPage = 0;
			$view->view_columns = $list_view->columns;
			$view->params = $list_view->params;
			//C4_AbstractViewLoader::setView($view_id, $view);
			
			
		}
		//print_r($view);
		$tpl->assign('view', $view);

		$tpl->display('file:' . dirname(__FILE__) . '/templates/tickets.tpl');
		
	}
	
//	function showDisplayTicket() {
//		
//		@$id = DevblocksPlatform::importGPC($_REQUEST['ticket_id'],'integer');
//		
//		@$active_worker = CerberusApplication::getActiveWorker();
//		
//		$tpl = DevblocksPlatform::getTemplateService();
//		$tpl->assign('path', $this->_TPL_PATH);
//		
//		$ticket = DAO_Ticket::getTicket($id);
//		$tpl->assign('ticket', $ticket);
//		$tpl->assign('requesters', $ticket->getRequesters());
//		
//		arsort($messages);
//				
//		$tpl->assign('latest_message_id',key($messages));
//		$tpl->assign('messages', $messages);
//		
//				// Thread comments and messages on the same level
//		$convo_timeline = array();
//
//		// Track senders and their orgs
//		$message_senders = array();
//		$message_sender_orgs = array();
//
//		// Loop messages
//		foreach($messages as $message_id => $message) { /* @var $message CerberusMessage */
//			$key = $message->created_date . '_m' . $message_id;
//			// build a chrono index of messages
//			$convo_timeline[$key] = array('m',$message_id);
//			
//			// If we haven't cached this sender address yet
//			if(!isset($message_senders[$message->address_id])) {
//				if(null != ($sender_addy = DAO_Address::get($message->address_id))) {
//					$message_senders[$sender_addy->id] = $sender_addy;	
//
//					// If we haven't cached this sender org yet
//					if(!isset($message_sender_orgs[$sender_addy->contact_org_id])) {
//						if(null != ($sender_org = DAO_ContactOrg::get($sender_addy->contact_org_id))) {
//							$message_sender_orgs[$sender_org->id] = $sender_org;
//						}
//					}
//				}
//			}
//		}
//		
//		$tpl->assign('message_senders', $message_senders);
//		$tpl->assign('message_sender_orgs', $message_sender_orgs);
//		
//		@$mail_inline_comments = DAO_WorkerPref::get($active_worker->id,'mail_inline_comments',1);
//		
//		if($mail_inline_comments) { // if inline comments are enabled
//			$comments = DAO_TicketComment::getByTicketId($id);
//			arsort($comments);
//			$tpl->assign('comments', $comments);
//			
//			// build a chrono index of comments
//			foreach($comments as $comment_id => $comment) { /* @var $comment Model_TicketComment */
//				$key = $comment->created . '_c' . $comment_id;
//				$convo_timeline[$key] = array('c',$comment_id);
//			}
//		}
//		
//		// sort the timeline
//		if(!$expand_all) {
//			krsort($convo_timeline);
//		} else {
//			ksort($convo_timeline);
//		}
//		$tpl->assign('convo_timeline', $convo_timeline);
//		
////		// Message toolbar items
////		$messageToolbarItems = DevblocksPlatform::getExtensions('cerberusweb.message.toolbaritem', true);
////		if(!empty($messageToolbarItems))
////			$tpl->assign('message_toolbaritems', $messageToolbarItems);
//		
//		// Workers
//		$workers = DAO_Worker::getAll();
//		$tpl->assign('workers', $workers);
//		
//		$tpl->register_modifier('makehrefs', array('CerberusUtils', 'smarty_modifier_makehrefs')); 
//		
//		$tpl->display('file:' . dirname(__FILE__) . '/templates/tickets/display.tpl');
//		
//	}
	
	function showWorkflow() {
		
	}
	
	function showOverview() {
		
	}
};



class ChIPhoneDisplayPage  extends CerberusIPhonePageExtension  {
	function __construct($manifest) {
		parent::__construct($manifest);
	}
	
	function isVisible() {
		return true;
	}
	
	function drawResourceTags() {
		echo "<script src=\"http://ajax.googleapis.com/ajax/libs/jquery/1.3.2/jquery.min.js\" type=\"text/javascript\"></script>\n";


		$tpl = DevblocksPlatform::getTemplateService();

		$content = "c=resource&p=cerberusweb.iphone&f=styles/cerberus/c4_iphone_display.css";
		$params=array();
		$resource_path = smarty_block_devblocks_url($params, $content, $tpl);
		
		echo "<style type=\"text/css\" media=\"screen\">@import \"".$resource_path."\";</style>\n";
		
		$content = "c=resource&p=cerberusweb.iphone&f=scripts/cerberus/c4_iphone_display.js";
		$params=array();
		$resource_path = smarty_block_devblocks_url($params, $content, $tpl);
		
		echo "<script type=\"text/javascript\" src=\"".$resource_path."\"></script>\n";
		
	}
	
	
	function render() {
		//echo "<ul title=\"Cerb4\" selected=\"true\"><li href=\"/\">whatever</li></ul>";
		//return;
		
		// draws HTML form of controls needed for login information
		$tpl = DevblocksPlatform::getTemplateService();
		$tpl->cache_lifetime = "0";
		
		// add translations for calls from classes that aren't Page Extensions (iphone plugin, specifically)
		//$translate = DevblocksPlatform::getTranslationService();
		//$tpl->assign('translate', $translate);
		
		$web_path =  DevblocksEngine::getWebPath();
		//echo $web_path;
		$mask = substr(strrchr($web_path, "/"), 1);
		$id = DAO_Ticket::getTicketIdByMask($mask);
		
		
		//echo substr($web_path, strrchr($web_path, "/"));
		
		
			
		//@$id = DevblocksPlatform::importGPC($_REQUEST['ticket_id'],'integer');
		
		@$active_worker = CerberusApplication::getActiveWorker();
		
		$tpl = DevblocksPlatform::getTemplateService();
		$tpl->assign('path', dirname(__FILE__). "/templates");

		$ticket = DAO_Ticket::getTicket($id);
		$tpl->assign('ticket', $ticket);
		$tpl->assign('requesters', $ticket->getRequesters());
		
		$messages = $ticket->getMessages();
		
		arsort($messages);
				
		$tpl->assign('latest_message_id',key($messages));
		$tpl->assign('messages', $messages);
		
				// Thread comments and messages on the same level
		$convo_timeline = array();

		// Track senders and their orgs
		$message_senders = array();
		$message_sender_orgs = array();

		// Loop messages
		foreach($messages as $message_id => $message) { /* @var $message CerberusMessage */
			$key = $message->created_date . '_m' . $message_id;
			// build a chrono index of messages
			$convo_timeline[$key] = array('m',$message_id);
			
			// If we haven't cached this sender address yet
			if(!isset($message_senders[$message->address_id])) {
				if(null != ($sender_addy = DAO_Address::get($message->address_id))) {
					$message_senders[$sender_addy->id] = $sender_addy;	

					// If we haven't cached this sender org yet
					if(!isset($message_sender_orgs[$sender_addy->contact_org_id])) {
						if(null != ($sender_org = DAO_ContactOrg::get($sender_addy->contact_org_id))) {
							$message_sender_orgs[$sender_org->id] = $sender_org;
						}
					}
				}
			}
		}
		
		$tpl->assign('message_senders', $message_senders);
		$tpl->assign('message_sender_orgs', $message_sender_orgs);
		
		@$mail_inline_comments = DAO_WorkerPref::get($active_worker->id,'mail_inline_comments',1);
		
		if($mail_inline_comments) { // if inline comments are enabled
			$comments = DAO_TicketComment::getByTicketId($id);
			arsort($comments);
			$tpl->assign('comments', $comments);
			
			// build a chrono index of comments
			foreach($comments as $comment_id => $comment) { /* @var $comment Model_TicketComment */
				$key = $comment->created . '_c' . $comment_id;
				$convo_timeline[$key] = array('c',$comment_id);
			}
		}
		
		// sort the timeline
		if(!$expand_all) {
			krsort($convo_timeline);
		} else {
			ksort($convo_timeline);
		}
		$tpl->assign('convo_timeline', $convo_timeline);
		
//		// Message toolbar items
//		$messageToolbarItems = DevblocksPlatform::getExtensions('cerberusweb.message.toolbaritem', true);
//		if(!empty($messageToolbarItems))
//			$tpl->assign('message_toolbaritems', $messageToolbarItems);
		
		// Workers
		$workers = DAO_Worker::getAll();
		$tpl->assign('workers', $workers);
		
		$tpl->register_modifier('makehrefs', array('CerberusUtils', 'smarty_modifier_makehrefs')); 
		
		
		$tpl->display('file:' . dirname(__FILE__) . '/templates/tickets/display.tpl');

		
		
		
		
		//$tpl->display('file:' . dirname(__FILE__) . '/templates/main.tpl');
		
	}

	
	function retrieveMessageAction() {
		//echo "This is my message body!!!";
		
		@$id = DevblocksPlatform::importGPC($_REQUEST['msgid']); // message id
		
		$tpl = DevblocksPlatform::getTemplateService();
		$tpl->cache_lifetime = "0";
		
		
		//$tpl->assign('path', dirname(__FILE__). "/templates");
		$tpl_path = DEVBLOCKS_PLUGIN_PATH . 'cerberusweb.iphone/templates/';
		
//		$tpl->assign('path', $this->_TPL_PATH);

//		$message = DAO_Ticket::getMessage($id);
//		$tpl->assign('message', $message);
//		$tpl->assign('message_id', $message->id);
		
		$content = DAO_MessageContent::get($id);
		$tpl->assign('content', $content);
			
//		$notes = DAO_MessageNote::getByTicketId($message->ticket_id);
//		$message_notes = array();
//		// Index notes by message id
//		if(is_array($notes))
//		foreach($notes as $note) {
//			if(!isset($message_notes[$note->message_id]))
//				$message_notes[$note->message_id] = array();
//			$message_notes[$note->message_id][$note->id] = $note;
//		}
//		$tpl->assign('message_notes', $message_notes);

		
		$tpl->assign('expanded', (empty($hide) ? true : false));
		
		$tpl->register_modifier('makehrefs', array('CerberusUtils', 'smarty_modifier_makehrefs')); 
		$tpl->display('file:' . $tpl_path . 'tickets/message_content.tpl');
		
	}
	
	function showDisplayTicket() {
			
	}

};



class ChIPhoneTicketsPage extends CerberusIPhonePageExtension  {
    
	function __construct($manifest) {
		parent::__construct($manifest);
	}
	
	function isVisible() {
		return true;
	}
	
	function render() {
		$tpl = DevblocksPlatform::getTemplateService();
		$active_worker = CerberusApplication::getActiveWorker();
		$memberships = $active_worker->getMemberships();
		
		$response = DevblocksPlatform::getHttpResponse();
		@$section = $response->path[1];
		
		//print_r($_REQUEST);exit();
		//@$page = DevblocksPlatform::importGPC($_GET['password']);
		@$page = DevblocksPlatform::importGPC($_REQUEST['page'],'integer');
		if($page==NULL) $page=0;
		
		if(isset($_POST['a2'])) {
			@$section = $_POST['a2'];
		}
		else {
			@$section = $response->path[2];	
		}
		
		//print_r($section);
		//echo $section;
		switch($section) {
			case 'search':
				$title = 'Search';
				$query = $_POST['query'];
				if($query && false===strpos($query,'*'))
					$query = '*' . $query . '*';
				
				if(!is_null($query)) {
					$params = array();
					$type = $_POST['type'];
					switch($type) {
			            case "mask":
			                $params[SearchFields_Ticket::TICKET_MASK] = new DevblocksSearchCriteria(SearchFields_Ticket::TICKET_MASK,DevblocksSearchCriteria::OPER_LIKE,strtoupper($query));
			                break;
			                
			            case "sender":
			                $params[SearchFields_Ticket::TICKET_FIRST_WROTE] = new DevblocksSearchCriteria(SearchFields_Ticket::TICKET_FIRST_WROTE,DevblocksSearchCriteria::OPER_LIKE,strtolower($query));               
			                break;
			                
			            case "subject":
			                $params[SearchFields_Ticket::TICKET_SUBJECT] = new DevblocksSearchCriteria(SearchFields_Ticket::TICKET_SUBJECT,DevblocksSearchCriteria::OPER_LIKE,$query);               
			                break;
			                
			            case "content":
			                $params[SearchFields_Ticket::TICKET_MESSAGE_CONTENT] = new DevblocksSearchCriteria(SearchFields_Ticket::TICKET_MESSAGE_CONTENT,DevblocksSearchCriteria::OPER_LIKE,$query);               
			                break;
					}
				}
				else {
					//show the search form because no search has been submitted
					$tpl->display('file:' . dirname(__FILE__) . '/templates/tickets/search.tpl');
					return;
				}
			break;
            case 'sidebar':
            			
				$groups = DAO_Group::getAll();
				$tpl->assign('groups', $groups);
				
				$group_buckets = DAO_Bucket::getTeams();
				$tpl->assign('group_buckets', $group_buckets);
				
				$workers = DAO_Worker::getAll();
				$tpl->assign('workers', $workers);
				
				$group_counts = DAO_Overview::getGroupTotals();
				$tpl->assign('group_counts', $group_counts);
				
				$waiting_counts = DAO_Overview::getWaitingTotals();
				$tpl->assign('waiting_counts', $waiting_counts);
				
				$worker_counts = DAO_Overview::getWorkerTotals();
				$tpl->assign('worker_counts', $worker_counts);
				
            	$tpl->display('file:' . dirname(__FILE__) . '/templates/tickets/sidebar.tpl');
            	return;
           	break;
			case 'overview':
			default:
				
				$workers = DAO_Worker::getAll();						
				$group_buckets = DAO_Bucket::getTeams();
				$groups = DAO_Group::getAll();
				@$filter = $response->path[3];	
				switch($filter) {
					case 'group':
						@$filter_group_id = $response->path[4];
						
						$params = array(
							SearchFields_Ticket::TICKET_CLOSED => new DevblocksSearchCriteria(SearchFields_Ticket::TICKET_CLOSED,'=',CerberusTicketStatus::OPEN),
							SearchFields_Ticket::TICKET_WAITING => new DevblocksSearchCriteria(SearchFields_Ticket::TICKET_WAITING,'=',0),
							SearchFields_Ticket::TICKET_NEXT_WORKER_ID => new DevblocksSearchCriteria(SearchFields_Ticket::TICKET_NEXT_WORKER_ID,'=',0),
						);
						
						if(!is_null($filter_group_id) && isset($groups[$filter_group_id])) {
							$tpl->assign('filter_group_id', $filter_group_id);
							$title = $groups[$filter_group_id]->name;
							$params[SearchFields_Ticket::TEAM_ID] = new DevblocksSearchCriteria(SearchFields_Ticket::TEAM_ID,'=',$filter_group_id);
							
							@$filter_bucket_id = $response->path[5];
							if(!is_null($filter_bucket_id)) {
								$tpl->assign('filter_bucket_id', $filter_bucket_id);
								@$title .= ': '.
									(($filter_bucket_id == 0) ? 'Inbox' : $group_buckets[$filter_group_id][$filter_bucket_id]->name);
								$params[SearchFields_Ticket::TICKET_CATEGORY_ID] = new DevblocksSearchCriteria(SearchFields_Ticket::TICKET_CATEGORY_ID,'=',$filter_bucket_id);
							} else {
								@$title .= ' (Spam Filtered)';
								$params[SearchFields_Ticket::TICKET_SPAM_SCORE] = new DevblocksSearchCriteria(SearchFields_Ticket::TICKET_SPAM_SCORE,'<=','0.9000');								
							}
						}

						break;
						
					case 'waiting':
						@$filter_waiting_id = $response->path[4];
						
						$params = array(
							SearchFields_Ticket::TICKET_CLOSED => new DevblocksSearchCriteria(SearchFields_Ticket::TICKET_CLOSED,'=',CerberusTicketStatus::OPEN),
							SearchFields_Ticket::TICKET_WAITING => new DevblocksSearchCriteria(SearchFields_Ticket::TICKET_WAITING,'=',1),
						);
						
						if(!is_null($filter_waiting_id) && isset($groups[$filter_waiting_id])) {
							$tpl->assign('filter_waiting_id', $filter_waiting_id);
							$title = '[Waiting] ' . $groups[$filter_waiting_id]->name;
							$params[SearchFields_Ticket::TEAM_ID] = new DevblocksSearchCriteria(SearchFields_Ticket::TEAM_ID,'=',$filter_waiting_id);
							
							@$filter_bucket_id = $response->path[5];
							if(!is_null($filter_bucket_id)) {
								$tpl->assign('filter_bucket_id', $filter_bucket_id);
								@$title .= ': '.
									(($filter_bucket_id == 0) ? 'Inbox' : $group_buckets[$filter_waiting_id][$filter_bucket_id]->name);
								$params[SearchFields_Ticket::TICKET_CATEGORY_ID] = new DevblocksSearchCriteria(SearchFields_Ticket::TICKET_CATEGORY_ID,'=',$filter_bucket_id);
							}
						}

						break;
						
					case 'worker':
						@$filter_worker_id = $response->path[4];

						$params = array(
							SearchFields_Ticket::TICKET_CLOSED => new DevblocksSearchCriteria(SearchFields_Ticket::TICKET_CLOSED,'=',CerberusTicketStatus::OPEN),
							SearchFields_Ticket::TICKET_WAITING => new DevblocksSearchCriteria(SearchFields_Ticket::TICKET_WAITING,'=',0),
							$params[SearchFields_Ticket::TEAM_ID] = new DevblocksSearchCriteria(SearchFields_Ticket::TEAM_ID,'in',array_keys($memberships)), // censor
						);

						if(!is_null($filter_worker_id)) {
							$tpl->assign('filter_bucket_id', $filter_bucket_id);
							$title = "For ".$workers[$filter_worker_id]->getName();
							$params[SearchFields_Ticket::TICKET_NEXT_WORKER_ID] = new DevblocksSearchCriteria(SearchFields_Ticket::TICKET_NEXT_WORKER_ID,'=',$filter_worker_id);
							
							@$filter_group_id = $response->path[5];
							if(!is_null($filter_group_id) && isset($groups[$filter_group_id])) {
								$title .= ' in '.$groups[$filter_group_id]->name;
								$params[SearchFields_Ticket::TEAM_ID] = new DevblocksSearchCriteria(SearchFields_Ticket::TEAM_ID,'=',$filter_group_id);
							}
						}
						
						break;
						
					case 'all':
					default:
						$title='All (Spam Filtered)';
						$params = array(
							SearchFields_Ticket::TICKET_CLOSED => new DevblocksSearchCriteria(SearchFields_Ticket::TICKET_CLOSED,'=',CerberusTicketStatus::OPEN),
							SearchFields_Ticket::TICKET_WAITING => new DevblocksSearchCriteria(SearchFields_Ticket::TICKET_WAITING,'=',0),
							SearchFields_Ticket::TICKET_NEXT_WORKER_ID => new DevblocksSearchCriteria(SearchFields_Ticket::TICKET_NEXT_WORKER_ID,'=',0),
							SearchFields_Ticket::TICKET_SPAM_SCORE => new DevblocksSearchCriteria(SearchFields_Ticket::TICKET_SPAM_SCORE,'<=','0.9000'),
							SearchFields_Ticket::TEAM_ID => new DevblocksSearchCriteria(SearchFields_Ticket::TEAM_ID,'in',array_keys($memberships)),
						);
						
						break;
				}
				
//				$params = array(
//						new DevblocksSearchCriteria(SearchFields_Ticket::TICKET_CLOSED,'=',CerberusTicketStatus::OPEN),
//						new DevblocksSearchCriteria(SearchFields_Ticket::TICKET_NEXT_WORKER_ID,'=',0),
//						new DevblocksSearchCriteria(SearchFields_Ticket::TICKET_SPAM_SCORE,'<=','0.9000'),
//						new DevblocksSearchCriteria(SearchFields_Ticket::TEAM_ID,'in',array_keys($memberships))					
//				);
				

				
//				$title = "Overview";				
			break;
		}
		
		$mobileView = C4_AbstractViewLoader::getView('', "VIEW_IPHONE");
		//print_r($mobileView);		
		if($mobileView == NULL) {
			$mobileView = new C4_IPhoneTicketView();//C4_TicketView();
		}
		$mobileView->id = "VIEW_IPHONE";
		$mobileView->name = $title;
		$mobileView->view_columns = array(SearchFields_Ticket::TICKET_LAST_ACTION_CODE);
		$mobileView->params = $params;
		$mobileView->renderLimit = 10;//$overViewDefaults->renderLimit;
		$mobileView->renderPage = $page;
		$mobileView->renderSortBy = SearchFields_Ticket::TICKET_UPDATED_DATE;
		$mobileView->renderSortAsc = 0;
		
		C4_AbstractViewLoader::setView($mobileView->id,$mobileView);		
		
		$views[] = $mobileView;
	
		$tpl->assign('views', $views);

		if($filter==null) {
			$filter = 'all';
		}
		$tpl->assign('filter', $filter);
		
		$fid = $response->path[4];
		if($fid == null ) {
			$fid = '0';
		}
		$tpl->assign('fid', $fid);
		
		$bucket_id = $response->path[5];
		if($bucket_id == null) {
			$buket_id = 0;
		}
		$tpl->assign('bid', $bucket_id);
		
		$tpl->assign('title', $title);
		$tpl->assign('tickets', $tickets[0]);
		$tpl->assign('next_page', $page+1);
		$tpl->assign('prev_page', $page-1);
		
		//print_r($tickets);exit();
		$tpl->display('file:' . dirname(__FILE__) . '/templates/tickets.tpl');
	}
	
};

?>