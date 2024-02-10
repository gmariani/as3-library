/**
* Displays a variable amount of bars to visualize the audio playing in Flash
* 
* @author Gabriel Mariani
* @version 0.1
*/

package cv.display {
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.media.SoundMixer;
	import flash.utils.Timer;
	import flash.utils.ByteArray;
	import gs.TweenLite;

	public class SpectrumAnalyzer extends Sprite {
		
		private var _plotHeight:int = 50;
		private const TOTAL_CHANNEL_LENGTH:int = 256;
		private const PROGRESS_UPDATE_INTERVAL_MS:uint = 10;
		private var _lineSpace:int = 1;
		private var _barAmount:int = 18;
		private var _barWidth:int = 5;
		private var bytes:ByteArray = new ByteArray();
		private var isPlaying:Boolean = false;
		private var _showPeaks:Boolean = false;
		private var arrLeftBar:Array = new Array();
		private var arrRightBar:Array = new Array();
		private var arrPeak:Array = new Array();
		private var playTimer:Timer;
		private var _soundChannel:String = "combined"; //left/right/both/combined
		private var _speed:Number = .5;
		private var _speed2:Number = 5;
		
		private var sprLeft:Sprite = new Sprite();
		private var sprRight:Sprite = new Sprite();
		private var sprBG:Sprite = new Sprite();
		private var sprPeak:Sprite = new Sprite();
		
		public function SpectrumAnalyzer(autoPlay:Boolean = true) {
			playTimer = new Timer(PROGRESS_UPDATE_INTERVAL_MS);
			playTimer.addEventListener(TimerEvent.TIMER, onPlayTimer);
			
			sprBG.graphics.beginFill(0x0000FF, 0);
			sprBG.graphics.drawRect(0, 0, 10, 10);
			sprBG.graphics.endFill();
			sprBG.width = 0;
			sprBG.height = _plotHeight;
			addChild(sprBG);
			
			addChild(sprLeft);
			addChild(sprRight);
			addChild(sprPeak);
			
			draw();
			if(autoPlay) play();
		}
		
		public function set plotHeight(n:int):void {
			_plotHeight = n;
			draw();
		}
		public function get plotHeight():int {
			return _plotHeight;
		}
		
		public function set lineSpace(n:int):void {
			_lineSpace = n;
			draw();
		}
		public function get lineSpace():int {
			return _lineSpace;
		}
		
		public function set barWidth(n:int):void {
			_barWidth = n;
			draw();
		}
		public function get barWidth():int {
			return _barWidth;
		}
		
		public function set barAmount(n:int):void {
			_barAmount = n;
			draw();
		}
		public function get barAmount():int {
			return _barAmount;
		}
		
		public function set fallOffSpeed(n:int):void {
			if(n < 0) n = 0;
			_speed = n;
		}
		public function get fallOffSpeed():int {
			return _speed;
		}
		
		public function set peakFallOffSpeed(n:int):void {
			if(n < 0) n = 0;
			_speed2 = n;
		}
		public function get peakFallOffSpeed():int {
			return _speed2;
		}
		
		public function set showPeaks(b:Boolean):void {
			_showPeaks = b;
		}
		public function get showPeaks():Boolean {
			return _showPeaks;
		}
		
		/**
		 * Can be to set to 'left', 'right', 'both', and 'combined'
		 */
		public function set soundChannel(str:String):void {
			_soundChannel = str;
		}
		public function get soundChannel():String {
			return _soundChannel;
		}
		
		public function play():void {
			isPlaying = true;
			playTimer.start();
		}
		
		public function stop():void {
			isPlaying = false;
			playTimer.stop();
		}
		
		private function onPlayTimer(e:TimerEvent):void {
			if(!SoundMixer.areSoundsInaccessible()) {
				try {
					SoundMixer.computeSpectrum(bytes, false, 0);
					// Used to navigate the whole spectrum rather than the first few bytes
					var nSkipAmount:int = (TOTAL_CHANNEL_LENGTH / _barAmount);
					var l:uint = arrLeftBar.length;
					
					// Left Channel / Combined
					for(var i:int = 0; i < l; i++) {
						var bar:Sprite = arrLeftBar[i];
						var bar2:Sprite = arrRightBar[i];
						var peak:Sprite = arrPeak[i];
						var newHeight:Number = 0;
						var newHeight2:Number = 0;
						
						if(_soundChannel == "left" || _soundChannel == "combined") {
							sprRight.visible = false;
							sprLeft.visible = true;
						} else if(_soundChannel == "right") {
							sprRight.visible = true;
							sprLeft.visible = false;
						} else {
							sprRight.visible = true;
							sprLeft.visible = true;
						}
						
						// Show or hide peaks
						sprPeak.visible = _showPeaks;
						
						if(_soundChannel != "right") {
							if(_soundChannel == "both" || _soundChannel == "left") {
								newHeight = bytes.readFloat() * _plotHeight;
							} else if(_soundChannel == "combined") {
								var n:Number = (bytes.readFloat() * _plotHeight);
								bytes.position = bytes.position + 1020;
								var n2:Number = (bytes.readFloat() * _plotHeight);
								bytes.position = bytes.position - 1024;
								newHeight = (n + n2) / 2;
							}
						}
						
						if(newHeight > bar.height) {
							bar.height = newHeight;
							TweenLite.to(bar, _speed, {height: 1});
						}
						
						// Right channel
						if (_soundChannel == "both" || _soundChannel == "right") {
							bytes.position = bytes.position + 1020;
							newHeight2 = (bytes.readFloat() * _plotHeight);
							bytes.position = bytes.position - 1024;
						}
						
						if(newHeight2 > bar2.height) {
							bar2.height = newHeight2;
							TweenLite.to(bar2, _speed, {height: 1});
						}
						
						// Set Peaks
						var n3:Number = _plotHeight - 1;
						if(bar.height > bar2.height) {
							n3 = _plotHeight - bar.height;
						} else {
							n3 = _plotHeight - bar2.height;
						}
						if(n3 < peak.y) {
							peak.y = n3;
							TweenLite.to(peak, _speed2, {y: _plotHeight - 1});
						}
						
						// Skip Ahead
						for(var k:int = 0; k < nSkipAmount; k++) {
							bytes.position += 4;
						}
					}
				} catch (error:SecurityError) {
					//trace("SpectrumAnalyzer::onPlayTimer - " + error.name + ": " + error.message);
				}
			} else {
				trace("SpectrumAnalyzer::onPlayTimer - Error: Sounds are not accessible");
			}
		}
		
		private function draw():void {
			playTimer.stop();
			
			for(var i:String in arrLeftBar) {
				sprLeft.removeChild(arrLeftBar[i]);
			}
			for(var j:String in arrRightBar) {
				sprRight.removeChild(arrRightBar[j]);
			}
			for(var l:String in arrPeak) {
				sprPeak.removeChild(arrPeak[l]);
			}
			
			arrLeftBar = new Array();
			arrRightBar = new Array();
			arrPeak = new Array();
			
			var startX:Number = 0;
			for (var k:int = 0; k < _barAmount; k++) {
				var bar:Sprite = new SpectrumAnalyzer_Skin();
				bar.height = 1;
				bar.width = _barWidth;
				bar.x = startX;
				bar.y = _plotHeight;
				arrLeftBar.push(bar);
				sprLeft.addChild(bar);
				
				var bar2:Sprite = new SpectrumAnalyzer_SecondarySkin();
				bar2.height = 1;
				bar2.width = _barWidth;
				bar2.x = startX;
				bar2.y = _plotHeight;
				arrRightBar.push(bar2);
				sprRight.addChild(bar2);
				
				var peak:Sprite = new SpectrumAnalyzer_Skin();
				peak.height = 1;
				peak.width = _barWidth;
				peak.x = startX;
				peak.y = _plotHeight - 1;
				arrPeak.push(peak);
				sprPeak.addChild(peak);
				
				startX += _barWidth + _lineSpace;
			}
			
			sprBG.width = startX;
			if(isPlaying) play();
			//play();
		}
	}
}