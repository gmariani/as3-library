package {
	
	import flash.display.MovieClip;
	import flash.utils.getTimer;
	import flash.utils.Dictionary;
	
	public class LoopTest extends MovieClip {
		private var l:int;
		private var list:Array = new Array();
		private var dict:Dictionary = new Dictionary();
		private var obj:Object = new Object();
		
		public function LoopTest() {
			var i:uint;
			
			//Create the source array
			for(i = 0; i < 1000000; i++) {
				list.push(Math.random());
			}
			l = list.length;
			trace("List of " + l + " elements.");
			
			// Create the source dictionary
			/*for (i = 0; i < 500000; i++) {
				var n:Number = Math.random();
				dict[n] = n;
			}*/
			
			// Create the source object
			/*for (i = 0; i < 500000; i++) {
				var n:Number = Math.random();
				obj[n] = n;
			}*/
			
			// Create the source dictionary 2
			/*for (i = 0; i <= 500000; i++) {
				dict[i] = Math.random();
				dict["length"] = i;
			}
			trace("Dictionary of " + dict["length"] + " elements.");*/
			
			//test00(); // for() [uint inline & list.length]: 	1M 198ms, 204ms, 204ms
			//test0();  // for() [uint & list.length]: 			1M 199ms, 202ms, 205ms
			//test1();  // for() [uint & l]: 					1M 150ms, 157ms, 157ms
			//test2();  // for() [uint & l reverse]: 			1M 149ms, 140ms, 145ms
			//test3();  // for each in(): 						1M 160ms, 163ms, 164ms
			//test4();  // for in(): 							1M 583ms, 585ms, 586ms
			//test5();  // while() [i < l]: 					1M 139ms, 145ms, 142ms
			//test6();  // while() [i--]: 						1M 139ms, 144ms, 143ms <-----
			//test7();  // while() [i-- > 0]: 					1M 152ms, 154ms, 154ms
			//test8();  // do while(): 							1M 234ms, 236ms, 237ms
			//test18(); // Array.forEach(): 					1M 324ms, 326ms, 321ms
			
			//test9();  // Dictionary for each in() [local vars]: 	500k 90ms, 89ms, 90ms
			//test10(); // Dictionary for each in(): 				500k 87ms, 88ms, 88ms
			//test11(); // Dictionary for each in() [inline]: 		500k 88ms, 88ms, 87ms
			
			//test12(); // Object for each in() [local vars]: 		500k 93ms, 90ms, 92ms
			//test13(); // Object for each in(): 					500k 96ms, 93ms, 90ms
			//test14(); // Object for each in() [inline]: 			500k 98ms, 94ms, 91ms
			
			//test15(); // Dictionary while() [i < l]: 			1M 144ms, 142ms, 136ms / 500k 72ms, 70ms, 71ms
			//test16(); // Dictionary while() [i--]: 			1M 138ms, 138ms, 141ms / 500k 74ms, 70ms, 70ms <-----
			//test17(); // Dictionary while() [i-- > 0]: 		1M 153ms, 147ms, 149ms / 500k 74ms, 74ms, 75ms
		}
		
		public function test000():void {
			var ts:Number = getTimer();
			for(var i:Number = 0; i < list.length; i++) {
				var z:Number = Math.random();
			}
			trace("for() [Number & list.length]: " + (getTimer() - ts) + "ms");
		}
		
		public function test00():void {
			var ts:Number = getTimer();
			for(var i:uint = 0; i < list.length; i++) {
				var z:Number = Math.random();
			}
			trace("for() [uint inline & list.length]: " + (getTimer() - ts) + "ms");
		}
		
		public function test0():void {
			var ts:Number = getTimer();
			var i:uint;
			for(i = 0; i < list.length; i++) {
				var z:Number = Math.random();
			}
			trace("for() [uint & list.length]: " + (getTimer() - ts) + "ms");
		}
		
		public function test1():void {
			var ts:Number = getTimer();
			var i:uint;
			for(i = 0; i < l; i++) {
				var z:Number = Math.random();
			}
			trace("for() [uint & l]: " + (getTimer() - ts) + "ms");
		}
		
		public function test2():void {
			var ts:Number = getTimer();
			var i:int;
			var l2:int = l - 1;
			for(i = l2; i >= 0; i--) {
				var z:Number = Math.random();
			}
			trace("for() [uint & l reverse]: " + (getTimer() - ts) + "ms");
		}
		
		public function test3():void {
			var ts:Number = getTimer();
			var j:Number;
			for each(j in list) {
				var z:Number = Math.random();
			}
			trace("for each in(): " + (getTimer() - ts) + "ms");
		}
		
		public function test4():void {
			var ts:Number = getTimer();
			var m:String;
			for (m in list) {
				var z:Number = Math.random();
			}
			trace("for in(): " + (getTimer() - ts) + "ms");
		}
		
		public function test5():void {
			var ts:Number = getTimer();
			var i:int = 0;
			while(i < l) {
				var z:Number = Math.random();
				i++;
			}
			trace("while() [i < l]: "+(getTimer()-ts)+"ms");
		}
		
		public function test6():void {
			var ts:Number = getTimer();
			var i:int = l - 1; 
			while(i--) {
				var z:Number = Math.random();
			}
			trace("while() [i--]: "+(getTimer()-ts)+"ms");
		}
		
		public function test7():void {
			var ts:Number = getTimer();
			var i:uint = l;
			while( i-- > 0 ){
				var z:Number = Math.random();
			}
			trace("while() [i-- > 0]: "+(getTimer()-ts)+"ms");
		}
		
		public function test8():void {
			var ts:Number = getTimer();
			var i:int = l - 1; 
			do {
				var z:Number = Math.random();
			} while (i--);
			trace("do while(): "+(getTimer()-ts)+"ms");
		}
		
		public function test18():void {
			var ts:Number = getTimer();
			list.forEach(doRandom);
			trace("Array.forEach(): "+(getTimer()-ts)+"ms");
		}
		
		private function doRandom(item:*, index:int, arr:Array):void {
            var z:Number = Math.random();
        }
		
		// Dictionary Tests
		
		public function test9():void {
			var ts:Number = getTimer();
			var d:Dictionary = dict, e:Object;
			for each (e in d) {
				var z:Number = Math.random();
			}
			trace("Dictionary for each in() [local vars]: "+(getTimer()-ts)+"ms");
		}
		
		public function test10():void {
			var ts:Number = getTimer();
			var e:Object;
			for each (e in dict) {
				var z:Number = Math.random();
			}
			trace("Dictionary for each in(): "+(getTimer()-ts)+"ms");
		}
		
		public function test11():void {
			var ts:Number = getTimer();
			for each (var e:Object in dict) {
				var z:Number = Math.random();
			}
			trace("Dictionary for each in() [inline]: "+(getTimer()-ts)+"ms");
		}
		
		// Object Tests
		
		public function test12():void {
			var ts:Number = getTimer();
			var o:Object = obj, e:Object;
			for each (e in o) {
				var z:Number = Math.random();
			}
			trace("Object for each in() [local vars]: "+(getTimer()-ts)+"ms");
		}
		
		public function test13():void {
			var ts:Number = getTimer();
			var e:Object;
			for each (e in obj) {
				var z:Number = Math.random();
			}
			trace("Object for each in(): "+(getTimer()-ts)+"ms");
		}
		
		public function test14():void {
			var ts:Number = getTimer();
			for each (var e:Object in obj) {
				var z:Number = Math.random();
			}
			trace("Object for each in() [inline]: "+(getTimer()-ts)+"ms");
		}
		
		// Dictionary Tests 2
		
		public function test15():void {
			var ts:Number = getTimer();
			var i:int = 0;
			var l:int = dict["length"];
			while(i < l) {
				var z:Number = Math.random();
				i++;
			}
			trace("dictionary while() [i < l]: "+(getTimer()-ts)+"ms");
		}
		
		public function test16():void {
			var ts:Number = getTimer();
			var i:int = dict["length"] - 1; 
			while(i--) {
				var z:Number = Math.random();
			}
			trace("dictionary while() [i--]: "+(getTimer()-ts)+"ms");
		}
		
		public function test17():void {
			var ts:Number = getTimer();
			var i:uint = dict["length"];
			while( i-- > 0 ){
				var z:Number = Math.random();
			}
			trace("dictionary while() [i-- > 0]: "+(getTimer()-ts)+"ms");
		}
	}
}