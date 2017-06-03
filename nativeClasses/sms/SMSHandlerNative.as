package nativeClasses.sms
{
	//import com.doitflash.air.extensions.sms.SMS;
	//import com.doitflash.air.extensions.sms.SMSEvent;
	
	import com.doitflash.air.extensions.sms.SMS;
	
	import dataManager.GlobalStorage;
	
	import flash.events.Event;
	import flash.utils.getDefinitionByName;
	
	//import com.doitflash.air.extensions.sms.SMS;
	
	public class SMSHandlerNative
	{
		/**com.doitflash.air.extensions.sms.SMS*/
		private static var smsClass:Class ;
		
		/**com.doitflash.air.extensions.sms.SMSEvent*/
		private static var smsEventObject:Class ;
		
		private static var sms:SMS ;
		
		private static const smsid:String = '468456456';
		
		private static var 	onDone:Function,
							onFaild:Function,
							
							onMessageReceived:Function;

		private static var lastSMSId:uint;
		
		private static const id_lastsms_id:String = "id_lastsms_id" ;
		
		public static function setUp():void
		{
			lastSMSId = uint(GlobalStorage.load(id_lastsms_id));
			if(sms==null && DevicePrefrence.isAndroid())
			{
				try
				{
					smsClass = getDefinitionByName("com.doitflash.air.extensions.sms.SMS") as Class;
					smsEventObject = getDefinitionByName("com.doitflash.air.extensions.sms.SMSEvent") as Class;
					sms = new smsClass();
				}
				catch(e)
				{
					smsClass = null ;
					trace("com.doitflash.air.extensions.sms.SMS is not imported : "+e);
				}
				/*if(smsClass!=null)
				{
					getLastReceivedSMS();
				}*/
			}
		}
		
		/**Get loast sms id
		private static function getLastReceivedSMS():void
		{
			trace("--------lastSMSId:"+lastSMSId);
			//sms.getSmsAfterId(lastSMSId);
			sms.addEventListener((smsEventObject as Object).SMS_RECEIVED,controllReceivedSMSToGetLastOne);
			sms.addEventListener((smsEventObject as Object).NEW_RECEIVED_SMS,controllReceivedSMSToGetLastOne);
			sms.addEventListener((smsEventObject as Object).NEW_PERIOD_SMS,controllReceivedSMSToGetLastOne);
			
		}
		
			protected static function controllReceivedSMSToGetLastOne(event:Event):void
			{
				trace("event :"+event);
				sms.removeEventListener((smsEventObject as Object).SMS_RECEIVED,controllReceivedSMSToGetLastOne);
				sms.removeEventListener((smsEventObject as Object).NEW_RECEIVED_SMS,controllReceivedSMSToGetLastOne);
				sms.removeEventListener((smsEventObject as Object).NEW_PERIOD_SMS,controllReceivedSMSToGetLastOne);
				
				var _smsArray:Array = sms.smsArray ; 
				trace("--------_smsArray:"+_smsArray) ;
				lastSMSId = _smsArray[0].id ;
				GlobalStorage.save(id_lastsms_id,lastSMSId) ;
				trace("---------------------lastSMSId-------------------> "+lastSMSId) ;
				sms.dispose() ;
				sms = new smsClass() ;
			}*/
		
	///////////////////////////////////////////////////////////////////////////////////////
		
		/**Be ready to get message*/
		public static function listenToGetMessage(onGet:Function,myNumberToListen:uint=785180):void
		{
			if(sms==null)
			{
				trace("SMS native is not supports on this device");
				return ;
			}
			onMessageReceived = onGet ;
			
			//It can get the last sms ids
			//sms.updateSms();
			//var _smsArray:Array = sms.smsArray; 
			//var lastSMSId:uint = _smsArray[0].id ;
			
			//trace("---------------------lastSMSId-------------------> "+lastSMSId);

			trace(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> SMS are : "+sms.conversationArray);
			
			sms.addEventListener((smsEventObject as Object).SMS_RECEIVED,controllReceivedSMS);
			sms.addEventListener((smsEventObject as Object).NEW_RECEIVED_SMS,controllReceivedSMS);
			sms.addEventListener((smsEventObject as Object).NEW_PERIOD_SMS,controllReceivedSMS);
			sms.getSmsAfterId(lastSMSId);

			trace("Listen to sms receive...");
			//sms.updateNewSms();
		}
		
		public static function canselListenToGetMessage():void
		{
			if(sms==null)
			{
				trace("SMS native is not supports on this device");
				return ;
			}
			
			trace("Cansel listening to sms");
			
			sms.removeEventListener((smsEventObject as Object).SMS_RECEIVED,controllReceivedSMS);
			sms.removeEventListener((smsEventObject as Object).NEW_RECEIVED_SMS,controllReceivedSMS);
			sms.removeEventListener((smsEventObject as Object).NEW_PERIOD_SMS,controllReceivedSMS);
			onMessageReceived = null ;
		}
		
		/**SMS received- if you whant to cansel listening to it, call CanselListenToGetMessage()*/
		protected static function controllReceivedSMS(event:*):void
		{
			trace("SMSs2 are : "+JSON.stringify(sms.smsArrayAfterId));
			//clearInterval(intervalId);
			trace("receved sms is : "+JSON.stringify(event.param,null,' '));
			onMessageReceived();//Dont delete this functin, more sms may come to
		}
	
	///////////////////////////////////////////////////////////////////////////////////////
		
		public static function sendMessage(phoneNumber:String,body:String,onDoneFunction:Function,onFaildFunction:Function):void
		{
			setUp();
			
			onDone = onDoneFunction ;
			onFaild = onFaildFunction ;
			if(sms)
			{
				sms.addEventListener((smsEventObject as Object).SEND_ERROR,sendingFaild);
				sms.addEventListener((smsEventObject as Object).DELIVERY_FAILED,sendingFaild);
				sms.addEventListener((smsEventObject as Object).SEND_SUCCESS,listenToAnswer);
				
				sms.sendSms(phoneNumber,body,smsid);
			}
		}
		
		protected static function listenToAnswer(event:*):void
		{
			trace("SmS snet..."+JSON.stringify(event.param,null,' '));
			trace("SMSs1 are : "+JSON.stringify(sms.smsArray));
			sms.removeEventListener((smsEventObject as Object).SEND_SUCCESS,listenToAnswer);
			
			onFaild = null ;
			calAndDeletFunction(onDone) ;
		}
		
		protected static function sendingFaild(event:Event):void
		{
			trace("Sending fails");
			sms.removeEventListener((smsEventObject as Object).SEND_ERROR,sendingFaild);
			sms.removeEventListener((smsEventObject as Object).DELIVERY_FAILED,sendingFaild);
			sms.removeEventListener((smsEventObject as Object).SEND_SUCCESS,listenToAnswer);
			onDone = null ;
			calAndDeletFunction(onFaild);
		}
		
	////////////////////////////////////////////////////////////
		
		/**Call and delete this function*/
		private static function calAndDeletFunction(func:Function,params:String=null):void
		{
			var cashedFunc:Function = func ;
			func = null ;
			if(params!=null && cashedFunc.length>0)
			{
				cashedFunc(params);
			}
			else
			{
				cashedFunc();
			}
		}
	}
}