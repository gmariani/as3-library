package {
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.utils.getTimer;
	import flash.utils.Dictionary;
	
	public class LoopTest2 extends MovieClip {
		
		private var _maxItems:uint = 1000000;
		private var createTimes:Array = [0, 0, 0, 0, 0];
		private var iterateTimes:Array = [0, 0, 0, 0, 0];
		
		public function LoopTest2() {
			// linkedListTest Create: 886.4ms / Iterate: 20ms - 5 Runs
			//runTest(linkedListTest, "linkedListTest", 5);
			
			// linkedListTest2 Create: 893.8ms / Iterate: 20.2ms - 5 Runs
			//runTest(linkedListTest2, "linkedListTest2", 5);
			
			// vectorTest Create: 973.2ms / Iterate: 468.4ms - 5 Runs
			//runTest(vectorTest, "vectorTest", 5);
			
			// vectorTest2 Create: 944ms / Iterate: 379.6ms - 5 Runs
			//runTest(vectorTest2, "vectorTest2", 5);
			
			// arrayTest Create: 985.4ms / Iterate: 407.4ms - 5 Runs
			//runTest(arrayTest, "arrayTest", 5);
			
			// arrayTest2 Create: 997.2ms / Iterate: 433ms - 5 Runs
			//runTest(arrayTest2, "arrayTest2", 5);
			
			// dictionaryTest Create: 991.4ms / Iterate: 410.2ms - 5 Runs
			//runTest(dictionaryTest, "dictionaryTest", 5);
			
			// dictionaryTest2 Create: 974.4ms / Iterate: 457.2ms - 5 Runs
			//runTest(dictionaryTest2, "dictionaryTest2", 5);
		}
		
		public function runTest(f:Function, name:String, runs:int = 5):void {
			var i:int = runs;
			while (--i > -1) {
				f(i);
			}
			
			trace(name + " Create: " + average(createTimes) + "ms / Iterate: " + average(iterateTimes) + "ms - " + runs + " Runs");
		}
		
		public function average(arr:Array):Number {
			return (arr[0] + arr[1] + arr[2] + arr[3] + arr[4]) / 5;
		}
		
		public function linkedListTest(index:int):void {
			// Create
			var ts:Number = getTimer();
			var _items:MyItem = new MyItem();
			var currentItem:MyItem = _items;
			var i:int = _maxItems;
			while (--i != 0) {
				currentItem = currentItem.next = new MyItem();
			}
			createTimes[index] = getTimer() - ts;
			
			// Iterate
			ts = getTimer();
			currentItem = _items;
			do {
				currentItem.data += 1;
				currentItem = currentItem.next;
			} while (currentItem);
			iterateTimes[index] = getTimer() - ts;
		}
		
		public function linkedListTest2(index:int):void {
			// Create
			var ts:Number = getTimer();
			var _items:MyItem = new MyItem();
			var currentItem:MyItem = _items;
			var i:int = _maxItems;
			while (--i != 0) {
				currentItem = currentItem.next = new MyItem();
			}
			createTimes[index] = getTimer() - ts;
			
			// Iterate
			ts = getTimer();
			currentItem = _items;
			while (currentItem) {
				currentItem.data += 1;
				currentItem = currentItem.next;
			}
			iterateTimes[index] = getTimer() - ts;
		}
		
		public function vectorTest(index:int):void {
			// Create
			var ts:Number = getTimer();
			var _items:Vector.<MyItem> = new Vector.<MyItem>(_maxItems, true);
			var i:int = _maxItems;
			while (--i) {
				_items[i] = new MyItem();
			}
			createTimes[index] = getTimer() - ts;
			
			// Iterate
			ts = getTimer();
			i = _maxItems - 1;
			do {
				_items[i].data += 1;
			} while (--i);
			iterateTimes[index] = getTimer() - ts;
		}
		
		public function vectorTest2(index:int):void {
			// Create
			var ts:Number = getTimer();
			var _items:Vector.<MyItem> = new Vector.<MyItem>(_maxItems, true);
			var i:int = _maxItems;
			while (--i) {
				_items[i] = new MyItem();
			}
			createTimes[index] = getTimer() - ts;
			
			// Iterate
			ts = getTimer();
			i = _maxItems - 1;
			while (--i) {
				_items[i].data += 1;
			}
			iterateTimes[index] = getTimer() - ts;
		}
		
		public function arrayTest(index:int):void {
			// Create
			var ts:Number = getTimer();
			var _items:Array = new Array(_maxItems);
			var i:int = _maxItems;
			while (--i) {
				_items[i] = new MyItem();
			}
			createTimes[index] = getTimer() - ts;
			
			// Iterate
			ts = getTimer();
			i = _maxItems - 1;
			do {
				_items[i].data += 1;
			} while (--i);
			iterateTimes[index] = getTimer() - ts;
		}
		
		public function arrayTest2(index:int):void {
			// Create
			var ts:Number = getTimer();
			var _items:Array = new Array(_maxItems);
			var i:int = _maxItems;
			while (--i) {
				_items[i] = new MyItem();
			}
			createTimes[index] = getTimer() - ts;
			
			// Iterate
			ts = getTimer();
			i = _maxItems - 1;
			while (--i) {
				_items[i].data += 1;
			}
			iterateTimes[index] = getTimer() - ts;
		}
		
		public function dictionaryTest(index:int):void {
			// Create
			var ts:Number = getTimer();
			var _items:Dictionary = new Dictionary();
			var i:int = _maxItems;
			while (--i) {
				_items[i] = new MyItem();
			}
			createTimes[index] = getTimer() - ts;
			
			// Iterate
			ts = getTimer();
			i = _maxItems - 1;
			do {
				_items[i].data += 1;
			} while (--i);
			iterateTimes[index] = getTimer() - ts;
		}
		
		public function dictionaryTest2(index:int):void {
			// Create
			var ts:Number = getTimer();
			var _items:Dictionary = new Dictionary();
			var i:int = _maxItems;
			while (--i) {
				_items[i] = new MyItem();
			}
			createTimes[index] = getTimer() - ts;
			
			// Iterate
			ts = getTimer();
			i = _maxItems - 1;
			while(--i) {
				_items[i].data += 1;
			}
			iterateTimes[index] = getTimer() - ts;
		}
	}
}


class MyItem {
	
	public var data:Number;
	
	public var next:MyItem;
	
	public function MyItem() {
		data = Math.random();
	}
}