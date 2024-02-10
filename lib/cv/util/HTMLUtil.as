package cv.util {
	
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.Dictionary;
	
	//--------------------------------------
    //  Class description
    //--------------------------------------
	/**
	 * A collection of useful html related functions.
	 */
	public class HTMLUtil {
		
		protected static var dictImgTags:Dictionary = new Dictionary(true);
		protected static var imgDebug:Boolean;
		
		public static function parseURL(url:String):Object {
			var regex:RegExp = /(?:(\w+)://)?(?:(\w+)(?::(\w+))?@)?([^/;\?:#]+)(?::(\d+))?(?:/?([^;\?#]+))?(?:;([^\?#]+))?(?:\?([^#]+))?(?:#(\w+))?/g;
			var o:Object = regex.exec(url);
			
			var objURL:Object = { };
			objURL.scheme = o[1];
			objURL.username = o[2];
			objURL.password = o[3];
			objURL.host = o[4];
			objURL.port = o[5];
			objURL.path = o[6];
			objURL.parameters = o[7];
			objURL.query = o[8];
			objURL.fragment = o[9];
			
			return objURL;
		}
		
		/**
		 * Fixes IMG tag handling by Flash so it's actually inline and not on a new line at the left or right side.
		 * The IMG tag MUSt have an ID attribute or else HTMLUtil can't target the image and replace it.
		 * If you are loading an image from a different domain you MUST use the checkPolicyFile attribute.
		 * 
		 * Currently supports everything the Flash version handles except:
		 * - vspace attribute
		 * - align attribute
		 * 
		 * Note: Also can only handle one image per textfield right now.
		 * 
		 * An acceptable IMG tag looks like this:
		 * <img width="19" id="speaker" height="19" src="http://www.url.com/speakerIcon.png" />
		 * 
		 * Call this function everytime the HTMLText is updated to reposition the images and/or
		 * clear the images.
		 * 
		 * @param	txt The textfield the html is being loaded into
		 * @param	spacingColor To space out the text where the image is, periods are inserted. Change this color
		 * 							to match the background color since we can't make transparent.
		 * @param	debug Enabled debug traces and lines of where the image is drawn.
		 * 
		 * @example
		 * <listing version="3.0">
		 * txt.htmlText = 'Right Click on the Audio icon <img width="19" id="speaker" height="19" hspace="4" vspace="0" src="http://www.url.com/speakerIcon.png" /> in the taskbar';
		 * HTMLUtil.fixIMGTag(txt);
		 * </listing>
		 */
		public static function fixIMGTag(txt:TextField, spacingColor:Number = 0xFFFFFF, debug:Boolean = false):void {
			if (!txt.parent) throw new Error("Targeted textfield must be attached to the display list");
			
			// Clear images if textfield has been fixed before
			var objTag:Object;
			if (dictImgTags[txt]) {
				for (var key:String in dictImgTags[txt]) {
					objTag = dictImgTags[txt][key];
					txt.parent.removeChild(objTag.bmp);
					if(objTag.hasOwnProperty("debug")) txt.parent.removeChild(objTag.debug);
					dictImgTags[txt][key] = null;
				}
			}
			dictImgTags[txt] = new Dictionary(true);
			
			var regex:RegExp = /(<img\s[^<]+\s?>)/gi;
			var regexAttr:RegExp = /(\w+)="([\w*\d*:?\/?.?]+)+"/gi;
			var o:Object = regex.exec(txt.htmlText);
			imgDebug = debug;
			
			while (o != null) {
				objTag = new Object();
				objTag.rawTag = o[1];
				objTag.index = o.index;
				objTag.txt = txt;
				
				// Parse attributes
				var o2:Object = regexAttr.exec(objTag.rawTag);
				while (o2 != null) {
					if(debug) trace("HTMUtil::fixIMGTag - ", o2[1], o2[2]);
					if (o2[1] == "ID") {
						objTag.loader = txt.getImageReference(o2[2]) as Loader;
						objTag.loader.contentLoaderInfo.addEventListener(Event.COMPLETE, imgCompleteHandler);
					}
					objTag[String(o2[1]).toLowerCase()] = o2[2];
					o2 = regexAttr.exec(objTag.rawTag);
				}
				
				dictImgTags[txt][objTag.loader] = objTag;
				o = regex.exec(txt.htmlText);
			}
		}
		
		/**
		 * Converts any given html into Flash compliant html.
		 * 
		 * @param	txt Random html
		 * @return	Flash compliant HTMl
		 */
		public static function convertHTML(str:String = ""):String {
			if (str == "") return str;
			
			// For some reason, if there are LI tags, it seems to make everything a list item
			
			// validTags 'a', 'b', 'br', 'font', 'img', 'i', 'li', 'p', 'span', 'textformat', 'u'
			var regex:RegExp = /(<\/?(?!([abpui]|br|font|img|li|span|textformat)[\s>]+)([^\/<\s]+)[^<>]*?>)/gi;
			var o:Object = regex.exec(str);
			var arrSplice:Array = [];
			var startIndex:Number = NaN;
			while (o != null) {
				if((o[3] == "script" || o[3] == "style") && isNaN(startIndex)) {
					startIndex = o.index;
				} else {
					if(!isNaN(startIndex)) {
						arrSplice.push(new Point(startIndex, o.index + o[1].length));
						startIndex = NaN;
					} else {
						arrSplice.push(new Point(o.index, o.index + o[1].length));
					}
				}
				
				// Removing the text at this point makes the regExp remove every other match
				//str = str.substring(0, o.index) + str.substring(o.index + o[1].length);
				
				o = regex.exec(str);
			}
			
			var i:uint = arrSplice.length;
			var p:Point;
			while(i--) {
				p = arrSplice[i];
				str = str.substring(0, p.x) + str.substring(p.y);
			}
			
			str = convertHTMLEntities(str);
			
			return str;
		}
		
		public static function convertHTMLEntities(str:String = ""):String {
			if (str == "") return str;
			
			var htmlEntities:Array = ["&nbsp;", "&iexcl;", "&cent;", "&pound;", "&curren;", "&yen;", "&brvbar;", "&sect;", "&uml;", "&copy;", "&ordf;", "&laquo;", "&not;", "&shy;", "&reg;", "&macr;", "&deg;", "&plusmn;", "&sup2;", "&sup3;", "&acute;", "&micro;", "&para;", "&middot;", "&cedil;", "&sup1;", "&ordm;", "&raquo;", "&frac14;", "&frac12;", "&frac34;", "&iquest;", "&Agrave;", "&Aacute;", "&Acirc;", "&Atilde;", "&Auml;", "&Aring;", "&AElig;", "&Ccedil;", "&Egrave;", "&Eacute;", "&Ecirc;", "&Euml;", "&Igrave;", "&Iacute;", "&Icirc;", "&Iuml;", "&ETH;", "&Ntilde;", "&Ograve;", "&Oacute;", "&Ocirc;", "&Otilde;", "&Ouml;", "&times;", "&Oslash;", "&Ugrave;", "&Uacute;", "&Ucirc;", "&Uuml;", "&Yacute;", "&THORN;", "&szlig;", "&agrave;", "&aacute;", "&acirc;", "&atilde;", "&auml;", "&aring;", "&aelig;", "&ccedil;", "&egrave;", "&eacute;", "&ecirc;", "&euml;", "&igrave;", "&iacute;", "&icirc;", "&iuml;", "&eth;", "&ntilde;", "&ograve;", "&oacute;", "&ocirc;", "&otilde;", "&ouml;", "&divide;", "&oslash;", "&ugrave;", "&uacute;", "&ucirc;", "&uuml;", "&yacute;", "&thorn;", "&yuml;", "&fnof;", "&Alpha;", "&Beta;", "&Gamma;", "&Delta;", "&Epsilon;", "&Zeta;", "&Eta;", "&Theta;", "&Iota;", "&Kappa;", "&Lambda;", "&Mu;", "&Nu;", "&Xi;", "&Omicron;", "&Pi;", "&Rho;", "&Sigma;", "&Tau;", "&Upsilon;", "&Phi;", "&Chi;", "&Psi;", "&Omega;", "&alpha;", "&beta;", "&gamma;", "&delta;", "&epsilon;", "&zeta;", "&eta;", "&theta;", "&iota;", "&kappa;", "&lambda;", "&mu;", "&nu;", "&xi;", "&omicron;", "&pi;", "&rho;", "&sigmaf;", "&sigma;", "&tau;", "&upsilon;", "&phi;", "&chi;", "&psi;", "&omega;", "&thetasym;", "&upsih;", "&piv;", "&bull;", "&hellip;", "&prime;", "&Prime;", "&oline;", "&frasl;", "&weierp;", "&image;", "&real;", "&trade;", "&alefsym;", "&larr;", "&uarr;", "&rarr;", "&darr;", "&harr;", "&crarr;", "&lArr;", "&uArr;", "&rArr;", "&dArr;", "&hArr;", "&forall;", "&part;", "&exist;", "&empty;", "&nabla;", "&isin;", "&notin;", "&ni;", "&prod;", "&sum;", "&minus;", "&lowast;", "&radic;", "&prop;", "&infin;", "&ang;", "&and;", "&or;", "&cap;", "&cup;", "&int;", "&there4;", "&sim;", "&cong;", "&asymp;", "&ne;", "&equiv;", "&le;", "&ge;", "&sub;", "&sup;", "&nsub;", "&sube;", "&supe;", "&oplus;", "&otimes;", "&perp;", "&sdot;", "&lceil;", "&rceil;", "&lfloor;", "&rfloor;", "&lang;", "&rang;", "&loz;", "&spades;", "&clubs;", "&hearts;", "&diams;", "&quot;", "&amp;", "&lt;", "&gt;", "&OElig;", "&oelig;", "&Scaron;", "&scaron;", "&Yuml;", "&circ;", "&tilde;", "&ensp;", "&emsp;", "&thinsp;", "&zwnj;", "&zwj;", "&lrm;", "&rlm;", "&ndash;", "&mdash;", "&lsquo;", "&rsquo;", "&sbquo;", "&ldquo;", "&rdquo;", "&bdquo;", "&dagger;", "&Dagger;", "&permil;", "&lsaquo;", "&rsaquo;", "&euro;"];
			var numberEntities:Array = ["&#160;", "&#161;", "&#162;", "&#163;", "&#164;", "&#165;", "&#166;", "&#167;", "&#168;", "&#169;", "&#170;", "&#171;", "&#172;", "&#173;", "&#174;", "&#175;", "&#176;", "&#177;", "&#178;", "&#179;", "&#180;", "&#181;", "&#182;", "&#183;", "&#184;", "&#185;", "&#186;", "&#187;", "&#188;", "&#189;", "&#190;", "&#191;", "&#192;", "&#193;", "&#194;", "&#195;", "&#196;", "&#197;", "&#198;", "&#199;", "&#200;", "&#201;", "&#202;", "&#203;", "&#204;", "&#205;", "&#206;", "&#207;", "&#208;", "&#209;", "&#210;", "&#211;", "&#212;", "&#213;", "&#214;", "&#215;", "&#216;", "&#217;", "&#218;", "&#219;", "&#220;", "&#221;", "&#222;", "&#223;", "&#224;", "&#225;", "&#226;", "&#227;", "&#228;", "&#229;", "&#230;", "&#231;", "&#232;", "&#233;", "&#234;", "&#235;", "&#236;", "&#237;", "&#238;", "&#239;", "&#240;", "&#241;", "&#242;", "&#243;", "&#244;", "&#245;", "&#246;", "&#247;", "&#248;", "&#249;", "&#250;", "&#251;", "&#252;", "&#253;", "&#254;", "&#255;", "&#402;", "&#913;", "&#914;", "&#915;", "&#916;", "&#917;", "&#918;", "&#919;", "&#920;", "&#921;", "&#922;", "&#923;", "&#924;", "&#925;", "&#926;", "&#927;", "&#928;", "&#929;", "&#931;", "&#932;", "&#933;", "&#934;", "&#935;", "&#936;", "&#937;", "&#945;", "&#946;", "&#947;", "&#948;", "&#949;", "&#950;", "&#951;", "&#952;", "&#953;", "&#954;", "&#955;", "&#956;", "&#957;", "&#958;", "&#959;", "&#960;", "&#961;", "&#962;", "&#963;", "&#964;", "&#965;", "&#966;", "&#967;", "&#968;", "&#969;", "&#977;", "&#978;", "&#982;", "&#8226;", "&#8230;", "&#8242;", "&#8243;", "&#8254;", "&#8260;", "&#8472;", "&#8465;", "&#8476;", "&#8482;", "&#8501;", "&#8592;", "&#8593;", "&#8594;", "&#8595;", "&#8596;", "&#8629;", "&#8656;", "&#8657;", "&#8658;", "&#8659;", "&#8660;", "&#8704;", "&#8706;", "&#8707;", "&#8709;", "&#8711;", "&#8712;", "&#8713;", "&#8715;", "&#8719;", "&#8721;", "&#8722;", "&#8727;", "&#8730;", "&#8733;", "&#8734;", "&#8736;", "&#8743;", "&#8744;", "&#8745;", "&#8746;", "&#8747;", "&#8756;", "&#8764;", "&#8773;", "&#8776;", "&#8800;", "&#8801;", "&#8804;", "&#8805;", "&#8834;", "&#8835;", "&#8836;", "&#8838;", "&#8839;", "&#8853;", "&#8855;", "&#8869;", "&#8901;", "&#8968;", "&#8969;", "&#8970;", "&#8971;", "&#9001;", "&#9002;", "&#9674;", "&#9824;", "&#9827;", "&#9829;", "&#9830;", "&#34;", "&#38;", "&#60;", "&#62;", "&#338;", "&#339;", "&#352;", "&#353;", "&#376;", "&#710;", "&#732;", "&#8194;", "&#8195;", "&#8201;", "&#8204;", "&#8205;", "&#8206;", "&#8207;", "&#8211;", "&#8212;", "&#8216;", "&#8217;", "&#8218;", "&#8220;", "&#8221;", "&#8222;", "&#8224;", "&#8225;", "&#8240;", "&#8249;", "&#8250;", "&#8364;"];
			
			str = str.split("&amp;").join("&");
			
			var i:uint = htmlEntities.length;
			while (i--) {
				str = str.split(htmlEntities[i]).join(numberEntities[i]);
			}
			
			return str;
		}
		
		protected static function imgCompleteHandler(event:Event):void {
			var ldrInfo:LoaderInfo = event.target as LoaderInfo;
			ldrInfo.removeEventListener(Event.COMPLETE, imgCompleteHandler);
			
			// Hide original image
			var ldr:Loader = ldrInfo.loader;
			var objTag:Object = dictImgTags[ldr.parent][ldr];
			var uniqueID:String = "__$$IMGFIX__" + objTag.id + "__$$__";
			var txt:TextField = objTag.txt;
			var bmp:Bitmap = Bitmap(ldr.content);
			bmp.visible = false;
			dictImgTags[txt][ldr] = null; // Clear the reference from memory
			
			// Get prop data
			if (!objTag.hasOwnProperty("hspace")) objTag.hspace = 0;
			if (!objTag.hasOwnProperty("width")) {
				objTag.width = bmp.width;
			} else {
				bmp.width = objTag.width;
			}
			if (!objTag.hasOwnProperty("height")) {
				objTag.height = bmp.height;
			} else {
				bmp.height = objTag.height;
			}
			
			// Replace tag with unique text
			txt.htmlText = txt.htmlText.split(objTag.rawTag).join(uniqueID);
			
			// Find position/bounds of unique text
			objTag.beginIndex = txt.text.indexOf(uniqueID);
			var bnds:Rectangle = txt.getCharBoundaries(objTag.beginIndex);
			bnds.x += txt.x;
			bnds.y += txt.y;
			
			// Grab the font size before IMG tag. For some reason Flash sets the font size of the IMG tag to 2
			var tf:TextFormat = txt.getTextFormat(objTag.beginIndex - 1, objTag.beginIndex);
			
			// For some reason, the width sometimes comes back as 0.55. So to get an accurate width, 
			// I'm recreating a textfield with just a space.
			var txtTemp:TextField = new TextField();
			txtTemp.defaultTextFormat = tf;
			txtTemp.text = " ";
			bnds.width = txtTemp.getCharBoundaries(0).width;
			
			// Insert spaces equal to width of image
			var i:int = int((Number(objTag.width) + (Number(objTag.hspace) * 2)) / bnds.width) + 2;
			var strSpace:String = '<FONT COLOR="#FFFFFF" SIZE="' + String(tf.size) + '">';
			while (i--) {
				strSpace += ".";
			}
			strSpace += "</FONT>";
			
			// Replace unique text with correct number of spaces
			txt.htmlText = txt.htmlText.split(uniqueID).join(strSpace);
			
			// Create new image and position
			objTag.bmp = new Bitmap(null, "auto", true);
			try {
				objTag.bmp.bitmapData = bmp.bitmapData;
			} catch (e:SecurityError) {
				throw new Error("Please set 'checkPolicyFile' to 'true' in the IMG tag of [" + ldrInfo.url + "] / " + e.message);
			}
			objTag.bmp.x = bnds.x + Number(objTag.hspace);
			objTag.bmp.y = bnds.y;
			objTag.bmp.width = bmp.width;
			objTag.bmp.height = bmp.height;
			txt.parent.addChild(objTag.bmp);
			
			// Debug
			if(imgDebug) {
				objTag.debug = new Shape();
				// Image Border
				objTag.debug.graphics.lineStyle(1, 0x0000FF);
				objTag.debug.graphics.drawRect(objTag.bmp.x, objTag.bmp.y, objTag.bmp.width, objTag.bmp.height);
				// Bounds Border
				objTag.debug.graphics.lineStyle(1, 0xFF0000);
				objTag.debug.graphics.drawRect(bnds.x, bnds.y, bnds.width, bnds.height);
				txt.parent.addChild(objTag.debug);
			}
		}
	}
}