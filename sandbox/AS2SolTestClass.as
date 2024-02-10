class AS2SolTestClass {
	public var foo = 'My Prop';
	public function AS2SolTestClass(val) {
		foo = val;
	}
	
	public function toString():String {
		return "[com.AS2SolTestClass - foo=" + foo + "]";
	}
}