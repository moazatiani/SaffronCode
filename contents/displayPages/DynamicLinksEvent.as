package contents.displayPages
	//contents.displayPages.DynamicLinksEvent
{
	import flash.events.Event;
	
	public class DynamicLinksEvent extends Event
	{
		/**Update links position*/
		public static const UPDATE_LINKS_POSITION:String = "UPDATE_LINKS_POSITION" ;
		
		/**Reload the dynamic link*/
		public static const RELOAD_REQUIRED:String = "RELOAD_REQUIRED" ;
		
		public function DynamicLinksEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}