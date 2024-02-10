package cv.formats {
	
	import cv.data.PlayList;
	
	//--------------------------------------
    //  Class description
    //--------------------------------------	
    /**
	 * The M3U class parses M3U formatted playlist files and adds the data
	 * to itself. M3U is by far the most popular playlist format, probably due 
	 * to its simplicity. It is an ad-hoc standard with no formal definition, 
	 * no canonical source, and no owner.
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.115.0
     */
	public dynamic class M3U extends PlayList {
		
		public function M3U(sourceFile:String):void {
			var lineBegin:int = sourceFile.indexOf("\n", sourceFile.indexOf("#EXTM3U", 0)) + 1;
			
			//Find BOF and skip it.
			var lineEnd:int = lineBegin;
			var lineCount:int = 0;
			var strLine:String = "";
			var strTitle:String = "";
			var nSeconds:int = 0;
			var l:uint = sourceFile.length;
			
			while (lineEnd != -1) {
				lineBegin = lineCount == 0 ? lineBegin : lineEnd + 1;
				// Incase there isn't a \n on the last item, compensate for it.
				if (lineBegin >= l) {
					lineEnd = -1;
				} else {
					lineEnd = sourceFile.indexOf("\n", lineEnd + 1);
					if (lineEnd < 0) lineEnd = l + 1;
				}
				strLine = sourceFile.substring(lineBegin, lineEnd - 1);
				lineCount++;
				
				if (strLine.indexOf("#EXTINF", 0) != -1) {
					nSeconds = int(strLine.substring(strLine.indexOf(":", 0) + 1, strLine.indexOf(",", 0)));
					strTitle = strLine.substring(strLine.indexOf(",", 0) + 1, strLine.length);
				} else {
					if (strLine.length > 1) {
						// Reset variables
						push( { title:strTitle, length:nSeconds, url:strLine } );
						strTitle = "";
						nSeconds = 0;
					}
				}
			}
		}
	}
}