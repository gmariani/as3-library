package {
	import flash.utils.IExternalizable;
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	public class MyExternal implements IExternalizable {

		public function MyExternal() {
			// constructor code
		}

		public function readExternal(input : IDataInput):void {
			//var thirdItem:String = input.readObject() as String;
			var fourthItem:String = input.readObject() as String;
		}
		public function writeExternal(output : IDataOutput):void {
			//output.writeObject("my third item");
			output.writeObject("my fourth item");
		}
	}
}