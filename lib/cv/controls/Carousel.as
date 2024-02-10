
package cv.controls {
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Graphics;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.events.Event;
	
	import gs.TweenLite;
	//import gs.OverwriteManager;
	
	public class Carousel extends Sprite {
		
		public static const TOP:String = "TOP";
		public static const BOTTOM:String = "BOTTOM";
		public static const LEFT:int = -1;
		public static const RIGHT:int = 1;
		public static const CENTER:String = "CENTER";
		public static const ITEM_ADDED:String = "ITEM_ADDED";
		public static const ITEM_REMOVED:String = "ITEM_REMOVED";
		public static const CHANGE:String = "CHANGE";
		public static const NEXT:String = "NEXT";
		public static const PREVIOUS:String = "PREVIOUS";
		
		/**
		 * Will automatically fade items as they near edges
		 */
		public var autoAlpha:Boolean = false;
		
		private var _align:String = CENTER;
		private var _ease:Function = TweenLite.defaultEase;
		private var _height:Number;
		private var _mask:DisplayObject;
		private var _selected:DisplayObject;
		private var _selectedPrevious:DisplayObject;
		private var _spacing:Number = 0;
		private var _tweenTime:Number = 0.5;
		private var _width:Number;
		private var arrItems:Array = new Array();
		private var index:int = 0;
		private var sprHolder:Sprite = new Sprite();
		private var sprMask:Sprite = new Sprite();
		private var tl:TweenLite;
		private var tweenObject:Object = new Object();
		
		// Turns on lines and borders to debug issues
		private var debug:Boolean = false;
		
		public function Carousel(spacing:Number=0, height:Number=20, width:Number=100) {
			_spacing = spacing;
			_height = height;
			_width = width;
			tweenObject.radian = 0;
			
			//OverwriteManager.init(OverwriteManager.ALL); 
			
			addChild(sprHolder);
			addChild(sprMask);
			
			if(debug) {
				this.graphics.lineStyle(1, 0xFF0000);
				this.graphics.moveTo(_width / 2, 0);
				this.graphics.lineTo(_width / 2, _height);
				this.graphics.drawRect(0, 0, _width, _height);
			}
			
			sprHolder.mask = sprMask;
			draw();
		}
		
		//--------------------------------------
		//  Properties
		//--------------------------------------
		
		/**
		* Gets/Sets the vertical alignment of items
		*/
		public function get align():String { return _align; }
		/**
		* @private
		*/
		public function set align(value:String):void {
			// validation
			switch(value) {
				case TOP:
				case CENTER:
				case BOTTOM:
					break;
				default :
					return;
			}
			
			_align = value;
		}
		
		/**
		 * Gets/Sets height of carousel
		 */
		override public function get height():Number { return _height; }
		/**
		* @private
		*/
		override public function set height(value:Number):void {
			_height = value;
			draw();
		}
		
		/**
		 * Gets the array of items
		 */
		public function get items():Array { return arrItems; }
		
		/**
		 * Gets the selected item
		 */
		public function get selected():DisplayObject { return _selected; }
		
		public function set selected(value:DisplayObject):void {
			selectItem(value);
		}
		
		public function get selectedIndex():int { return index; }
		
		public function set selectedIndex(value:int):void {
			selectIndex(value);
		}
		
		/**
		 * Gets the previously selected item
		 */
		public function get selectedPrevious():DisplayObject { return _selectedPrevious; }
		
		/**
		 * Gets/Sets spacing between items. Modifies radius of carousel.
		 */
		public function get spacing():Number { return _spacing; }
		/**
		* @private
		*/
		public function set spacing(value:Number):void {
			_spacing = value;
		}
		
		/**
		* Gets/Sets duration of the tween
		*
		* @default 1
		*/
		public function get tweenTime():Number { return _tweenTime; }
		/**
		* @private
		*/
		public function set tweenTime(value:Number):void {
			_tweenTime = value;
		}
		
		/**
		 * Gets/Sets type of easing function to use
		 */
		public function get tweenType():Function { return _ease; }
		/**
		* @private
		*/
		public function set tweenType(value:Function):void {
			_ease = value;
		}
		
		/**
		 * Gets/Sets width of carousel
		 */
		override public function get width():Number { return _width; }
		/**
		* @private
		*/
		override public function set width(value:Number):void {
			_width = value;
			draw();
		}
		
		//--------------------------------------
		//  Methods
		//--------------------------------------
		
		/**
		 * Adds an item to the carousel.
		 * 
		 * @param	item Item to be added
		 */
		public function addItem(item:DisplayObject):void {
			addItemAt(item, 0);
		}
		
		/**
		 * Adds an item to the carousel at a specific index.
		 * 
		 * @param	item Item to be added
		 * @param	idx	Index to add item at
		 */
		public function addItemAt(item:DisplayObject, idx:uint):void {
			var temp:Array = arrItems.splice(idx);
			arrItems[idx] = item;
			arrItems = arrItems.concat(temp);
			
			if(item is DisplayObjectContainer && debug) {
				var shp:Shape = new Shape();
				var bnds:Rectangle = item.getRect(item);
				shp.graphics.lineStyle(1, 0xFF0000);
				shp.graphics.moveTo(bnds.width / 2, bnds.top);
				shp.graphics.lineTo(bnds.width / 2, bnds.bottom);
				shp.graphics.drawRect(bnds.left, bnds.top, bnds.width, bnds.height);
				DisplayObjectContainer(item).addChild(shp);
			}
			
			sprHolder.addChild(item);
			render();
			
			// For some reason if render is only called once, the center item is not 
			// selected correctly til user hits next or previous
			render();
			dispatchEvent(new Event(ITEM_ADDED));
		}
		
		/**
		 * Move carousel right
		 * 
		 * @param	amount Amount to move the carousel by
		 */
		public function next(amount:uint = 1):void {
			move(amount, 1);
			dispatchEvent(new Event(NEXT));
		}
		
		/**
		 * Move carousel left
		 * 
		 * @param	amount Amount to move the carousel by
		 */
		public function previous(amount:uint = 1):void {
			move(amount, -1);
			dispatchEvent(new Event(PREVIOUS));
		}
		
		/**
		 * Remove the last item in the array
		 * 
		 * @return The item removed
		 */
		public function removeItem():DisplayObject {
			return removeItemAt(arrItems.length - 1);
		}
		
		/**
		 * Remove an item at the specified index
		 * 
		 * @param	idx	The index to remove an item at
		 * @return	The item removed
		 */
		public function removeItemAt(idx:uint):DisplayObject {
			var arrItem:Array = arrItems.splice(idx, 1);
			var item:DisplayObject = sprHolder.removeChild(arrItem[0]);
			dispatchEvent(new Event(ITEM_REMOVED));
			
			return item;
		}
		
		/**
		 * Select the specified item in the carousel
		 * 
		 * @param	item The item to select
		 * @return	If the item was selected successfully or not
		 */
		public function selectItem(item:DisplayObject):Boolean {
			var idx:int;
			var len:uint = arrItems.length;
			for (var i:uint = 0; i < len; i++) {
				if (arrItems[i] === item) {
					idx = i;
					break;
				}
			}
			
			// Find shortest path to item
			if (item.x > _selected.x && idx > index) {
				idx = 0 - (len - idx);
			} else if (item.x < _selected.x && idx < index) {
				idx = idx + len;
			}
			
			if(!isNaN(idx)) {
				var delta:int = abs(index - idx);
				if (idx > index) {
					previous(delta);
				} else {
					next(delta);
				}
				return true;
			} else {
				trace("Carousel - Error: Can't find item");
				return false;
			}
		}
		
		public function selectIndex(idx:int):Boolean {
			var item:DisplayObject = arrItems[idx];
			var len:uint = arrItems.length;
			if (item) {
				// Find shortest path to item
				if (item.x > _selected.x && idx > index) {
					idx = 0 - (len - idx);
				} else if (item.x < _selected.x && idx < index) {
					idx = idx + len;
				}
				
				var delta:int = abs(index - idx);
				if (idx > index) {
					previous(delta);
				} else {
					next(delta);
				}
				return true;
			} else {
				trace("Carousel - Error: Can't find item");
				return false;
			}
		}
		
		//--------------------------------------
		//  Private
		//--------------------------------------
		
		private function abs(value:Number):Number {
			return (value < 0) ? -value : value;
		}
		
		private function dispatchChange():void {
			render();
			dispatchEvent(new Event(CHANGE));
		}
		
		/**
		 * Update mask size
		 */
		private function draw():void {
			var g:Graphics = sprMask.graphics;
			g.clear();
			g.beginFill(0xFF0000, 0);
			g.drawRect(0, 0, _width, _height);
			g.endFill();
		}
		
		private function move(amount:uint, direction:int):void {
			var moveAmount:Number = amount * (Math.PI * 2 / arrItems.length);
			if (tl && tl.active) tl.complete();
			tl = TweenLite.to(tweenObject, _tweenTime, { radian:String(moveAmount * direction), ease:_ease, onComplete:dispatchChange, onUpdate:render } );
		}
		
		private function render(e:Event = null):void {
			var i:int = arrItems.length;
			if(i > 0) {
				var j:Number;
				var item:DisplayObject;
				var bnds:Rectangle;
				
				var nextRad:Number;
				var nextX:Number;
				
				var itemRad:Number;
				var itemCenter:Number;
				var itemAlpha:Number;
				var itemX:Number;
				var itemOffSet:Number;
				
				var radius:Number = (_width / 2) + _spacing;
				var centerX:Number = (_width / 2);
				
				var closestItem:DisplayObject = arrItems[0];
				var closestIndex:int = 0;
				var closestCenter:Number;
				var closestBounds:Rectangle = closestItem.getRect(sprHolder);
				
				var yCoord:Number = 0;
				
				// Redraw boundries
				if(debug) {
					this.graphics.clear();
					this.graphics.lineStyle(1, 0xFF0000);
					this.graphics.moveTo(_width / 2, 0);
					this.graphics.lineTo(_width / 2, _height);
					this.graphics.drawRect(0, 0, _width, _height);
					this.graphics.lineStyle(1, 0x0000FF);
				}
				
				while (i--) {
					item = arrItems[i];
					bnds = item.getRect(sprHolder);
					itemCenter = bnds.left + (bnds.width / 2);
					
					// Get starting x coord of item section
					itemRad = (Math.PI * 2 / arrItems.length * i);
					itemX = radius * Math.cos((itemRad + tweenObject.radian));
					
					// Get ending x coord of item section
					nextRad = (Math.PI * 2 / arrItems.length * (i + 1));
					nextX = radius * Math.cos((nextRad + tweenObject.radian));
					
					// Get offset to center item between both x coordinates
					itemOffSet = ((nextX - itemX) / 2) - (bnds.width / 2);
					
					// Set X Position
					item.x = centerX + itemX + itemOffSet;
					
					// Set Y Position
					switch(_align) {
						case TOP:
							yCoord = 0;
							break;
						case CENTER :
							yCoord = (_height - bnds.height) / 2;
							break;
						case BOTTOM :
							yCoord = _height - bnds.height;
							break;
					}
					item.y = yCoord;
					
					// Set alpha/visibility
					itemAlpha = Math.sin((itemRad + tweenObject.radian));
					if (autoAlpha) item.alpha =  itemAlpha;
					if (itemAlpha <= 0) {
						item.visible = false;
					} else {
						item.visible = true;
						
						// Draw dividing lines
						if(debug) {
							this.graphics.moveTo(centerX + itemX, 0);
							this.graphics.lineTo(centerX + itemX, _height - 20);
							this.graphics.lineTo(centerX + itemX + 10, _height - 20);
						}
					}
					
					closestCenter = closestBounds.left + (closestBounds.width / 2);
					if (item.visible) {
						if (abs(itemCenter - centerX) < abs(closestCenter - centerX)) {
							// Find Center Item
							closestItem = item;
							closestBounds = bnds;
							closestIndex = i;
						} else if (closestItem.visible == false) {
							// If the closest item is no longer visible, let it be overridden by an item that is visible
							closestItem = item;
							closestBounds = bnds;
							closestIndex = i;
							i = arrItems.length;
						}
					}
				}
				
				_selectedPrevious = _selected;
				_selected = closestItem;
				index = closestIndex;
			} else {
				_selectedPrevious = _selected;
				_selected = null;
				index = NaN;
			}
		}
	}
}