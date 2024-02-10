package cv.formats {
	
	import cv.data.PlayList;
	
	//--------------------------------------
    //  Class description
    //--------------------------------------	
    /**
	 * The B4S class parses B4S formatted playlist files and adds the data
	 * to itself. B4S is a proprietary XML-based format introduced in Winamp version 3.
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.115.0
     */
	public class B4S extends PlayList {
		
		public function B4S(sourceFile:XML):void {
			
			if (sourceFile.namespace("") != undefined) { default xml namespace = sourceFile.namespace("") }
			
			// PlayList label
			//var strLabel:String = sourceFile.@label;
			//var nNumOfEntries:String = sourceFile.@num_entries;
			
			// Get Entries
			for each (var entry:XML in sourceFile..entry) {
				push({title:entry.Name.toString(), length:entry.Length, url:entry.@Playstring});
			}
		}
	}
}