package cv.util {
	
	import flash.external.ExternalInterface;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	import flash.system.Security;
	import flash.utils.Dictionary;
	
	//--------------------------------------
    //  Class description
    //--------------------------------------
	/**
	 * A collection of useful web related functions.
     *
     * @langversion 3.0
     * @playerversion Flash 9
	 */
	public class WebUtil {
		
		public static const WINDOW_SELF:String   = '_self';
		public static const WINDOW_BLANK:String  = '_blank';
		public static const WINDOW_PARENT:String = '_parent';
		public static const WINDOW_TOP:String    = '_top';
		
		protected static var _strQuery:String;
		protected static var _dictVars:Dictionary;
		
		/**
		 * The field/value pairs of the browser URL.
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		public static function get queryString():String {
			if (!WebUtil._strQuery) {
				var query:String = ExternalInterface.call('document.location.search.toString');
				
				if (query != '' && query != null) {
					WebUtil._strQuery = query.substring(1);
					
					var pairs:Array = WebUtil._strQuery.split('&');
					var i:int = -1;
					var pair:Array;
					
					WebUtil._dictVars = new Dictionary();
					
					while (++i < pairs.length) {
						pair = pairs[i].split('=');
						WebUtil._dictVars[pair[0]] = pair[1];
					}
				}
			}
			
			return WebUtil._strQuery;
		}
		
		/**
		 *	Refreshes the browser with the current page
		 *
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		*/
		public static function refresh():void {
			ExternalInterface.call('window.location.replace', ExternalInterface.call('window.location.href.toString'));
		}
		
		public static function openUrl(request:*, window:String = WebUtil.WINDOW_SELF):void {
			if (request is String) {
				request = new URLRequest(request);
			} else if (!(request is URLRequest)) {
				throw new Error('The argument type you passed for parameter "request" is not allowed by this method.');
			}
			
			if (window == WebUtil.WINDOW_BLANK && ExternalInterface.available && !LocationUtil.isIde() && request.data == null) {
				if (WebUtil.openWindow(request.url, window)) return;
			}
			
			navigateToURL(request, window);
		}
		
		/**
		 * A Flash wrapper for JavaScript's window.open.
		 * 
		 * @param url: Specifies the URL you wish to open/navigate to.
		 * @param window: The browser window or HTML frame in which to display the URL indicated by the url parameter.
		 * @param features: Defines the various window features to be included.
		 * @return Returns true if the window was successfully created; otherwise false.
		 * 
		 * @see <a href="http://google.com/search?q=JavaScript+window.open+documentation">JavaScript documentation for window.open</a>.
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		public static function openWindow(url:String, window:String = WebUtil.WINDOW_BLANK, features:String = ""):Boolean {
			return ExternalInterface.call("function cvOpenWindow(url, windowOrName, features) { return window.open(url, windowOrName, features) != null; }", url, (window == WebUtil.WINDOW_BLANK) ? 'cvWindow' + int(1000 * Math.random()) : window, features);
		}
		
		/**
		 * Returns a query string value by key.
		 * 
		 * @param key: The key of the query string value to retrieve.
		 * @return The string value of the key.
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		public static function getValue(key:String):String {
			if (WebUtil.queryString == null) return null;
			return WebUtil._dictVars[key];
		}
		
		/**
		 * Checks to if query string key exists.
		 * 
		 * @param key: The name of the key to check for existence.
		 * @return Returns true if the key exists; otherwise false.
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		public static function hasKey(key:String):Boolean {
			return WebUtil.getValue(key) ? true : false;
		}
		
		/**
		 * Loads a crossdomain.xml based on a SecurityError. You would use this in cases of loading
		 * NetStreams off of CDN's where you don't know the final server url. Since NetStream doesn't allow
		 * you to specify the LoaderContext, this is the next best bet. 
		 * 
		 * The best way to use this would be to try loading the media, if it errors out from a SecurityError
		 * call this and loop that procedure about 4 times before giving up.
		 * 
		 * @see http://jessewarden.com/2009/03/handling-crossdomainxml-and-302-redirects-using-netstream.html#netstreamprob
		 * @param	error The security error encoutnered.
		 * 
		 * @example
		 * try {
		 * 		var bit:BitmapData = new BitmapData(progressiveVideoPlayer.measuredWidth, progressiveVideoPlayer.measuredHeight, false, 0x000000);
		 * 		bit.draw(progressiveVideoPlayer);
		 * } catch(error:SecurityError) {
		 * 		WebUtil.loadPolicyFile(error);
		 * }
		 */
		public static function loadPolicyFile(error:SecurityError):void {
			var list:Array = error.toString().split(" ");
			var swfURL:String = list[7] as String;
			var domain:String = list[10] as String;
			domain = domain.substring(0, domain.length - 1);
			var domainList:Array = domain.split("/");
			var protocol:String = domainList[0] as String;
			var address:String = domainList[2];
			var policyFileURL:String = protocol + "//" + address + "/crossdomain.xml";
			Security.loadPolicyFile(policyFileURL);
		}
	}
}