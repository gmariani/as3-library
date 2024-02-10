/**
 * 
 * Read XSPF PlayLists
 * 
 * MIME Type: application/xspf+xml
 * 
 * 
 * @author Gabriel Mariani
 * @version 1.0
*/
 
package cv.formats {
	
	import cv.data.PlayList;
	
	//--------------------------------------
	//  Class description
	//--------------------------------------	
	/**
	 * The XSPF class parses XSPF formatted playlist files and adds the data
	 * to itself.
	 *
	 * @langversion 3.0
	 * @playerversion Flash 9.0.115.0
	 */
	public dynamic class XSPF extends PlayList {
		
		public function XSPF(sourceFile:XML):void {
			// The source RSS data may or may not use a namespace to define its content.
			if (sourceFile.namespace("") != undefined) { default xml namespace = sourceFile.namespace("") }
			
			//var version:String = sourceFile.@version; // Version
			//var title:String = sourceFile.title; // Title
			
			// Get Entries
			for each (var track:XML in sourceFile..track) {
				var o:Object = new Object();
				for each(var child:XML in track.children()) {
					switch(child.localName().toLowerCase()) {
						/*case "creator" :
							o.author = child.toString(); // A human-readable title for the playlist. xspf:playlist elements MAY contain exactly one.
							break;
						case "description" :
							o.description = child.toString(); // A human-readable title for the playlist. xspf:playlist elements MAY contain exactly one.
							break;*/
						case "duration" :
							o.length = child.toString(); // The time to render a resource, in milliseconds.
							if (o.length) o.length = -1;
							break;
						case "location" :
							o.url = child.toString(); // Source URI for this playlist. xspf:playlist elements MAY contain exactly one.
							break;
						/*case "info" :
							o.link = child.toString(); // A human-readable title for the playlist. xspf:playlist elements MAY contain exactly one.
							break;
						case "image" :
							o.image = child.toString(); // A human-readable title for the playlist. xspf:playlist elements MAY contain exactly one.
							break;*/
						case "title" :
							o.title = child.toString(); // A human-readable title for the playlist. xspf:playlist elements MAY contain exactly one.
							break;
						/*case "meta" :
							// image, type
							o[child.@rel] = child.toString();
							break;*/
					}
				}
				push(o);
			}
		}
	}
}