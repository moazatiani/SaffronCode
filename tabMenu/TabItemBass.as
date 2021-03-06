package tabMenu
{
	import appManager.displayContentElemets.TitleText;
	
	import contents.Contents;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;


	public class TabItemBass extends MovieClip
	{
		protected var _group:String,
					_bg:MovieClip,
					_name:String,
					_defaultTabe:String,
					_selected:Boolean,
					_activeCurrentTab:Boolean,
					_sendOnLoadEvent:Boolean,
					_selectableInActive:Boolean,
					_title:TitleText;
					
					
		private var _timerId:uint;	
		
		
		public function TabItemBass(GroupName_p:String=null,ActiveCurrentTab_p:Boolean=false,SendOnLoadEvent_p:Boolean=true,SelectableInActive_p:Boolean=false)
		{
			super();
			_group = GroupName_p;
			_activeCurrentTab = ActiveCurrentTab_p;		
			_name = this.name.split('_')[0];
			_sendOnLoadEvent = SendOnLoadEvent_p;
			_selectableInActive = SelectableInActive_p;
			try
			{			
				this.gotoAndStop(_name);
				_bg = Obj.get('bg',this);
				setTitle();
			}
			catch(e:Error)
			{
				trace('<<<Frame label '+_name+' not found in scene '+_name+'.>>>');
			}
			_defaultTabe = this.name.split('_')[1];	
			TabMenuManager.event.addEventListener(TabMenuEvent.SELECT,onSelected);	
			if(_activeCurrentTab && TabMenuManager.getCurrentTabe(GroupName_p,_name)==true)
			{
				_timerId = setTimeout(sendEventBytimer,5);
			}
			else if( !TabMenuManager.getAtiveGroup(GroupName_p)&& _defaultTabe!=null && _defaultTabe.toLowerCase()=='true')
			{
				_timerId = setTimeout(sendEventBytimer,5);
			}
			else if(!_sendOnLoadEvent)
			{
				onSelected(new TabMenuEvent(TabMenuEvent.SELECT,_group,null));
			}

			this.addEventListener(MouseEvent.CLICK,click_fun);
			this.addEventListener(Event.REMOVED_FROM_STAGE,unload);
		}
		protected function setTitle():void
		{
			if(_bg!=null)_title = Obj.findThisClass(TitleText,_bg);
			if(_title!=null)_title.setUp(Contents.lang.t[_name]);
		}
		protected function unload(event:Event):void
		{
			TabMenuManager.event.removeEventListener(TabMenuEvent.SELECT,onSelected);	
		}
		
		private function sendEventBytimer():void
		{
			if(_sendOnLoadEvent)
			{
				sendEvent();
			}
			else
			{				
				onSelected(new TabMenuEvent(TabMenuEvent.SELECT,_group,_name));
			}
			clearTimeout(_timerId);
		}
		
		/** defined active tab selected metod or add _true of end name tabe simple 'tabname_true' if add true this tab is default selected tab*/
		public function setup():void
		{
			sendEvent();
		}
		
		protected function onSelected(event:TabMenuEvent):void
		{
			if(event.group == _group)
			{
				if(event.name == _name && _bg!=null)
				{
					_selected = true;
				}
				else if(_bg!=null)
				{
					_selected = false;
				}
				if(_bg!=null)
				{		
					_bg.gotoAndStop(_selected);
				}

			}
		}
		
		protected function click_fun(event:MouseEvent):void
		{	
			if(!_selected || _selectableInActive)
			{			
				sendEvent();
				if(_activeCurrentTab)
				{
					TabMenuManager.setCurrentTabe(_group,_name,true);
				}
			}
		}
		protected function sendEvent():void
		{
			TabMenuManager.event.dispatchEvent(new TabMenuEvent(TabMenuEvent.SELECT,_group,_name));
		}
	}
}