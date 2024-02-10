package cv.formats {
	
	import cv.data.PlayList;
	
	//--------------------------------------
    //  Class description
    //--------------------------------------	
    /**
	 * The PLS class parses PLS formatted playlist files and adds the data
	 * to itself. A proprietary format used for playing Shoutcast and Icecast 
	 * streams. The syntax of a PLS file is the same syntax as a Windows 
	 * .ini file and was probably chosen because of support in the Windows API.
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.115.0
     */
	public dynamic class PLS extends PlayList {
		
		private var regex:RegExp;
		private var file:String;
		
		public function PLS(sourceFile:String):void {
			// Get number of entries
			file = sourceFile;
			regex = /NumberOfEntries(\w*)=\d/g;
			var l:int = regExec();
			
			// Go through each entry
			for (var i:int = 1; i <= l; i++) {
				var o:Object = new Object();
				regex = new RegExp("File" + i + "=(.*)");
				o.url = regExec();
				regex = new RegExp("Title" + i + "=(.*)");
				o.title = regExec();
				regex = new RegExp("Length" + i + "=(.*)");
				o.length = regExec();
				push(o);
			}
		}
		
		private function regExec():* {
			return regex.exec(file)[0].split("=")[1];
		}
	}
}