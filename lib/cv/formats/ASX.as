package cv.formats {
	
	import cv.data.PlayList;
	
	//--------------------------------------
    //  Class description
    //--------------------------------------	
    /**
	 * The ASX class parses ASX formatted playlist files and adds the data
	 * to itself.
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.115.0
     */
	public dynamic class ASX extends PlayList {
		
		public function ASX(sourceFile:XML):void {
			
			// The source RSS data may or may not use a namespace to define its content.
			if (sourceFile.namespace("") != undefined) { default xml namespace = sourceFile.namespace("") }
			
			//var version:String = sourceFile.@version; // Version
			//var title:String = sourceFile.title; // Title
			
			// Get Entries
			for each (var entry:XML in sourceFile..entry) {
				var o:Object = new Object();
				for each(var child:XML in entry.children()) {
					switch(child.localName().toLowerCase()) {
						/*case "author" :
							o.author = child.toString();
							break;
						case "abstract" :
							o.description = child.toString();
							break;*/
						case "duration" :
							o.length = toSeconds(child.@value.toString()); // Defines the length of time the WMP control will render a stream.
							break;
						case "ref" :
							o.url = child.@href.toString();
							break;
						/*case "moreinfo" :
							o.link = child.@href.toString();
							break;
						case "param" :
							// image, type
							o[child.@name] = child.@value.toString();
							break;
						case "starttime" :
							o.start = toSeconds(entry.starttime.@value.toString());
							break;*/
						case "title" :
							o.title = child.toString(); // Defines a text string specifying the title for an ASX or ENTRY element.
							break;
					}
				}
				
				/*var strExt:String = o.url.substr(-3);
				if (mimetypes[strExt] != undefined) o.type = mimetypes[strExt];
				if (o.url.substr(-4) == "rtmp") o.type = "rtmp";*/
				
				if(entry.hasOwnProperty("base")) o.url = entry.base.toString() + o.url; // Defines a URL string appended to the front of URLs sent to the WMP control.
				push(o);
			}
		}
	}
}