
package sliderMenu
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.ui.Multitouch;
	
	import popForm.PopMenu;

	public class SliderManager
	{
		private static const debugVersion:Boolean = true ;
		
		
		public static const TOP_MENU:String = "topMenu",
							BOTTOM_MENU:String = "bottomMenu",
							LEFT_MENU:String = "leftMenu",
							RIGHT_MENU:String = "rightMenu";
		
		/**private static var tdMenu:Boolean;
		-1 means left side menu, 1 means right side menu
		private static var _menuDirectioni:int ;*/
		
		private static var allPose:Array;
		
	/////////////////////////////dispay object variables	
		private static var 	myStage:Stage,
							myRoot:DisplayObject,
							excludesList:Vector.<DisplayObject>,
							excludesPose:Vector.<Point>;

		
		/**slider s variables*/
		private static var 	slider_l:MovieClip,
							l_w:Number,
							l_p:Point,
							slider_r:MovieClip,
							r_w:Number,
							r_p:Point,
							slider_t:MovieClip,
							t_w:Number,
							t_p:Point,
							slider_b:MovieClip,
							b_p:Point,
							b_w:Number;
		
		private static var manageMenusFrames:Boolean;
							
	/////////////////////////////////// numerical variables↓
		/**this variable tells the number of the accepted pixel from the stage */
		private static var resolution:Number=35;
		
		
		/**stage pose variables
		private static var 	stageW:Number,
							stageH:Number,
							lx:Number,
							rx:Number,
							ty:Number,
							by:Number;*/
		
		internal static var lock_flag:Boolean = false;
							
		
		/**this variable tells that from witch side the slider menu is dragging*/
		private static var currentDraggingPose:String='';
		
		private static var mouseFirstPose:Point;
		
		
		public static var animSpeed:uint = 2;
		
		
	/////////////////////////////////
		
		public static var moveStage:Boolean = false ;
		
		
		
		////////////////////animation functions
		private static var frameRateControlled:Boolean;
		
		/**opent this menu*/
		public static function openMenu(MenuDirection:String = null)
		{
			if(PopMenu.isOpen)
			{
				return ;
			}
			unLock();
			
			if(MenuDirection==null)
			{
				if(slider_l!=null)
				{
					MenuDirection = LEFT_MENU ;
				}
				else if(slider_r!=null)
				{
					MenuDirection = RIGHT_MENU ;
				}
				else if(slider_t!=null)
				{
					MenuDirection = TOP_MENU ;
				}
				else if(slider_b != null)
				{
					MenuDirection = BOTTOM_MENU ;
				}
			}
			
			mouseFirstPose = null ;
			currentDraggingPose = MenuDirection;
		}
		
		/**hide all menus*/
		public static function hide(instanceHide:Boolean=false)
		{
			if(myRoot!=null)
			{
				mouseFirstPose = null ;
				currentDraggingPose = '' ;
				if(instanceHide)
				{
					var cashedAnimSpeed:uint = animSpeed ;
					animSpeed = 1;
					anim(null);
					animSpeed = cashedAnimSpeed ;
				}
			}
		}
		/**Tells if menu is open or not*/
		public static function isOpen():Boolean
		{
			return !(currentDraggingPose == '') ;
		}
		
		
		/**start the drag*/
		private static function checkDrag(e:MouseEvent)
		{
			if(lock_flag)
			{
				//menu is lock
				return ;
			}
			mouseFirstPose = new Point(myStage.mouseX,myStage.mouseY);
			if(slider_l!=null 
				&& 
				(
					(
						moveStage 
						&& 
						(
							(
								currentDraggingPose!=LEFT_MENU 
								&& 
								myRoot.mouseX<resolution
							) 
							|| 
							(
								currentDraggingPose==LEFT_MENU 
								&& 
								myRoot.mouseX>0
							)
						)
					) 
					|| 
					(
						!moveStage
						&&
						(
							(
								currentDraggingPose!=LEFT_MENU 
								&& 
								myStage.mouseX<resolution
							)
							||
							(
								currentDraggingPose==LEFT_MENU 
								&& 
								myStage.mouseX>slider_l.x
							)
						)
					)
				)
			)
			{
				if(currentDraggingPose==LEFT_MENU)
				{
					if(moveStage)
					{
						mouseFirstPose.x-=myRoot.x;
					}
					else
					{
						mouseFirstPose.x-=slider_l.x;
					}
				}
				currentDraggingPose = LEFT_MENU;
			}
			else if//(slider_r!=null && myStage.mouseX>slider_r.x-resolution && currentDraggingPose != RIGHT_MENU)
				(slider_r!=null 
					&& 
					(
						(
							moveStage 
							&& 
							(
								(
									currentDraggingPose!=RIGHT_MENU 
									&& 
									myRoot.mouseX>slider_r.x-resolution
								) 
								|| 
								(
									currentDraggingPose==RIGHT_MENU 
									&& 
									myRoot.mouseX<slider_r.x+resolution
								)
							)
						) 
						|| 
						(
							!moveStage
							&&
							(
								(
									currentDraggingPose!=RIGHT_MENU 
									&& 
									myStage.mouseX>slider_r.x-resolution
								)
								||
								(
									currentDraggingPose==RIGHT_MENU 
									&& 
									myStage.mouseX<slider_r.x+resolution
								)
							)
						)
					)
				)
			{
				if(currentDraggingPose==RIGHT_MENU)
				{
					if(moveStage)
					{
						mouseFirstPose.x-=myRoot.x;
					}
					else
					{
						mouseFirstPose.x+=addGetSlider(currentDraggingPose);
					}
				}
				currentDraggingPose = RIGHT_MENU;
			}
			else if(slider_t!=null && myStage.mouseY<resolution && currentDraggingPose != TOP_MENU)
			{
				currentDraggingPose = TOP_MENU;
			}
			else if(slider_b!=null && myStage.mouseY>slider_b.y-resolution && currentDraggingPose != BOTTOM_MENU)
			{
				currentDraggingPose = BOTTOM_MENU;
			}
			else
			{
				mouseFirstPose = null ;
				var obj:MovieClip = addGetSlider(currentDraggingPose,null,0,true);
				//trace("obj is : "+obj);
				if(obj == null || !obj.hitTestPoint(myRoot.mouseX,myRoot.mouseY))
				{
					currentDraggingPose = '' ;
				}
			}
			
				 
			///continure other drag detections
		}
		
		/**stop the dragging */
		private static function stopDrag(e:MouseEvent)
		{
			if(mouseFirstPose!=null && !lock_flag)
			{
				var deltaPoseNumber = addGetSlider(currentDraggingPose);
				if(currentDraggingPose == LEFT_MENU || currentDraggingPose == RIGHT_MENU)
				{
					if(currentDraggingPose == LEFT_MENU && myStage.mouseX-mouseFirstPose.x<deltaPoseNumber/2)
					{
						currentDraggingPose = '' ;
					}
					else if(currentDraggingPose == RIGHT_MENU && myStage.mouseX-mouseFirstPose.x>deltaPoseNumber/-2)
					{
						currentDraggingPose = '' ;
					}
				}
				else if(currentDraggingPose == TOP_MENU || currentDraggingPose == BOTTOM_MENU)
				{
					if(Math.abs(myStage.mouseY-mouseFirstPose.y)<deltaPoseNumber/2)
					{
						currentDraggingPose = '' ;
					}
				}
				
				mouseFirstPose = null ;
			}
		}
		
		/**animate the stage*/
		private static function anim(e:Event)
		{
			var deltaPose:Point = new Point(0,0);
			var deltaPoseNumber:Number = addGetSlider(currentDraggingPose);
			if(currentDraggingPose==LEFT_MENU || currentDraggingPose==RIGHT_MENU)
			{
				if(mouseFirstPose!=null)
				{
					deltaPose = new Point(myStage.mouseX-mouseFirstPose.x,deltaPose.y);
				}
				else
				{
					if(currentDraggingPose == LEFT_MENU)
					{
						deltaPose = new Point(deltaPoseNumber,deltaPose.y);
					}
					else
					{
						deltaPose = new Point(-deltaPoseNumber,deltaPose.y);
					}
				}
			}
			else if(currentDraggingPose == TOP_MENU || currentDraggingPose == BOTTOM_MENU )
			{
				if(mouseFirstPose!=null)
				{
					deltaPose = new Point(deltaPose.x,myStage.mouseY-mouseFirstPose.y);
				}
				else
				{
					if(currentDraggingPose == TOP_MENU )
					{
						deltaPose = new Point(deltaPose.x,deltaPoseNumber);
					}
					else
					{
						deltaPose = new Point(deltaPose.x,-deltaPoseNumber);
					}
				}
			}
			
			if(currentDraggingPose =='')
			{
				//nothing
			}
			else if(currentDraggingPose == LEFT_MENU)
			{
				deltaPose.x = Math.max(Math.min(deltaPose.x,deltaPoseNumber),0);
			}
			else if (currentDraggingPose == RIGHT_MENU)
			{
				deltaPose.x = Math.min(Math.max(deltaPose.x,-deltaPoseNumber),0);
			}
			else if(currentDraggingPose == TOP_MENU)
			{
				deltaPose.y = Math.max(0,Math.min(deltaPose.y,deltaPoseNumber));
			}
			else if(currentDraggingPose == BOTTOM_MENU)
			{
				deltaPose.y = Math.min(0,Math.max(deltaPose.y,-deltaPoseNumber));
			}
			
			//trace("myStage : "+myStage.x++);
			if(moveStage)
			{
				myRoot.x += (deltaPose.x-myRoot.x)/animSpeed;
				myRoot.y += (deltaPose.y-myRoot.y)/animSpeed;
			}
			
			var i:int;
			
			if(manageMenusFrames || !moveStage)
			{
				var rootPose:Point = new Point(myRoot.x,myRoot.y);
				var precent:Number = rootPose.length ;
				
				for(i = 0 ; i<allPose.length ; i++)
				{
					var obj:MovieClip = addGetSlider(allPose[i],null,0,true);
					if(obj == null)
					{
						continue ;
					}
					var deltaW:Number = addGetSlider(allPose[i]);
					
					if(manageMenusFrames)
					{
						if(currentDraggingPose == allPose[i])
						{
							var cprecent:uint;
							if(moveStage)
							{
								cprecent = Math.min(obj.totalFrames,Math.ceil(Math.min(1,precent/deltaW)*obj.totalFrames));
							}
							else
							{
								cprecent = Math.min(obj.totalFrames,Math.ceil(Math.min(1,deltaPose.length/deltaW)*obj.totalFrames));
							}
							obj.gotoAndStop(cprecent);
						}
						else
						{
							obj.gotoAndStop(1);
						}
					}
					
					if(!moveStage)
					{
						var pose:Point = addGetSlider(allPose[i],null,0,false,true);
						if(currentDraggingPose == allPose[i])
						{
							obj.x += ((pose.x+deltaPose.x)-obj.x)/animSpeed ;
							obj.y += ((pose.y+deltaPose.y)-obj.y)/animSpeed ;
						}
						else
						{
							obj.x += (pose.x-obj.x)/animSpeed ;
							obj.y += (pose.y-obj.y)/animSpeed ;
						}
					}
				}
			}
			
			
			for(i = 0 ; i<excludesList.length ; i++)
			{
				excludesList[i].x = excludesPose[i].x-myRoot.x;
				excludesList[i].y = excludesPose[i].y-myRoot.y;
			}
		}
		
		
	//////////////////////////////////////////////////////intialize functions↓
							
		/**fist insialize of the class - detecting the stage width and height too*/					
		private static function intialize(appObject:DisplayObject)
		{
			if(excludesList == null)
			{
				allPose = [LEFT_MENU,TOP_MENU,RIGHT_MENU,BOTTOM_MENU];
				
				myRoot = appObject ;
				myStage = myRoot.stage ;
				excludesList = new Vector.<DisplayObject>();
				excludesPose = new Vector.<Point>();
				
				myStage.addEventListener(MouseEvent.MOUSE_DOWN,checkDrag);
				myStage.addEventListener(MouseEvent.MOUSE_UP,stopDrag);
				myStage.addEventListener(Event.ENTER_FRAME,anim);
				
				if(!frameRateControlled)
				{
					var frameRatePrecent:Number = myStage.frameRate/30 ;
					
					frameRateControlled = true ;
					animSpeed = animSpeed*frameRatePrecent;
				}
				//detectSizes();
			}
		}
		
		/**set up a slider menu for the stage on selected position and with yourMenu<br>
		 * you have only one stage*/
		public static function setMenu(yourMenu:MovieClip,deltaSlide:Number,menuPosition:String = LEFT_MENU,manageFrames:Boolean=true,moveTheStage:Boolean=true)
		{
			lock_flag = true ;
			moveStage = moveTheStage ;
			manageMenusFrames = manageFrames ;
			if(manageMenusFrames)
			{
				yourMenu.stop();
			}
			if(!debugVersion && Multitouch.supportsTouchEvents)
			{
				//enable button for these menus
				return;
			}
			
			intialize(yourMenu.root);
			
			addGetSlider(menuPosition,yourMenu,deltaSlide);
			unLock();
		}
		
		/**lock the slider menus*/
		public static function lock(closeBeforLock:Boolean=true)
		{
			if(closeBeforLock)
			{
				hide();
			}
			lock_flag = true ;
			SliderButtonSwitcher.lockDispatcher.dispatchEvent(new Event(Event.CLOSE));
		}
		
		/**unlock the app*/
		public static function unLock()
		{
			lock_flag = false;
			SliderButtonSwitcher.lockDispatcher.dispatchEvent(new Event(Event.OPEN));
		}
		
		/**exclude some objects from sliding with stage object*/
		public static function doNotActOnThisObject(excludedObject:DisplayObject)
		{
			excludesList.push(excludedObject);
			excludesPose.push(new Point(excludedObject.x,excludedObject.y));
		}
		
		
		
		
		/**this function will set up the stageW and stageH variables from detecting fullscreen width and height
		private static function detectSizes()
		{
			var temFullScreenWidth,temFullScreenHeight;
			
			temFullScreenWidth = myStage.fullScreenWidth ;
		
			temFullScreenHeight = myStage.fullScreenHeight ;
			
			
			var scaleX = temFullScreenWidth/myStage.stageWidth;
			var scaleY = temFullScreenHeight/myStage.stageHeight;
			
			var scl = Math.max(scaleX,scaleY);
			
			stageW = Math.round(temFullScreenWidth/scl);
			stageH = Math.round(temFullScreenHeight/scl);
			
			trace('scale is : '+scl);
			trace('stage W : '+stageW);
			trace('stage H : '+stageH);
			
			lx = (stageW-myStage.stageWidth)/-2;
			rx = myStage.stageWidth-lx;
			ty = (stageH-myStage.stageHeight)/-2;
			by = myStage.stageHeight-ty;
		}*/
		
		
		/**set or get the menu on the selected direction - this function will take menu position to the asked position for the menu*/
		private static function addGetSlider(pose:String,menu:MovieClip=null,yourSize:Number=0,returnMenuObject:Boolean = false,returnMenuPose:Boolean=false):*
		{
		
			switch(pose)
			{
				case(TOP_MENU):
				{
					if(menu!=null)
					{
						t_w = yourSize ;
						t_p = new Point(menu.x,menu.y) ;
						/*menu.x = lx ;
						menu.y = ty;*/
						slider_t = menu ;
					}
					if(returnMenuPose)
					{
						return t_p ;
					}
					else if(returnMenuObject)
					{
						return slider_t ;
					}
					else
					{
						return t_w;
					}
					return t_w;
					break;
				};
				case(RIGHT_MENU):
				{
					if(menu!=null)
					{
						reset();
						r_w = yourSize ;
						r_p = new Point( menu.x,menu.y);
						/*menu.x = rx ;
						menu.y = ty;*/
						slider_r = menu ;
					}
					if(returnMenuPose)
					{
						return r_p;
					}
					else if(returnMenuObject)
					{
						return slider_r ;
					}
					else
					{
						return r_w;
					}
					break;
				};
				case(LEFT_MENU):
				{
					if(menu!=null)
					{
						reset();
						l_w = yourSize ;
						l_p = new Point(menu.x,menu.y);
						/*menu.x = lx ;
						menu.y = ty;*/
						slider_l = menu ;
					}
				
					if(returnMenuPose)
					{
						return l_p ;
					}
					else if(returnMenuObject)
					{
						return slider_l ;
					}
					else
					{
						return l_w;
					}
					break;
				};
				case(BOTTOM_MENU):
				{
					if(menu!=null)
					{
						b_w = yourSize ;
						b_p = new Point(menu.x,menu.y) ;
						/*menu.x = lx ;
						menu.y = by;*/
						slider_b = menu ;
					}
					
					if(returnMenuPose)
					{
						return b_p ;
					}
					else if(returnMenuObject)
					{
						return slider_b ;
					}
					else
					{
						return b_w;
					}
					break;
				};
			}
			
			return null ;
		}
		
		
		/**open or close current menu , depends on it situation*/
		public static function switchMenu(MenuDirection:String = LEFT_MENU):void
		{
			unLock();
			mouseFirstPose = null ;
			if(currentDraggingPose == MenuDirection)
			{
				currentDraggingPose = '';
			}
			else
			{
				currentDraggingPose = MenuDirection;
			}
		}
		private static function reset():void
		{
			r_w = 0 ;
			r_p = null;
			slider_r = null ;
			
			l_w = 0 ;
			l_p = null;
			slider_l = null ;
		}
	}
}