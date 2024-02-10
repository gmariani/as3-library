package {
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.display.Loader;
	import flash.events.ProgressEvent;
	import flash.net.URLRequest;

	public class Preloader extends MovieClip {
		
		protected var ldr:Loader;
		protected var swfURL:String;
		
		public function Preloader() {
			swfURL = loaderInfo.parameters.swfToLoad || "main.swf";
			
			try {
				ldr = new Loader();
				ldr.contentLoaderInfo.addEventListener(Event.COMPLETE, loadHandler);
				ldr.contentLoaderInfo.addEventListener(Event.OPEN, loadHandler);
				ldr.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, progressHandler);
				ldr.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
				ldr.load(new URLRequest(swfURL));
			} catch (error:SecurityError) {
				throw new Error("Preloader::Security Error - " + error.message);
			}
		}
		
		public function get isLocal():Boolean {
			return (loaderInfo.url.indexOf("file") == 0);
		};
		
		protected function beginLoading():void {
			//
		}
		
		protected function updateLoading(percent:Number, loaded:Number, total:Number):void {
			//
		}
		
		protected function endLoading():void {
			addChildAt(ldr, 0);
		}
		
		private function progressHandler(event:ProgressEvent):void {
			updateLoading(event.bytesLoaded / event.bytesTotal, event.bytesLoaded, event.bytesTotal);
		}
		
		private function loadHandler(event:Event):void {
			if (event.type == Event.COMPLETE) {
				endLoading();
			} else if (event.type == Event.OPEN) {
				beginLoading();
			}
		}
		
		private function errorHandler(event:IOErrorEvent):void {
			throw new Error("Preloader::IO Error - " + event.text);
		}
	}
}