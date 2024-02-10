/*
 * 
 * http://www.betriebsraum.de/blog/2007/06/22/runtime-font-loading-with-as3-flash-cs3-not-flex/
 * 
 * Just create a Loader and load the swf…and when the Loader is finished 
 * create a URLLoader and load the stylesheet. The initialize method accepts 
 * an ApplicationDomain and a StyleSheet which are both stored in instance 
 * variables. The ApplicationDomain parameter would be 
 * myLoader.contentLoaderInfo.applicationDomain and the StyleSheet is an instance 
 * of the StyleSheet class (with parseCSS called before to parse the external css file). 
 * After calling the initialize method you would call registerFonts and pass an array 
 * with font class names you want to register in the global list, for 
 * example: fontManagerInstance.registerFonts([”Standard57″]). This registers the font 
 * with a class name of Standard57 (Standard57 is the class set in the symbol linkage, 
 * not the symbol name and not the real font name!). In the CSS file the font is 
 * defined with font-family: standard 07_57 (use the real name here!). Also make 
 * sure to set just one font in the font-family style!
 * 
 * 
 * If you now place a textfield onto the stage and write:
 * 
 * myTextField.styleSheet = fontManagerInstance.getStyleSheet();
 * myTextField.embedFonts = true;
 * myTextField.htmlText = "<h1>This is the headline</h1>";
 * 
 * everything should work (provided there’s a h1 style in the css with the correct 
 * font-family set and a font symbol in the library swf). If the textfield is manually 
 * placed onto the stage it’s important to set a different font for the textfield itself 
 * (in the property inspector) than the one that is defined in the CSS file (so simply select 
 * _sans, for example). In addition don’t embed it in the property inspector as the file size 
 * is increased then (set embedFonts in your code instead).
 * 
 */

package cv.managers {
	
	import flash.text.StyleSheet;
	import flash.system.ApplicationDomain;
	import flash.text.Font;
	import flash.events.EventDispatcher;

	public class FontManager extends EventDispatcher {
		
		private var _fontsDomain:ApplicationDomain;
		private var _styleSheet:StyleSheet;
		private static var _instance:FontManager = new FontManager();
		
		public function FontManager() {
			if (_instance) trace("FontManager - Error : FontManager can only be accessed through FontManager.getInstance()");
			
			super();
		}
		
		public static function getInstance():FontManager {
			return _instance;
		}
		
		public function initialize(fontsDomain:ApplicationDomain, styles:StyleSheet = null):void {
			if (_fontsDomain == null) {
				_fontsDomain = fontsDomain;
				_styleSheet = styles;
			} else {
				trace("FontManager::initialize - Error : FontManager already initialized");
			}
		}
		
		public function registerFonts(fontList:Array):void {
			var n:int = fontList.length;
            for (var i:uint = 0; i < n; i++) {
				Font.registerFont(getFontClass(fontList[i]));
			}
		}
		
		public function getFontClass(id:String):Class {
			return _fontsDomain.getDefinition(id) as Class;
		}
		
		public function getFont(id:String):Font {
			var fontClass:Class = getFontClass(id);
			return new fontClass as Font;
		}
		
		public function getStyleSheet():StyleSheet {
			return _styleSheet;
		}
	}
}