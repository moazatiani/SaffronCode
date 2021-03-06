package contents.rollingList
	//contents.rollingList.RollingList
{
	import appManager.event.AppEvent;
	import appManager.event.AppEventContent;
	
	import contents.LinkData;
	import contents.PageData;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	[Event(name="change", type="flash.events.Event")]
	public class RollingList extends MovieClip
	{
		//appManager.displayContentElemets.TitleText
		
		public var lastSelectedItem:uint = 0 ;
		
		private var rollerItemClass:Class ;
		
		public var myPageDataLink:Vector.<LinkData>,
					totalPageLinks:uint;
		
		
		private var myHeight:Number,
					myWidth:Number,
					myLinkItemHeight:Number;
		
		private var createdLins:Vector.<RollingItem> ;
		
		private var bottomOfList:int,
					topOfList:int;
					
		private var rollingItemsMask:Sprite ,
					rollingItemsContainer:Sprite ;
					
					
		//Animation variables
		private var scorllI:Number ;
		private var isDragging:Boolean = false ;
		private var startsToDrag:Boolean = false ;
		private var currentMouseY:Number ;
		private var V:Number,
					Vlist:Vector.<Number>,
					vQueLength:uint = 20 ,
					mu:Number = 0.8,
					mu2:Number=0.4,
					mu3:Number=0.4,
					fu2:Number = 50 ,
					fu3:Number = 5 ,
					fu:Number = 5 ;
					
		private static var lastScrollPosition:Object = {};
					
		private var pointerMC:MovieClip ;
		
		private const minDragToMove:Number = 10 ;
		
		private var selectedItemIndexToTrack:int = -1 ;
		private var myPageId:String;
					
		public function RollingList()
		{
			super();
			
			scorllI = 0 ;
			V = 0 ;
			
			var rollerSample:RollingItem = Obj.findThisClass(RollingItem,this);
			myLinkItemHeight = rollerSample.height ;
			rollerItemClass = Obj.getObjectClass(rollerSample) ;
			Obj.remove(rollerSample);
			
			pointerMC = Obj.get("pointer_mc",this);
			if(pointerMC==null)
			{
				pointerMC = new MovieClip();
				pointerMC.graphics.beginFill(0x000000);
				pointerMC.graphics.lineTo(-10,-5);
				pointerMC.graphics.lineTo(-10,5);
				pointerMC.x = pointerMC.width ;
			}
			
			myHeight = this.height ;
			myWidth = this.width ;
			this.removeChildren();
			this.graphics.clear();
			
			this.graphics.beginFill(0x000000,0);
			this.graphics.drawRect(0,0,myWidth,myHeight);
			
			rollingItemsMask = new Sprite();
			rollingItemsMask.graphics.beginFill(0x000000,0.1);
			rollingItemsMask.graphics.drawRect(0,0,myWidth,myHeight);
			
			rollingItemsContainer = new Sprite();
			
			this.addChild(rollingItemsContainer);
			this.addChild(rollingItemsMask);
			
			
			rollingItemsContainer.mask = rollingItemsMask ;
			
			rollingItemsContainer.addEventListener(AppEvent.PAGE_CHANGES,preventPageChange);
			this.addEventListener(Event.REMOVED_FROM_STAGE,unLoad);
			this.addEventListener(MouseEvent.MOUSE_DOWN,mousePressed);
		}	
		
		protected function preventPageChange(event:Event):void
		{
			trace("Im selected");
			event.stopImmediatePropagation();
			var selectedItem:RollingItem = event.target as RollingItem ;
			if(selectedItem == null)
			{
				return ;
			}
			else if(lastSelectedItem != selectedItem.myIndex)
			{
				lastSelectedItem = selectedItem.myIndex ;
				selectedItemIndexToTrack = selectedItem.myIndex ;
				dispatchChangeEvent();
			}
		}
		
		/**Mouse down*/
		protected function mousePressed(event:MouseEvent):void
		{
			currentMouseY = this.mouseY ;
			startsToDrag = true ;
			selectedItemIndexToTrack = -1 ;
			V = 0 ;
			Vlist = new Vector.<Number>();
			stage.addEventListener(MouseEvent.MOUSE_UP,stopDraging);
		}
		
		/**Mouse up*/
		protected function stopDraging(event:MouseEvent):void
		{
			stage.removeEventListener(MouseEvent.MOUSE_UP,stopDraging);
			isDragging = false ;
			startsToDrag = false ;
		}
		
		/**Animate the scorller*/
		protected function anim(event:Event):void
		{
			if(startsToDrag)
			{
				if(Math.abs(currentMouseY-this.mouseY)>minDragToMove)
				{
					isDragging = true ;
					currentMouseY = this.mouseY ;
					startsToDrag = false ;
					this.dispatchEvent(new ScrollMTEvent(ScrollMTEvent.LOCK_SCROLL_TILL_MOUSE_UP,true));
				}
			}
			if(isDragging)
			{
				scorllI += (this.mouseY-currentMouseY);
				Vlist.push(this.mouseY-currentMouseY);
				currentMouseY = this.mouseY ;
				if(Vlist.length>vQueLength)
				{
					Vlist.shift();
				}
			}
			else
			{
				if(startsToDrag == false && Vlist!=null )
				{
					V = 0 ;
					for(var i:int = 0 ; i<Vlist.length ; i++)
					{
						V += Vlist[i] ;
					}
					if(Vlist.length!=0)
					{
						V = V/Vlist.length ;
					}
					Vlist = null ;
				}
				if(createLinkY(0)>myHeight/2+2)
				{
					V += (myHeight/2-createLinkY(0))/fu ;
					V = V*mu2 ;
				}
				else if(createLinkY(totalPageLinks-1)<myHeight/2-2)
				{
					V += (myHeight/2-(createLinkY(totalPageLinks-1)))/fu ;
					V = V*mu2 ;
				}
				else if(selectedItemIndexToTrack!=-1)
				{
					var targetY:Number = createLinkY(selectedItemIndexToTrack) ;
					if(Math.abs(targetY-pointerMC.y)<myLinkItemHeight/2 && Math.abs(V)<4)
					{
						selectedItemIndexToTrack = -1 ;
					}
					V+=(pointerMC.y-targetY)/fu3 ;
					V*=mu3 ;
				}
				else
				{
					var leedY:Number = (createLinkY(0)-myHeight/2) ;
					var currentItemOnPointer:int = -Math.floor((leedY+linkHeight()/2)/linkHeight()) ;
					leedY = leedY+currentItemOnPointer*linkHeight()
					V-=leedY/fu2;
					if(lastSelectedItem!=currentItemOnPointer && Math.abs(V)<2)
					{
						lastSelectedItem = currentItemOnPointer ;
						dispatchChangeEvent();
					}
					lastScrollPosition[myPageId] = scorllI ;
				}
				
				
				scorllI += V ;
				V = V*mu ;
			}
			controllLinkGenerator();
			updateAllInterface();
		}	
		
		/**Selected item changed*/
		private function dispatchChangeEvent():void
		{
			trace("Changed : "+lastSelectedItem);
			this.dispatchEvent(new Event(Event.CHANGE));
			this.dispatchEvent(new AppEventContent(myPageDataLink[lastSelectedItem]));
		}
		
		/**Removed from stage*/
		protected function unLoad(event:Event):void
		{
			stage.removeEventListener(MouseEvent.MOUSE_UP,stopDraging);
			this.removeEventListener(Event.ENTER_FRAME,anim);
			this.removeEventListener(Event.REMOVED_FROM_STAGE,unLoad);
		}
		
		/**Set the page list*/
		public function setUp(pageData:PageData,selectedItemIndex:uint=0):void
		{
			if(pageData==null)
			{
				return;
			}
			selectedItemIndexToTrack = lastSelectedItem = selectedItemIndex ;
			myPageDataLink = pageData.links1 ;
			totalPageLinks = myPageDataLink.length ;
			myPageId = pageData.id ;
			if(myPageId == '' || isNaN(Number(lastScrollPosition[myPageId])) )
			{
				scorllI = 0 ;
			}
			else
			{
				scorllI = Number(lastScrollPosition[myPageId]) ;
			}
			
			for(var i:int = 0 ; createdLins!=null && i<createdLins.length ; i++)
			{
				Obj.remove(createdLins[i]);
			}
			
			bottomOfList = 1 ;
			topOfList = 0 ;
			
			createdLins = new Vector.<RollingItem>();
			
			controllLinkGenerator();
			updateAllInterface();
			this.removeEventListener(Event.ENTER_FRAME,anim);
			this.addEventListener(Event.ENTER_FRAME,anim);
			
			this.addChild(pointerMC);
			var cahsedScroll:Number = scorllI ;
			scorllI = 0 ;
			pointerMC.y = createLinkY(0);/*+myLinkItemHeight/2*/
			scorllI = cahsedScroll ;
			dispatchChangeEvent();
		}
		
		/**Controll link*/
		private function controllLinkGenerator():void
		{
			var newLinkAdded:Boolean = false ;
			var requiredLinkY:Number ;
			//trace('bottomOfList : '+bottomOfList+' , topOfList : '+topOfList); 
			if(bottomOfList>=0)
			{
				if(bottomOfList<totalPageLinks)
				{
					requiredLinkY = createLinkY(bottomOfList); 
					if(/*requiredLinkY+myLinkItemHeight>0 && */requiredLinkY<myHeight)
					{
						addLink(bottomOfList,true);
						bottomOfList++ ;
						newLinkAdded = true ;
					}
				}
				if(bottomOfList>0 && createLinkY(bottomOfList-1)>myHeight)
				{
					removeLint(true);
					bottomOfList--;
				}
			}
			if(topOfList>=0)
			{
				requiredLinkY = createLinkY(topOfList);
				if(requiredLinkY+myLinkItemHeight>0/* && requiredLinkY<myHeight*/)
				{
					addLink(topOfList,false);
					topOfList--;
					newLinkAdded = true ;
				}
			}
			if(topOfList+1<totalPageLinks && createLinkY(topOfList+1)+myLinkItemHeight<0)
			{
				removeLint(false);
				topOfList++;
			}
			
			if(newLinkAdded)
			{
				controllLinkGenerator();
			}
		}
		
		/**Add this item to the list*/
		private function addLink(linkItemIndex:int,isFromBottom:Boolean):void
		{
			var item:RollingItem = new rollerItemClass();
			rollingItemsContainer.addChild(item);
			item.x = myWidth/2; 
			item.setUp(myPageDataLink[linkItemIndex]);
			item.setIndex(linkItemIndex);
			if(isFromBottom)
			{
				createdLins.push(item) ;
			}
			else
			{
				createdLins.unshift(item) ;
			}
		}
		
		/**Remove the link item from the list*/
		private function removeLint(isFromBottom:Boolean)
		{
			if(isFromBottom)
			{
				Obj.remove(createdLins.pop());
			}
			else
			{
				Obj.remove(createdLins.shift());
			}
		}
		
		/**Update all interface*/
		private function updateAllInterface():void
		{
			var listLenght:uint = createdLins.length ;
			var currentY:Number ;
			for(var i:int = 0 ; i<listLenght ; i++)
			{
				currentY = createdLins[i].y = createLinkY(createdLins[i].myIndex) ;
				createLinkAlphaAndScale(currentY,createdLins[i]);
			}			
		}
		
		/**Return the link Y for this index*/
		private function createLinkY(itemIndex:uint):Number
		{
			return itemIndex*linkHeight()+scorllI+myHeight/2 ;
		}
		
		private function linkHeight():Number
		{
			return myLinkItemHeight ;
		}
		
		/**Return the link Y for this index*/
		private function createLinkAlphaAndScale(currentY:Number,rollItem:RollingItem):void
		{
			//currentY-=myLinkItemHeight;
			const maxAvailableArea:Number = myLinkItemHeight*3 ;
			var changedH:Number = myHeight-myLinkItemHeight ;
			
			if(myHeight>maxAvailableArea)
			{
				changedH = maxAvailableArea ;
				currentY -= (myHeight-maxAvailableArea)/2 ;
			}
			
			var rad:Number = Math.PI/-2+currentY/changedH*(Math.PI*2) ;
			if(rad<-Math.PI/2)
			{
				rad = -Math.PI/2;
			}
			else if(rad>Math.PI*3/2)
			{
				rad = Math.PI*3/2;
			}
			var sinVal:Number = Math.sin(rad)/2+0.5 ;
			/*if(rollItem.myIndex==0)
			{
				trace("sinVal : "+sinVal);
				trace("rad : "+(rad/Math.PI*180));
			}*/
			if(sinVal<0)
			{
				sinVal
			}
			rollItem.alpha = 0.1+sinVal*0.9 ;
			rollItem.scaleX = rollItem.scaleY = 0.9+sinVal*0.1 ;
		}
	}
}