package cv.util {
	
	import flash.xml.XMLDocument;
	import flash.xml.XMLNode;
	import flash.xml.XMLNodeType;
	
	//--------------------------------------
    //  Class description
    //--------------------------------------
	/**
	 * A collection of useful string related functions.
     *
     * @langversion 3.0
     * @playerversion Flash 9
	 */
	public class StringUtil {
		
		public static function htmlEscape(str:String):String {
			return XML(new XMLNode(XMLNodeType.TEXT_NODE, str)).toXMLString();
		}
		
		/**
		*	Determines whether the specified string contains any characters.
		*
		*	@param str The string to check
		*	@return Boolean
		*
		* 	@langversion ActionScript 3.0
		*	@playerversion Flash 9.0
		*/
		public static function isEmpty(str:String):Boolean {
			if (str == null) return true;
			return !str.length;
		}
		
		/**
		*	Determines whether the specified string is numeric.
		*
		*	@param str The string
		*	@return Boolean
		*
		* 	@langversion ActionScript 3.0
		*	@playerversion Flash 9.0
		*/
		public static function isNumeric(str:String):Boolean {
			if (str == null) return false;
			var regx:RegExp = /^[-+]?\d*\.?\d+(?:[eE][-+]?\d+)?$/;
			return regx.test(str);
		}
		
		/**
	     *  Returns <code>true</code> if the specified string is
	     *  a single space, tab, carriage return, newline, or formfeed character.
	     *
	     *  @param str The String that is is being queried. 
	     *
	     *  @return <code>true</code> if the specified string is
	     *  a single space, tab, carriage return, newline, or formfeed character.
	     */
	    public static function isWhitespace(str:String):Boolean {
	        switch (str) {
	            case " ":
	            case "\t":
	            case "\r":
	            case "\n":
	            case "\f":
	                return true;
	            default:
	                return false;
	        }
	    }
		
		/**
		*	Removes whitespace from the front and the end of the specified
		*	string.
		*
		*	@param str The String whose beginning and ending whitespace will be removed.
		*	@return String
		*
		* 	@langversion ActionScript 3.0
		*	@playerversion Flash 9.0
		*/
		public static function trim(str:String):String {
			if (str == null) return '';
			return str.replace(/^\s+|\s+$/g, '');
		}
		
		/**
		*	Removes whitespace from the front (left-side) of the specified string.
		*
		*	@param str The String whose beginning whitespace will be removed.
		*	@return String
		*
		* 	@langversion ActionScript 3.0
		*	@playerversion Flash 9.0
		*/
		public static function trimLeft(str:String):String {
			if (str == null) return '';
			return str.replace(/^\s+/, '');
		}
		
		/**
		*	Removes whitespace from the end (right-side) of the specified string.
		*
		*	@param str The String whose ending whitespace will be removed.
		*	@return String
		*
		* 	@langversion ActionScript 3.0
		*	@playerversion Flash 9.0
		*/
		public static function trimRight(str:String):String {
			if (str == null) return '';
			return str.replace(/\s+$/, '');
		}
		
		/**
		*	Returns a string truncated to a specified length with optional suffix
		*
		*	@param str The string.
		*	@param len The length the string should be shortend to
		*	@param suffix (optional, default=...) The string to append to the end of the truncated string.
		*	@return String
		*
		* 	@langversion ActionScript 3.0
		*	@playerversion Flash 9.0
		*/
		public static function truncate(str:String, len:uint, suffix:String = "..."):String {
			if (str == null) return '';
			len -= suffix.length;
			var trunc:String = str;
			if (trunc.length > len) {
				trunc = trunc.substr(0, len);
				if (/[^\s]/.test(str.charAt(len))) {
					trunc = trimRight(trunc.replace(/\w+$|\s+$/, ''));
				}
				trunc += suffix;
			}
			
			return trunc;
		}
		
		/**
		*	Remove's all < and > based tags from a string
		*
		*	@param str The source string.
		*	@return String
		*
		* 	@langversion ActionScript 3.0
		*	@playerversion Flash 9.0
		*/
		public static function stripTags(str:String):String {
			if (str == null) return '';
			return str.replace(/<\/?[^>]+>/igm, '');
		}
		
		/**
		*	Determins the number of words in a string.
		*
		*	@param str The string.
		*	@return uint
		*
		* 	@langversion ActionScript 3.0
		*	@playerversion Flash 9.0
		*/
		public static function wordCount(str:String):uint {
			if (str == null) return 0;
			return str.match(/\b\w+\b/g).length;
		}
	}
}