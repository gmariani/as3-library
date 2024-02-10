package {
	import flash.net.registerClassAlias;
	registerClassAlias("com.AS3SolTestClass", AS3SolTestClass);
	[RemoteClass(alias = "com.AS3SolTestClass")]
	public class AS3SolTestClass extends Object {
		public var foo:int = 3;
		public function AS3SolTestClass(val:int) {
			foo = val;
		}

		public function toString():String {
			return "[com.AS3SolTestClass - foo=" + foo + "]";
		}
	}
}