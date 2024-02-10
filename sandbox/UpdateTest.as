package {
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.utils.getTimer;
	import flash.utils.Dictionary;
	
	public class UpdateTest extends MovieClip {
		
		private var list:Array = new Array();
		private var dict:Dictionary = new Dictionary();
		private var mc:MovieClip;
		
		public static var ts:Number;
		public static var reportTimes:int = 0;
		public static var isFirst:Boolean = false;
		public static var activeTicker:FrameTicker;
		
		public function UpdateTest() {
			activeTicker = new FrameTicker();
			
			//Create the source
			for (var i:uint = 0; i < 15000; i++) {
				mc = new Circle();
				
				// Uncomment for Dictionary Test
				//dict[mc] = mc;
				// Uncomment for Array Test
				list.push(mc);
				
				this.addChild(mc);
			}
			
			// Uncomment for Array/Dictionary Test
			//this.addEventListener(Event.ENTER_FRAME, updateAll, false, 0, true);
			activeTicker.addEventListener("tick", updateAll, false, 0, true);
			
			this.addEventListener(Event.EXIT_FRAME, onExit, false, 0, true);
		}
		
		private function onExit(e:Event):void {
			if(isFirst) endTimer();
		}
		
		private function updateAll(e:Event):void {
			startTimer();
			
			/*
			Dictionary & Loop: 8ms  10k
			Dictionary & Loop: 10ms 15k
			*/
			// Dictionary
			/*for each (mc in dict) {
				mc.update();
			}*/
			
			/*
			Array & Loop: 4ms   10k
			Array & Loop: 6-7ms 15k (sprinkled with a few 5ms)
			*/
			// Array
			var i:int = list.length;
			while (i--) {
				list[i].update();
			}
		}
		
		public static function startTimer():void{
			ts = getTimer();
			isFirst = true;
		}
		
		public static function endTimer():void {
			if(reportTimes < 10) {
				trace("Array & Loop: " + (getTimer() - ts) + "ms");
				//trace("Dictionary & Loop: " + (getTimer() - ts) + "ms");
				//trace("Listener: " + (getTimer() - ts) + "ms");
				reportTimes++;
			}
			isFirst = false;
		}
	}
}
import flash.display.MovieClip;
import flash.display.Shape;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.TimerEvent;
import flash.utils.Timer;

class FrameTicker extends EventDispatcher {
	
	protected var shape:Shape;
	
	public function FrameTicker():void {
		shape = new Shape();
		shape.addEventListener(Event.ENTER_FRAME, tick);
	}
	
	protected function tick(evt:Event):void {
		dispatchEvent(new Event("tick"));
	}
}

class Circle extends MovieClip {
	
	public function Circle():void {
		this.graphics.beginFill(0xFF0000, 1);
		this.graphics.drawCircle(-5, -5, 10);
		this.graphics.endFill();
		this.x = 200;
		this.y = 200;
		
		// Uncomment for Listener Test
		//this.addEventListener(Event.ENTER_FRAME, updateOne, false, 0, true);
		//UpdateTest.activeTicker.addEventListener("tick", updateOne, false, 0, true);
	}
	
	/*
	Static Ticker Listener: 5ms   10k
	Static Ticker Listener: 8-9ms 15k
	Enter_Frame Listener: 85ms 10k
	*/
	private function updateOne(e:Event):void {
		if (!UpdateTest.isFirst) UpdateTest.startTimer();
		update();
	}
	
	public function update():void {
		this.x += 1;
		if (this.x < 0) this.x = 550;
	}
}