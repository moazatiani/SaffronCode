//Edited on 9/26/2015
package diagrams.instagram
{
	import com.mteamapp.camera.MTeamCamera;
	
	import flash.display.JointStyle;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	public class Instagram extends MovieClip
	{
		/**If isLock variable was true , the class can not draw its datas till unlock function calls*/
		private var isLock:Boolean = false ;
		
		/**if you add any new Datas , it will change to true and after drawing the instafram , it will be false*/
		private var isChanged:Boolean = false ;
		
		/**This is an area that titlse need to show*/
		private var vTitleHeights:Number ;
		
		/**List of titles from out of tht class*/
		private var pushedTitles:InstagramTitles ;
		
		/**List of titlte those generated by the class its self*/
		private var myTitles:InstagramTitles ;
		
		
		/**List of current isntagram datas*/
		private var myDiagramDatas:Vector.<InstagramData> ;
		
		private var Width:Number ,
					Height:Number ;
					
		private var HLine:MovieClip,
					VLine:MovieClip ;
					
					
		private var diagramsPrevList:Vector.<DiagramPreveiw> ;
					
		//private var HTitleList:Vector.<InstaTitle>;
		//private var VTitleList:Vector.<InstaTitle>;
		
		public function Instagram(myAreaRectangle:Rectangle )
		{
			super();
			
			diagramsPrevList = new Vector.<DiagramPreveiw>();
			
			myDiagramDatas = new Vector.<InstagramData>();
			
			Width = myAreaRectangle.width ;
			Height = myAreaRectangle.height ;
			
			HLine = new MovieClip();
			this.addChild(HLine);
			VLine = new MovieClip();
			this.addChild(VLine);
			
			
			/*this.graphics.beginFill(0xff0000);
			this.graphics.drawRect(0,0,Width,Height);*/
			
			this.x = myAreaRectangle.x ;
			this.y = myAreaRectangle.y ;
			
			
			var sampleTitle:InstaTitle = new InstaTitle() ;
			vTitleHeights = sampleTitle.height ;
			
			this.addEventListener(Event.ENTER_FRAME , checkMosePoseFoGuide);
			this.addEventListener(Event.REMOVED_FROM_STAGE,unLoad);
		}
		
		protected function unLoad(event:Event):void
		{
			
			this.removeEventListener(Event.ENTER_FRAME , checkMosePoseFoGuide);
			this.removeEventListener(Event.REMOVED_FROM_STAGE,unLoad);
		}
		
		protected function checkMosePoseFoGuide(event:Event):void
		{
			
			var i:int ;
			if(this.mouseX<0 || this.mouseX>Width || this.mouseY<0 || this.mouseY>Height)
			{
				HLine.visible = false ;
				VLine.visible = false ;
				return ;
			}
			if(myTitles == null)
			{
				return ;
			}
			var min:Number = Infinity ;
			var delta:Number ;
			var minID:uint ;
			minID = 0;
			
			
			if(myTitles.hTitle.length!=0)
			{
				for(i = 0 ; i<myTitles.hTitle.length ; i++)
				{
					delta = Math.abs(myTitles.hTitle[i].position-this.mouseX) ;
					if( delta < min )
					{
						min = delta ;
						minID = i ;
					}
				}
				
				HLine.visible = true ;
				HLine.x = myTitles.hTitle[minID].position ;
			}
			
			
		//Vertical guide line
			min = Infinity ;
			minID = 0;
			if(myTitles.vTitle.length!=0)
			{
				for(i = 0 ; i<myTitles.vTitle.length ; i++)
				{
					delta = Math.abs(myTitles.vTitle[i].position-this.mouseY) ;
					if( delta < min )
					{
						min = delta ;
						minID = i ;
					}
				}
				
				VLine.visible = true ;
				VLine.y = myTitles.vTitle[minID].position ;
			}
		}
		
		/**Lock instance diagram drawing*/
		public function lock():void
		{
			
			isLock = true ;
		}
		
		/**Unlock the diagram and redraw diagram if datas are changed*/
		public function unLock()
		{
			isLock = false ;
			if(isChanged)
			{
				reDrawDiagram();
			}
		}
		
		
		
		
	///////////////////////////////////////
		/**Add this diagram ( override if same is exists ) and redraw diagram again*/
		public function addDiagramData(diagramData:InstagramData)
		{
			for(var i = 0 ; i<myDiagramDatas.length && diagramData>myDiagramDatas[i] ; i++){}
			var replcate = (myDiagramDatas.length>i && diagramData.id == myDiagramDatas[i].id)?1:0;
			myDiagramDatas.splice(i,replcate,diagramData);
			isChanged = true ;
			
			//Dont redray the diagram
			//Dont worry, It will prevent to redrawing if the diagram was lock
			reDrawDiagram();
		}
		
		
		
		/**This function will not redraw the tiltles of the instagram. if you need to change diagram range,call 0-lock() 1- clearDiagram(), 2-addDiagramDatas() with your new range 3-changeDiagramTitle() 4-unLock()*/
		public function changeDiagramValue(instaData:InstagramData):void
		{
			
			for(var i = 0 ; i<diagramsPrevList.length ; i++)
			{
				if(diagramsPrevList[i].id == instaData.id)
				{
					diagramsPrevList[i].changeVals(instaData);
					return ;
				}
			}
			throw "Add this diagram first. id is : "+instaData;
		}
		
		public function clearDiagram()
		{
			myDiagramDatas = new Vector.<InstagramData>();
			diagramsPrevList = new Vector.<DiagramPreveiw>();
			isChanged = true ;
			
			reDrawDiagram();
		}
		
		
		
		
		public function addTitleList(newTitleObject:InstagramTitles=null)
		{
			pushedTitles = newTitleObject ;
			isChanged = true ;
			reDrawDiagram();
		}
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		/**redraw the diagram*/
		private function reDrawDiagram()
		{
			var i ;
			
			//HTitleList = new Vector.<InstaTitle>();
			//VTitleList = new Vector.<InstaTitle>();
			
			var pose:Number ;
			
			if(isLock || !isChanged)
			{
				trace('Diagram is lock now');
				return ;
			}
			clearOldDiagram();
			//Drae diagramm
			
			/**My Dynaic Titles*/
			myTitles = new InstagramTitles();
			
			/**maximon steps available   Height - vTitleHeights*/
			var maxHeight:Number ;
			maxHeight = Height - vTitleHeights;
			
			/**Width - InstagramConstants.HTitle_margin*2-InstagramConstants.VTilte_width*/
			var diagramMinX:Number = InstagramConstants.VTilte_width+InstagramConstants.HTitle_margin;
			var diagramMaxX:Number = Width - InstagramConstants.HTitle_margin ;
			var diagramWidth:Number = diagramMaxX-diagramMinX ;
			
			var minHNumber:Number = Infinity ;
			var maxHNumber:Number = -Infinity;
			
			var minVNumber:Number = Infinity ;
			var maxVNumber:Number = -Infinity ;
			
			HLine.graphics.clear();
			HLine.graphics.lineStyle(InstagramConstants.Diagram_guide_line_thickness
				,InstagramConstants.diagram_guide_linke_color);
			HLine.graphics.lineTo(0,maxHeight);
			HLine.visible = false ;
			
			VLine.graphics.clear();
			VLine.graphics.lineStyle(InstagramConstants.Diagram_guide_line_thickness
				,InstagramConstants.diagram_guide_linke_color);
			VLine.graphics.lineTo(Width-InstagramConstants.VTilte_width,0);
			VLine.x = InstagramConstants.VTilte_width ;
			VLine.visible = false ;
			
			
			for(i = 0 ; i < myDiagramDatas.length && myDiagramDatas[i].values.length > 0 ; i++)
			{
				minHNumber = Math.min(myDiagramDatas[i].values[0].Hval,minHNumber);
				maxHNumber = Math.max(myDiagramDatas[i].values[myDiagramDatas[i].values.length-1].Hval,maxHNumber);
				
				for(var j = 0 ; j<myDiagramDatas[i].values.length ; j++)
				{
					var vVal:Number = myDiagramDatas[i].values[j].Vval ;
					minVNumber = Math.min(minVNumber,vVal) ;
					//trace("min val : "+minVNumber,vVal);
					maxVNumber = Math.max(maxVNumber,vVal) ;
					
					myTitles.addHTitle(new InstaTitleValue(myDiagramDatas[i].values[j].Hval));
				}
			}
			
			if(minVNumber==maxVNumber)
			{
				if(minVNumber>0)
				{
					minVNumber = 0 ;
				}
				else
				{
					maxVNumber+=1;
				}
			}
			
			/**No title can be less than this number , it can takes from pushedTitles*/
			var realMinimom:Number = 0 ;
			/**No title can be more than this number , it can takes from pushedTitles*/
			var realMaximom:Number = Infinity ;
			
			if(pushedTitles != null && pushedTitles.vTitle.length>0)
			{
				//trace("min val2 : "+pushedTitles.vTitle[0].value);
				realMinimom = minVNumber = Math.min(pushedTitles.vTitle[0].value,minVNumber);
				realMaximom = maxVNumber = Math.max(pushedTitles.vTitle[pushedTitles.vTitle.length-1].value,maxVNumber);
			}
			
			//trace("minHNumber : "+minHNumber);
			//trace("maxHNumber : "+maxHNumber);
			
			//trace("minVNumber : "+minVNumber+' < '+realMinimom);
			//trace("maxVNumber : "+maxVNumber+' < '+realMaximom);
			
			
			//Generate myTitles ↓
			
				//debug lines
					/*trace(11+" : "+log10(11));
					trace(98+" : "+log10(98));
					trace(120+" : "+log10(120));
					trace(5+" : "+log10(5));
					trace(0.1+" : "+log10(0.1));
					trace(0.3+" : "+log10(0.3));
					return;*/
				
				//1- Maximom steps :
				//trace("0-1 maxHeight : "+maxHeight); 
				var maxTitleNumber:uint  = Math.floor(maxHeight/vTitleHeights);
				maxTitleNumber = dividableBy5(maxTitleNumber);
				//trace("1-maxTitleNumber : "+maxTitleNumber);
				/**n*///it doesn't need to increase 2 step from available places because, from now, titles can be at the toppest and bottomest places on the diagram.
				var availableTitleNumbers:uint = Math.max(1, maxTitleNumber/*-2*/) ;
				//trace("2-availableTitleNumbers : "+availableTitleNumbers);
				//2- delta phase on availableTitileNumbers
				var deltaPhase:Number = maxVNumber - minVNumber ;
				//trace("3-deltaPhase : "+deltaPhase);
				/**m*/
				var pureSteps:Number
				if (InstagramConstants.fixVerticalSteps)
				pureSteps = 1 ;
				else
				pureSteps = deltaPhase / availableTitleNumbers ;
				//trace("4-pureSteps : "+pureSteps);
				//3- find steps level ( 10 , 100 , 1000 , ... )
				/**o*/
				var stepsPower:Number = log10(pureSteps);
				//trace('5-stepsPower : '+stepsPower);
				/**p*/
				var smallSteps:Number = pureSteps/stepsPower ;
				//trace('6-smallSteps : '+smallSteps);
				var steps:Number = stepsPower * Math.round(smallSteps);
				//trace('7-steps : '+steps);
				var minStep:Number = Math.max(realMinimom, Math.floor(minVNumber / steps) * steps);
				//trace("8-minStep : "+minStep);
				
				var vTitleTemp:String ;
				var vStepValTemp:Number ;
				var vValueTemp:InstaTitleValue ;
				do
				{
					vTitleTemp = '' ;
					vStepValTemp = Math.min(minStep,realMaximom) ;
					if(pushedTitles!=null)
					{
						vValueTemp = pushedTitles.getVName(vStepValTemp,steps);
						if(vValueTemp!=null)
						{
							vStepValTemp = vValueTemp.value ;
							vTitleTemp = vValueTemp.title ;
						}
					}
					myTitles.addVTitle(new InstaTitleValue(vStepValTemp,vTitleTemp));
					//trace("steps : "+minStep);
					minStep+=steps;
				}while(minStep-steps<maxVNumber);
				//It makes maxLevel shows the wrong value
				//maxVNumber = minStep-steps ;
				
				//trace("VTitles : "+myTitles.vTitle);
				
				//Change the min and max : 
				minVNumber = Math.min(myTitles.vTitle[0].value,minVNumber); 
				maxVNumber = Math.max(myTitles.vTitle[myTitles.vTitle.length-1].value,maxVNumber); 
				
			//trace("minVNumber : "+minVNumber+" maxVNumber : "+maxVNumber);
			
			//Draw vertical titles ↓
			
			var vtitleHeightDisplayObjects:Number = maxHeight;//(maxHeight-vTitleHeights) ;
			var newTitle:InstaTitle;
			/*if( pushedTitles == null || pushedTitles.vTitle.length == 0 )
			{*/
			
			for( i = 0 ; i<myTitles.vTitle.length ; i++)
			{
				newTitle = new InstaTitle();
				//debug 
					/*newTitle.graphics.beginFill(0xff0000);
					newTitle.graphics.drawCircle(0,0,5);*/
				newTitle.width = InstagramConstants.VTilte_width ;
				newTitle.addVerticalLeverMeter() ;
				
				//VTitleList.push(newTitle);
				
				newTitle.text = titleSplitter(myTitles.vTitle[i].title) ;
				this.addChild(newTitle) ;
				pose = vtitleHeightDisplayObjects-generatePrecent(myTitles.vTitle[i],minVNumber,maxVNumber)*vtitleHeightDisplayObjects ;
				newTitle.y = pose - newTitle.height/2 ;
				
				myTitles.vTitle[i].position = pose;
			}
				
			/**From now, the only way to generate titles is to set them on the myTitles first.*/
			/*}
			else
			{
				for( i = 0 ; i<pushedTitles.vTitle.length ; i++)
				{
					newTitle = new InstaTitle();
					newTitle.width = InstagramConstants.VTilte_width ;
					newTitle.addVerticalLeverMeter();
					
					//VTitleList.push(newTitle);
					
					newTitle.text = titleSplitter(pushedTitles.vTitle[i].title) ;
					this.addChild(newTitle);
					
					pose = vtitleHeightDisplayObjects-generatePrecent(pushedTitles.vTitle[i],minVNumber,maxVNumber)*vtitleHeightDisplayObjects;
					
					newTitle.y = pose - newTitle.height/2;
					
					trace("pose : "+pose);
					
						//myTitles.vTitle[i].position = pose ;
					//93-09-01 I change top line to buttom ↓ to controll errors when no insta data is entered
					pushedTitles.vTitle[i].position = pose ;
				}
			}*/
			
			
			//Draw Horizontal datas
			
			if(myTitles.hTitle.length<1)
			{
				trace('This is not a diagram . control inputs');
				return ;
			}
			
			for( i = 0 ; pushedTitles!= null && i<pushedTitles.hTitle.length ; i++)
			{
				myTitles.addHTitle(pushedTitles.hTitle[i]);
			}
			
			
			var deltaX:Number = (diagramWidth)/(myTitles.hTitle.length-1);
			for( i = 0 ; i< myTitles.hTitle.length ; i++)
			{
				newTitle = new InstaTitle();
				newTitle.width = InstagramConstants.HTitle_width ;
				newTitle.text = myTitles.hTitle[i].title ;
				newTitle.y = maxHeight ;
				pose = diagramMinX + i*deltaX ;
				newTitle.addHorizontalLeverMeter();
				newTitle.x = pose - InstagramConstants.HTitle_width/2 ;
				myTitles.hTitle[i].position = pose;
				//HTitleList.push(newTitle);
				
				this.addChild(newTitle);
			}
			
			
		//Draw Lines
			this.graphics.lineStyle(InstagramConstants.Diagram_colors,InstagramConstants.Diagram_thickness,1,false,"normal",null,JointStyle.MITER,0);
			this.graphics.moveTo(InstagramConstants.VTilte_width,0);
			this.graphics.lineTo(InstagramConstants.VTilte_width,maxHeight);
			this.graphics.lineTo(Width,maxHeight);
			this.graphics.endFill();
			
			
			//Draw diagram ↓
			
			for(i = 0 ; i<myDiagramDatas.length ; i++)
			{
				var diagram:DiagramLines = new DiagramLines(myDiagramDatas[i],diagramWidth,maxHeight,myTitles);
				diagram.x = diagramMinX ;
				diagram.y = 0 ;
				this.addChild(diagram) ;
				diagramsPrevList.push(diagram);
			}
			
			//Reset this variable
			isChanged = false ;
		}
		
		
		private function generatePrecent(titleData:InstaTitleValue,min:Number,max:Number):Number
		{
			//trace(titleData.value,min,max)
			//trace("("+titleData.value+"-"+min+")/("+max+"-"+min+") = "+((titleData.value-min)/(max-min)));
			return (titleData.value-min)/(max-min);
		}
		
		/**Clear the old diagram interfaces*/
		private function clearOldDiagram()
		{
			//clear diagram
			diagramsPrevList = new Vector.<DiagramPreveiw>();
			this.removeChildren();
			
			this.addChild(HLine);
			this.addChild(VLine);
		}
		
		
	/////////////Math
		private function log10(x:Number):Number
		{
			if(x<0)
			{
				throw "x<0 not supports";
			}
			var log:Number = 1;
			if(x>10)
			{
				do
				{
					log*=10 ;
				}while(x/log > 10)
			}
			else if(x<1)
			{
				do
				{
					log/=10 ;
				}while(x/log < 1)
			}
			else
			{
				return log ;
			}
			
			
				
			return log;
		}
		
		/**returns the number that can devide by 5*/
		private function dividableBy5(number:uint):uint
		{
			return Math.abs(number-number%5);
		}
		
		/**Split titles if theyr length are more than this number*/
		private function titleSplitter(title:String,availableChars:uint = InstagramConstants.availableCharsOnTitles)
		{
			availableChars = Math.min(availableChars,title.length);
			return title.substring(0,availableChars);
		}
	}
}