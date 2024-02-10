package cv.date {
	
	// Supposed to be a subclass of Parsing
	public class Exception extends Error {
		public function Exception(s:String, id:int = 0) {
			message = "Parse error at '" + s.substring(0, 10) + " ...'";
		}
	}
}