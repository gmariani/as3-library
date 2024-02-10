
package cv.util {
	
	import flash.display.DisplayObject;
	import flash.utils.ByteArray;
	
	/**
	 * Utilities for working with Objects.
	*/
	public class ObjectUtil {
		
		/**
		 * Makes a clone of the original Object.
		 * 
		 * @param obj: Object to make the clone of.
		 * @return Returns a duplicate Object.
		 * @example
		 * 	<code>
		 * 		this._author      = new Person();
		 * 		this._author.name = "Aaron";
		 * 		
		 * 		registerClassAlias("Person", Person);
		 * 		
		 * 		var humanClone:Person = Person(ObjectUtil.clone(this._author));
		 * 		
		 * 		trace(humanClone.name);
		 * 	</code>
		 */
		public static function clone(obj:Object):Object {
			var ba:ByteArray = new ByteArray();
			ba.writeObject(obj);
			ba.position = 0;
			return ba.readObject();
		}
		
		/**
		 * 	Determines if object contains no value(s).
		 * 	
		 * 	@param obj: Object to derimine if empty.
		 * 	@return Returns {@code true} if object is empty; otherwise {@code false}.
		 * 	@example
		 * 		<code>
		 * 			var testNumber:Number;
		 * 			var testArray:Array   = new Array();
		 * 			var testString:String = "";
		 * 			var testObject:Object = new Object();
		 * 			
		 * 			trace(ObjectUtil.isEmpty(testNumber)); // traces "true"
		 * 			trace(ObjectUtil.isEmpty(testArray));  // traces "true"
		 * 			trace(ObjectUtil.isEmpty(testString)); // traces "true"
		 * 			trace(ObjectUtil.isEmpty(testObject)); // traces "true"
		 * 		</code>
		 */
		public static function isEmpty(obj:*):Boolean {
			if (obj == undefined)
				return true;
			
			if (obj is Number)
				return isNaN(obj);
			
			if (obj is Array || obj is String)
				return obj.length == 0;
			
			if (obj is Object) {
				for (var prop:String in obj)
					return false;
				
				return true;
			}
			
			return false;
		}
		
		/**
		 * Returns the Class used to construct an object. This is a shortcut instead
		 * of using getQualifiedClassName and getDefinitionByName combination.
		 * 
		 * @param	obj	The object you want to find the Class of.
		 * @return	The Class used.
		 */
		public static function getClass(obj:Object):Class {
			return Object(obj).constructor;
		}
	}
}