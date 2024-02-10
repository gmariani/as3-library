package cv.managers {
	
	import flash.display.DisplayObject;
	import flash.events.EventDispatcher;
	import gs.TweenLite;
	import gs.easing.*;
	
	public class LayoutManager extends EventDispatcher {
		
		public static const LEFT:String = "LEFT";
		public static const TOP:String = "TOP";
		public static const CENTER:String = "CENTER";
		public static const RIGHT:String = "RIGHT";
		public static const BOTTOM:String = "BOTTOM";
		
		// Variables
		private var _items:Array = new Array();
		private var _layout:Array = new Array();
		private var _currentY:Number;
		private var _startY:Number;
		private var _startX:Number;
		private var _spacingX:Number;
		private var _spacingY:Number;
		private var _width:Number;
		private var _align:String = LEFT;
		private var _alignRow:String = TOP;
		private var _tween:Boolean = true;
		private var _tweenTime:Number = 1;
		private var _tweenType:Function = Regular.easeOut;
		
		/**
		* Constructor
		*
		* @param x			Starting X position
		* @param y			Starting Y position
		* @param xSpacing	Item X spacing
		* @param ySpacing	Item Y spacing
		* @param width		Boundary width
		*/
		public function LayoutManager(x:Number=0, y:Number=0, xSpacing:Number=10, ySpacing:Number=10, width:Number=1000) {
			_width = width;
			_spacingX = xSpacing;
			_spacingY = ySpacing;
			_startY = y;
			_currentY = y;
			_startX = x;
		}
		
		//--------------------------------------
		//  Properties
		//--------------------------------------
		
		/**
		* Indicates where tweening is on/off
		*
		* @default true
		*/
		public function get tween():Boolean {
			return _tween;
		}
		/**
		* @private
		*/
		public function set tween(val:Boolean):void {
			_tween = val;
		}
		
		/**
		* Indicates what function from the Easing class is used for tweening
		*
		* @default "Regular.easeOut"
		*/
		public function get tweenType():Function {
			return _tweenType;
		}
		/**
		* @private
		*/
		public function set tweenType(val:Function):void {
			_tweenType = val;
		}
		
		/**
		* Indicates the duration a tween takes to animate
		*
		* @default 1
		*/
		public function get tweenTime():Number {
			return _tweenTime;
		}
		/**
		* @private
		*/
		public function set tweenTime(val:Number):void {
			_tweenTime = val;
		}
		
		/**
		* Indicates the grid width boundary
		*
		* @default 1000
		*/
		public function get width():Number {
			return _width;
		}
		/**
		* @private
		*/
		public function set width(val:Number):void {
			_width = val;
		}
		
		/**
		* Indicates the distance between items in the grid
		*
		* @default 10
		*/
		public function get spacingY():Number {
			return _spacingY;
		}
		/**
		* @private
		*/
		public function set spacingY(val:Number):void {
			_spacingY = val;
			arrange();
		}
		
		/**
		* Indicates the distance between items in the grid
		*
		* @default 10
		*/
		public function get spacingX():Number {
			return _spacingX;
		}
		/**
		* @private
		*/
		public function set spacingX(val:Number):void {
			_spacingX = val;
			arrange();
		}
		
		/**
		* Indicates the starting Y position
		*
		* @default 0
		*/
		public function get startY():Number {
			return _startY;
		}
		/**
		* @private
		*/
		public function set startY(val:Number):void {
			_startY = val;
		}
		
		/**
		* Indicates the starting X position
		*
		* @default 0
		*/
		public function get startX():Number {
			return _startX;
		}
		/**
		* @private
		*/
		public function set startX(val:Number):void {
			_startX = val;
		}
		
		/**
		* Indicates the list of items to be arranged
		*
		*/
		public function get items():Array {
			return _items;
		}
		/**
		* @private
		*/
		public function set items(val:Array):void {
			var len:uint = val.length;
			_currentY = _startY;
			_items = new Array();
			
			for(var i:uint = 0; i < len; i++) {
				addItem(val[i]);
			}
			arrange();
		}
		
		/**
		* Indicates the format the items will be arranged
		*
		*/
		public function get layout():Array {
			return _layout;
		}
		/**
		* @private
		*/
		public function set layout(val:Array):void {
			_layout = val;
			arrange();
		}
		
		/**
		* Indicates the alignment of items
		*
		*/
		public function get align():String {
			return _align;
		}
		/**
		* @private
		*/
		public function set align(val:String):void {
			// validation
			switch(val) {
				case LEFT:
				case CENTER:
				case RIGHT:
					break;
				default :
					return;
			}
			
			_align = val;
			arrange();
		}
		
		/**
		* Indicates the alignment of items
		*
		*/
		public function get alignRow():String {
			return _alignRow;
		}
		/**
		* @private
		*/
		public function set alignRow(val:String):void {
			// validation
			switch(val) {
				case TOP:
				case CENTER:
				case BOTTOM:
					break;
				default :
					return;
			}
			
			_alignRow = val;
			arrange();
		}
		
		/**
		* Indicates the Y position of the lowest row
		*
		* @return The current Y position of lowest row.
		*/
		public function get currentY():Number {
			return _currentY;
		}
		
		/**
		* Indicates the last row's id
		*
		* @return The current row id.
		*/
		public function get currentRow():uint {
			var cR:uint = 0;
			if(_items.length == 0) {
				_items[0] = new Array();
			} else {
				cR = _items.length - 1;
			}
			
			return cR;
		}
		
		//--------------------------------------
		//  Methods
		//--------------------------------------
		
		/**
		* Add a new item to the grid on the last row at the last column
		*
		* @param mc The DisplayObject (item) to be added.
		* @param isNewRow Forces LayoutManager to place this on a new row.
		*/
		public function addItem(mc:DisplayObject, isNewRow:Boolean=false):void {
			var row:uint = currentRow;
			var currentWidth:Number = getRowWidth(row);
			
			if(currentWidth + mc.width > width) isNewRow = true;
			
			if(isNewRow) {
				_currentY += getRowHeight(row) + _spacingY;
				row++;
				_items.push(new Array());
				currentWidth = getRowWidth(row);
			}
			
			// Simple Arrange
			_items[row].push(mc);
			moveModule(_items[row][_items[row].length - 1], currentWidth, _currentY);
		}
		
		/**
		* Add a new item to the grid at the specified position
		*
		* @param rowNum The column count.
		* @param colNum The row count.
		* @param mc The DisplayObject (item) to be added.
		*/
		public function addItemAt(rowNum:Number, colNum:Number, mc:DisplayObject):void {
			var rowArray:Array = _items[rowNum - 1].slice();
			var tempArray:Array = rowArray.splice(colNum - 1);
			rowArray[colNum - 1] = mc;
			rowArray = rowArray.concat(tempArray);
			_items[rowNum - 1] = rowArray;
			addUpdate();
		}
		
		/**
		* Remove an item from the grid based on DisplayObject name
		*
		* @param mc The DisplayObject (item) to be removed.
		* @return A value of {@code true} means the item was removed successfully;
		* 		{@code false} means the item was not found.
		*/
		public function removeItem(mc:DisplayObject):Boolean {
			var posArray:Array = findItem(mc);
			if(posArray.length == 0) return false;
			_items[posArray[0]].splice(posArray[1],1);
			removeUpdate();
			return true;
		}
		
		/**
		* Remove an item from the grid based on grid position
		*
		* @param rowNum The column count.
		* @param colNum The row count.
		*/
		public function removeItemAt(rowNum:Number, colNum:Number):void {
			_items[rowNum - 1].splice(colNum - 1,1) ;
			removeUpdate();
		}
		
		/**
		* Rearranges the grid based on current settings.
		*
		* @param rowStart (optional) Row to start arranging.
		*/
		public function arrange(rowStart:Number=undefined):void {
			var curY:Number = _startY;
			var rowLen:uint = _items.length;
			var idx:uint = 0;
			
			// Start at a sepcific row?
			if(rowStart) {
				idx = rowStart + 1;
				curY = _items[rowStart][0].y + getRowHeight(rowStart) + _spacingY;
			}
			
			// Search through item array, and position items
			for (var i:uint = idx; i < rowLen; i++) {
				var colCount:uint;
				var layoutIdx:uint
				var colLen:uint = _items[i].length;
				var rowHeight:Number = getRowHeight(i);
				
				if(_layout.length > 0) {
					layoutIdx = i % _layout.length;
					colCount = _layout[layoutIdx];
				}
				
				if (colCount && colCount != colLen) {
					// Is specified layout?
					if(colCount < colLen) {
						while (colCount != colLen) {
							moveToNextRow(i);
							rowLen = _items.length;
							colLen = _items[i].length;
						}
					} else {
						while (colCount != colLen) {
							if (!_items[i + 1]) break;
							
							moveToPrevRow(i);
							rowLen = _items.length;
							colLen = _items[i].length;
						}
					}
				} else {
					// Is row too wide?
					if(getRowWidth(i) > _width) {
						moveToNextRow(i);
						rowLen = _items.length;
						colLen = _items[i].length;
					}
				}
				
				// Check alignment
				var curX:Number = 0;
				switch(_align) {
					case LEFT:
						curX = 0;
						break;
					case CENTER:
						curX = (_width - getRowWidth(i)) / 2;
						break;
					case RIGHT:
						curX = _width - getRowWidth(i);
						break;
				}
				
				for(var j:uint = 0; j < colLen; j++) {
					var curMod:DisplayObject = _items[i][j];
					
					// Check row alignment
					var tempY:Number = rowHeight - curMod.height;
					switch(_alignRow) {
						case TOP:
							tempY = curY;
							break;
						case CENTER:
							tempY = curY + ((rowHeight - curMod.height) / 2);
							break;
						case BOTTOM:
							tempY = curY + (rowHeight - curMod.height);
							break;
					}
					moveModule(curMod, curX, tempY);
					curX += curMod.width + _spacingX;
				}
				
				curY += rowHeight + _spacingY;
			}
		}
		
		//--------------------------------------
		//  Private
		//--------------------------------------
		
		/**
		* Finds a item in the grid based on DisplayObject name.
		*
		* @param mc The DisplayObject (item) to be found.
		* @return A value of {@code [rowNum, colNum]} if located;
		* {@code []} (Array of zero length) if not located.
		*/
		private function findItem(mc:DisplayObject):Array {
			var rowLen:uint = _items.length;
			for (var rowNum:uint = 0; rowNum < rowLen; rowNum++) {
				var colLen:uint = _items[rowNum].length;
				for (var colNum:uint = 0; colNum < colLen; colNum++) {
					if(_items[rowNum][colNum] == mc) return [rowNum, colNum];
				}
			}
			return [];
		}
		
		/**
		* Moves an item to from one row to the next.
		*
		* @param idx Row to move the last item on.
		*/
		private function moveToNextRow(idx:uint):void {
			var nxtIdx:uint = idx + 1;
			if(!_items[nxtIdx]) _items.push(new Array());
			_items[nxtIdx].unshift(_items[idx].pop());
		}
		
		/**
		* Moves an item to from one row to the previous.
		*
		* @param idx Row to move the last item from.
		*/
		private function moveToPrevRow(idx:uint):void {
			var nxtIdx:uint = idx + 1;
			_items[idx].push(_items[nxtIdx].shift());
			if(_items[nxtIdx].length == 0) _items.pop();
		}
		
		/**
		* Recursive function called when item is added. Checks to see if the added
		* item makes rows too wide and adjusts rows accordingly.
		*
		* @param n (optional) Row number.
		*/
		private function addUpdate(idx:uint = 0):void {
			if(_items[idx][0]) {
				// Is row too wide?
				if(getRowWidth(idx) > _width) {
					moveToNextRow(idx);
					addUpdate(idx);
				} else {
					addUpdate(++idx);
				}
			} else {
				arrange();
			}
		}
		
		/**
		* Recursive function called when item is removed. Checks to see if the removed
		* item makes rows too narrow and adjusts rows accordingly.
		*
		* @param n (optional) Row number.
		*/
		private function removeUpdate(idx:uint = 0):void {
			if(_items[idx++][0]){
				// Is row too narrow?
				if((_items[idx++][0].width + getRowWidth(idx)) < _width) {
					moveToPrevRow(idx);
					removeUpdate(idx);
				} else {
					removeUpdate(idx++);
				}
			} else {
				arrange();
			}
		}
		
		/**
		* Moves an item to a specified position based on tween setting
		*
		* @param mc The DisplayObject to be moved.
		* @param x Target X position.
		* @param y Target Y position.
		*/
		private function moveModule(mc:DisplayObject, x:Number, y:Number):void {
			x += _startX;
			if (_tween) {
				TweenLite.to(mc, _tweenTime, {x:x, y:y, ease:_tweenType } );
			} else {
				mc.x = x;
				mc.y = y;
			}
		}
		
		/**
		* Fetches the specified rows width only based on widthes and spacing
		*
		* @param idx The row number.
		* @return The width of specified row.
		*/
		private function getRowWidth(idx:uint):Number {
			var totalW:Number = 0;
			for(var i:String in _items[idx]) {
				totalW += _items[idx][i].width + _spacingX;
			}
			return totalW;
		}
		
		/**
		* Fetches the specified rows height only based on heights and spacing
		*
		* @param idx The row number.
		* @return The height of specified row.
		*/
		private function getRowHeight(idx:uint):Number {
			var bigH:Number = 0;
			for(var i:String in _items[idx]) {
				var modH:Number = _items[idx][i].height;
				if(modH > bigH) bigH = modH;
			}
			return bigH;
		}
	}
}