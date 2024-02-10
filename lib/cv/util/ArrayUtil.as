package cv.util {
	
	//--------------------------------------
    //  Class description
    //--------------------------------------
	/**
	 * A collection of useful array related functions.
	 */
	public class ArrayUtil {
		
		/**
		 * Will all instances of an item in an array.
		 * 
		 * @param	array	The array to use
		 * @param	item	The item to be removed
		 * @return	How many times the item was found in the array
		 */
		public static function removeAllItems(array:Array, item:*):uint {
			var i:int = ArrayUtil.findItem(array, item);
			var f:uint = 0;
			
			while (i != -1) {
				array.splice(i, 1);
				i = ArrayUtil.findItem(array, item);
				f++;
			}
			
			return f;
		}
		
		/**
		 * Removes an specific item from the array.
		 * 
		 * @param	array	The array to use
		 * @param	item	The item to be removed
		 * @return	Whether the item was successfully removed or not
		 */
		public static function removeItem(array:Array, item:*):Boolean {
			var i:uint = array.length;
			while (i--) {
				if (array[i] === item) {
					array.splice(i, 1);
					return true;
				}
			}
			return false;
		}
		
		/**
		 * Counts how many times an item is in the array.
		 * 
		 * @param	array	The array to use
		 * @param	item	The item to be found
		 * @return	The index the item was found at.
		 */
		public static function findItem(array:Array, item:*):int {
			var i:uint = array.length;
			while (i--) {
				if (array[i] === item) {
					return i;
				}
			}
			return -1;
		}
		
		/**
		 * Inserts an item at the specific index.
		 * 
		 * @param	array	The array to use
		 * @param	item	The item to be inserted
		 * @param	index	The index in the array to insert the item at
		 * @return	The updated array
		 */
		public static function insert(array:Array, item:*, index:uint):Array {
			var temp:Array = array.splice(index);
			array[index] = item;
			array = array.concat(temp);
			return array;
		}
		
		/**
		 * Returns the highest valued number in the array.
		 * 
		 * @param	array	The array to use
		 * @return	The highest number found
		 */
		public static function getHighestValue(array:Array):Number {
			return array[array.sort(16|8)[array.length - 1]];
		}
		
		/**
		 * Returns the lowest valued number in the array.
		 * 
		 * @param	array	The array to use
		 * @return	The lowest number found
		 */
		public static function getLowestValue(array:Array):Number {
			return array[array.sort(16|8)[0]];
		}
		
		/**
		 * Finds element in array and displays result
		 * 
		 * @param	array	The array to use
		 * @param	item	The item to look for
		 * @return	Whether the item is found in teh array or not
		 */
		public static function search(array:Array, item:*):Boolean {
			var i:uint = array.length;
			while (i--) {
				if(array[i] === item) return true;
			}
			return false;
		}
		
		/**
		 * Returns number of appearances of element in array
		 * 
		 * @param	array	The array to use
		 * @param	item	The item to be found
		 * @return	How many times the item is in the array
		 */
		public static function searchCount(array:Array, item:*):int {
			var i:int  = array.indexOf(item, 0);
			var c:uint = 0;
			
			while (i != -1) {
				i = array.indexOf(item, i + 1);
				c++;
			}
			
			return c;
		}
		
		/**
		 * Merges two arrays together.
		 * 
		 * @param	arr1	The first array
		 * @param	arr2	The second array
		 * @return	The combined array
		 */
		public static function union(arr1:Array, arr2:Array):Array {
			var temp:Array = new Array();
			var l:uint = arr1.length;
			var l2:uint = arr2.length;
			for(var i:int = 0; i < l; i++) {
				for(var j:int = 0; j < l2; j++){
					if(arr1[i] === arr2[j]) temp.push(arr1[i]);
				}
			}
			return temp;
		}
		
		/**
		 * Shuffles the elements in an array
		 * 
		 * @param	array	The array to be shuffled
		 * @return	The shuffled array
		 */
		public static function shuffle(array:Array):Array {
			var t:Array  = new Array();
			var r:Array  = array.sort(ArrayUtil._sortRandom, Array.RETURNINDEXEDARRAY);
			var i:int = -1;
			
			while (++i < array.length) {
				t.push(array[r[i]]);
			}
			
			return t;
		}
		
		/**
		 * Removes any duplicates found in an array
		 * 
		 * @param	array The array to be filtered
		 * @return	The filtered array
		 */
		public static function removeDuplicates(array:Array):Array {
			return array.filter(ArrayUtil._removeDuplicatesFilter);
		}
		
		/**
		 * Gets the difference between two arrays.
		 * 
		 * @param	arr1	The first array
		 * @param	arr2	The second array
		 * @return	The array containing just the differences
		 */
		public static function difference(arr1:Array, arr2:Array):Array {
			var item:*;
			var temp:Array = new Array();
			var isDifferent:Boolean = false;
			var l:uint = arr1.length;
			var l2:uint = arr2.length;
			var i:int;
			var j:int;
			
			for (i = 0; i < l; i++) {
				item = arr1[i];
				isDifferent = true;
				for(j = 0; j < l2; j++){
					if (item === arr2[j]) {
						isDifferent = false;
						break;
					}
				}
				if(isDifferent) temp.push(item);
			}
			
			for (i = 0; i < l2; i++) {
				item = arr2[i];
				isDifferent = true;
				for(j = 0; j < l; j++){
					if (item === arr1[j]) {
						isDifferent = false;
						break;
					}
				}
				if(isDifferent) temp.push(item);
			}
			
			return temp;
		};
		
		/** @private **/
		protected static function _sortRandom(a:*, b:*):int {
			return Math.round(MathUtil.randomRange(0, 1)) ? 1 : -1;
		}
		
		/** @private **/
		protected static function _removeDuplicatesFilter(e:*, i:int, arr:Array):Boolean {
			return (i == 0) ? true : arr.lastIndexOf(e, i - 1) == -1;
		}
	}
}