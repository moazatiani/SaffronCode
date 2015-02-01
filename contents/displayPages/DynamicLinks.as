package contents.displayPages
	//contents.displayPages.DynamicLinks
{
	import contents.LinkData;
	import contents.PageData;
	import contents.interFace.DisplayPageInterface;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	public class DynamicLinks extends MovieClip implements DisplayPageInterface
	{
		private var myPageData:PageData ;
		
		private var sampleLink:LinkItem,
					linkClass:Class;
					
		private var linkScroller:ScrollMT,
					areaRect:Rectangle,
					linksContainer:Sprite,
					linksSensor:Sprite ;
					
		private var lastGeneratedLinkIndes:uint ;
		
		public static var deltaY:Number = 20 ;
		
		private var noLinksMC:MovieClip ;
		
		/**1-Cereate LinkItem on this pages<br>
		 * 2- Draw a shape to define scrollArea in this object*/
		public function DynamicLinks()
		{
			super();
			
			//This will automaticaly removes at the last line
			noLinksMC = Obj.get("no_link_mc",this);
			
			areaRect = this.getBounds(this);
			
			sampleLink = Obj.findThisClass(LinkItem,this,true);
			if(sampleLink ==null)
			{
				throw "Dynamic manu class shouldent be empty of linkItem!";
			}
			
			linkClass = getDefinitionByName(getQualifiedClassName(sampleLink)) as Class;
			trace('link class is : '+linkClass);
			
			this.removeChildren();
		}
		
		public function setUp(pageData:PageData):void
		{
			trace("current page data is : "+pageData.export());
			myPageData = pageData;
			if(pageData.links1.length == 0 && noLinksMC!=null)
			{
				this.addChild(noLinksMC);
			}
			else
			{
				createLinks();
			}
		}
		
		private function createLinks()
		{
			lastGeneratedLinkIndes = 0 ;
			
			linksContainer = new Sprite();
			linksContainer.x = areaRect.x ;
			linksContainer.y = areaRect.y ;
			linksContainer.graphics.beginFill(0,0) ;
			linksContainer.graphics.drawRect(0,0,areaRect.width,areaRect.height) ;
			
			this.addChild(linksContainer);
		
			
			linksSensor = new Sprite();
			linksSensor.y = deltaY ;
			linksSensor.graphics.beginFill(0,0);
			linksSensor.graphics.drawRect(0,0,areaRect.width,areaRect.height/2);
			
			linksContainer.addChild(linksSensor);
			
			
			linkScroller = new ScrollMT(linksContainer,areaRect,areaRect,true,false,true);
			
			this.addEventListener(Event.ENTER_FRAME,controllSensor);
			this.addEventListener(Event.REMOVED_FROM_STAGE,unLoad);
		}
		
		private function unLoad(ev:Event=null)
		{
			this.removeEventListener(Event.ENTER_FRAME,controllSensor) ;
			this.removeEventListener(Event.REMOVED_FROM_STAGE,unLoad) ;
		}
		
		private function controllSensor(ev:Event=null)
		{
			var sens:Rectangle = linksSensor.getBounds(this);
			if(sens.top<areaRect.bottom)
			{
				var ifTherIs:Boolean = creatOneLink();
				if(ifTherIs)
				{
					controllSensor();
				}
				else
				{
					unLoad()
				}
			}
		}
		
		private function creatOneLink():Boolean
		{
			// TODO Auto Generated method stub
			if(lastGeneratedLinkIndes<myPageData.links1.length)
			{
				var newLink:LinkItem = new linkClass() ;
				linksContainer.addChild(newLink) ;
				newLink.setUp(myPageData.links1[lastGeneratedLinkIndes]) ;
				newLink.x = (areaRect.width-newLink.width)/2 ;
				newLink.y = linksSensor.y ;
				linksSensor.y+=newLink.height+deltaY ;
				
				lastGeneratedLinkIndes++ ;
				return true ;
			}
			else
			{
				return false ;
			}
		}
	}
}