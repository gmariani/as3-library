
package cv.managers {

	import flash.events.NetStatusEvent;
    import flash.net.SharedObject;
    import flash.net.SharedObjectFlushStatus;
	
	public class SOManager {
		
		private var soData:SharedObject;
		
		public function SOManager() { }
		
		public function open(strSO:String):void {
			soData = SharedObject.getLocal(strSO);
		}
		
		public function save(strName:String, value:*):void {
			var flushStatus:String = null;
			soData.data[strName] = value;
            
            try {
                flushStatus = soData.flush(10000);
            } catch (error:Error) {
				new Error("SharedObject - Could not write SharedObject to disk");
            }
			
            if (flushStatus != null) {
                switch (flushStatus) {
                    case SharedObjectFlushStatus.PENDING:
                        trace("Requesting permission to save object...");
                        soData.addEventListener(NetStatusEvent.NET_STATUS, onFlushStatus);
                        break;
                    case SharedObjectFlushStatus.FLUSHED:
                        trace("Value flushed to disk. [1]");
                        break;
                }
            }
		}
		
		private function clearValue(strName:String):void {
			delete soData.data[strName];
        }
		
		private function onFlushStatus(event:NetStatusEvent):void {
            switch(event.info.code) {
                case "SharedObject.Flush.Success":
                    trace("Value flushed to disk. [2]");
                    break;
                case "SharedObject.Flush.Failed":
                    new Error("SharedObject - User denied permission -- value not saved.");
                    break;
            }
            soData.removeEventListener(NetStatusEvent.NET_STATUS, onFlushStatus);
        }
		
		public function get size():uint {
			return soData.size;
		}
		
		public function get data():Object {
			return soData.data;
		}
	}
}