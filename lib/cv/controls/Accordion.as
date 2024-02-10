
package cv.controls {
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import cv.controls.AccordionItem;

	public class Accordion extends Sprite {
		
		private var arrItems:Array = new Array();
		private var _width:Number = 0;
		private var _height:Number = 0;
		private var sprEf:Sprite = new Sprite();
		
		public function Accordion() {
			init();
		}
		
		private function init():void {
			sprEf.addEventListener(Event.ENTER_FRAME, onEnterFrameHandler);
		}
		
		public function get numItems():int {
			return arrItems.length;
		}
		
		public function get selectedItem():Object {
			return {};
		}
		
		public function get selectedHeader():String {
			return '';
		}

		public function get selectedIndex():int {
			return 0;
		}
		
		public function addItem(strLabel:String, sprContent:DisplayObject):void {
			var ai:AccordionItem = new AccordionItem(strLabel, sprContent);
			var aiPrev:AccordionItem = arrItems[arrItems.length - 1];
			//ai.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDownHandler);
			ai.addEventListener("ItemSelected", onItemSelectedHandler);
			ai.x = 0;
			ai.y = aiPrev ? aiPrev.y + aiPrev.height : 0;
			arrItems.push(ai);
			
			if(_width < ai.contentWidth) {
				_width = ai.contentWidth;
				setNewWidth();
			} else {
				ai.width = _width;
			}
			addChild(ai);
		}
		
		public function addItemAt(strLabel:String, sprContent:DisplayObject, nIndex:int):void {
			//
		}
		
		public function removeItemAt(nIndex:int):Boolean {
			return false;
		}
		
		public function removeAll():void {
			for(var i:String in arrItems) {
				removeChild(arrItems[i]);
			}
		}
		
		public function getItemAt(nIndex:int):Object {
			if(nIndex > 0 && nIndex < arrItems.length) return arrItems[nIndex];
			return null;
		}
		
		public function getHeaderAt(nIndex:int):String {
			if(nIndex > 0 && nIndex < arrItems.length) return arrItems[nIndex].label;
			return null;
		}
		
		private function setNewWidth():void {
			for(var i:String in arrItems) {
				arrItems[i].width = _width;
			}
		}
		
		private function onItemSelectedHandler(e:Event):void {
			var sprItem:AccordionItem = e.currentTarget as AccordionItem;
			for(var i:String in arrItems) {
				if(arrItems[i] != sprItem) {
					arrItems[i].close();
				} else {
					arrItems[i].toggle();
				}
			}
		}
		
		private function onMouseDownHandler(e:MouseEvent):void {
			var sprItem:AccordionItem = e.currentTarget as AccordionItem;
			for(var i:String in arrItems) {
				if(arrItems[i] != sprItem) {
					arrItems[i].close();
				} else {
					arrItems[i].toggle();
				}
			}
		}
		
		private function onEnterFrameHandler(e:Event):void {
			var l:int = arrItems.length;
			for(var i:int = 0; i < l; i++) {
				var curItem:AccordionItem = arrItems[i];
				if(i > 0) {
					var prevItem:AccordionItem = arrItems[i - 1];
					curItem.y = prevItem.y + prevItem.height;
				} else {
					curItem.y = 0;
				}
			}
		}
		
		// keyup
		// keydown
	}
}