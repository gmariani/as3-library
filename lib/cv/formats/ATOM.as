package cv.formats {
	
	import cv.data.PlayList;
	
	//--------------------------------------
    //  Class description
    //--------------------------------------	
    /**
	 * The ATOM class parses ATOM formatted playlist files and adds the data
	 * to itself.
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.115.0
     */
	public dynamic class ATOM extends PlayList {
		
		public function ATOM(sourceFile:XML):void {
			
			// The source RSS data may or may not use a namespace to define its content.
			if (sourceFile.namespace("") != undefined) { default xml namespace = sourceFile.namespace("") }
			
			//var title:String = sourceFile.title; // Title
			
			// Get Entries
			for each (var entry:XML in sourceFile..entry) {
				var o:Object = new Object();
				for each(var child:XML in entry.children()) {
					switch(child.localName().toLowerCase()) {
						/*case "author" :
							o.author = child.toString();
							break;
						case "summary" :
							o.description = child.toString();
							break;*/
						case "duration" :
							o.length = toSeconds(child.@value.toString()); // Defines the length of time the WMP control will render a stream.
							break;
						case "group" :
							for each (var child2:XML in child.children()) {
								switch(child2.localName().toLowerCase()) {
									case "content":
										if (!o.url && mimetypes[child2.@type.toString()]) {
											o.url = child2.@url.toString();
											//o.type = child2.@type.toString();
											if (child2.@duration) o.duration = toSeconds(child2.@duration);
											//if (child2.@start) o.start = toSeconds(child2.@start);
										}
										break;
									/*case "description":
										o.description = child.toString();
										break;
									case "thumbnail":
										if(!o.image) o.image = child.@url.toString();
										break;
									case "credit":
										o.author = child.toString();
										break;*/
								}
							}
							break;
						/*case "link" :
							if (child.@rel == "alternate") o.link = child.@href.toString();
							break;*/
						case "title" :
							o.title = child.toString();
							break;
					}
				}
				
				push(o);
			}
		}
	}
}