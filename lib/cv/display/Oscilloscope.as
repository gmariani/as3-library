/**
* ...
* @author Gabriel Mariani
* @version 0.1
*/

package cv.display {
	
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundMixer;
	import flash.utils.*;

	public class Oscilloscope extends Sprite {
		
		private const TOTAL_CHANNEL_LENGTH:int = 256;
		private const PROGRESS_UPDATE_INTERVAL_MS:uint = 10;
		
		public static const LEFT:String = "left";
		public static const RIGHT:String = "right";
		public static const BOTH:String = "both";
		public static const COMBINED:String = "combined";
		public static const SOLID:String = "solid";
		public static const DOTS:String = "dots";
		public static const LINES:String = "lines";
		
		private var _plotHeight:int = 50;
		private var _lineColor:Number = 0x0000FF;
		private var _lineColor2:Number = 0xFF0000;
		private var _numChannels:int = 64;
		private var _lineSpace:int = 1;
		private var _lineStyle:String = SOLID; // solid/dots/lines
		private var _soundChannel:String = COMBINED; //left/right/both/combined
		private var sprLines:Sprite = new Sprite();
		private var sprBG:Sprite = new Sprite();
		private var bytes:ByteArray = new ByteArray();
		private var playTimer:Timer;
		
		public function Oscilloscope(autoPlay:Boolean = true) {
			sprBG.graphics.beginFill(0x000000, 0);
			sprBG.graphics.drawRect(0, 0, 10, 10);
			sprBG.graphics.endFill();
			sprBG.width = _numChannels * 2 + 2;
			sprBG.height = _plotHeight * 2;
			addChild(sprBG);
			
			addChild(sprLines);
			
			playTimer = new Timer(PROGRESS_UPDATE_INTERVAL_MS);
			playTimer.addEventListener(TimerEvent.TIMER, onPlayTimer);
			if(autoPlay) play();
		}
		
		public function set plotHeight(n:int):void {
			_plotHeight = n;
		}
		public function get plotHeight():int {
			return _plotHeight;
		}
		
		/**
		 * Can be set to 'solid', 'dots', or 'lines'
		 */
		public function set lineStyle(str:String):void {
			_lineStyle = str;
		}
		public function get lineStyle():String {
			return _lineStyle;
		}
		
		/**
		 * Sets the left channel line color
		 */
		public function set lineColor(n:Number):void {
			_lineColor = n;
		}
		public function get lineColor():Number {
			return _lineColor;
		}
		
		/**
		 * Sets the right channel line color
		 */
		public function set lineColor2(n:Number):void {
			_lineColor2 = n;
		}
		public function get lineColor2():Number {
			return _lineColor2;
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
		
		/**
		 * Can be set to 0 - 256
		 */
		public function set numChannels(n:int):void {
			if(n > 256) n = 256;
			if(n < 0) n = 0;
			_numChannels = n;
			sprBG.width = _numChannels * 2 + 2;
			sprBG.height = _plotHeight * 2;
		}
		public function get numChannels():int {
			return _numChannels;
		}
		
		/**
		 * Starts animation
		 */
		public function play():void {
			playTimer.start();
		}
		
		/**
		 * Stops animation
		 */
		public function stop():void {
			playTimer.stop();
		}
		
		/**
		 * Called on an interval
		 * 
		 * @param	e	TimerEvent, not used
		 */
		private function onPlayTimer(e:TimerEvent):void {
			if(!SoundMixer.areSoundsInaccessible()) {
				try {
					SoundMixer.computeSpectrum(bytes, false, 0);
					
					var n:Number = 0;
					var n2:Number = 0;
					var startX:Number = 0;
					var g:Graphics= sprLines.graphics;
					var skipAmount:int = int(TOTAL_CHANNEL_LENGTH / _numChannels);
					g.clear();
					
					// Left Channel / Combined
					if(_soundChannel != RIGHT) {
						if(_lineStyle == LINES || _lineStyle == SOLID) g.lineStyle(0, _lineColor);
						if(_lineStyle == SOLID || _lineStyle == DOTS) g.beginFill(_lineColor);
						g.moveTo(0, _plotHeight);
						
						if(_soundChannel == BOTH || _soundChannel == LEFT) {
							for (var i:int = 0; i < TOTAL_CHANNEL_LENGTH; i++) {
								n = (bytes.readFloat() * _plotHeight);
								
								if(i % skipAmount == 0) {
									if(_lineStyle == SOLID || _lineStyle == LINES) {
										g.lineTo(startX, _plotHeight - n);
									} else if(_lineStyle == DOTS) {
										g.moveTo(startX, _plotHeight - n);
										g.drawRect(startX, _plotHeight - n, 1, 1);
									}
									startX += 2;
								}
							}
						} else if(_soundChannel == COMBINED) {
							for (var i2:int = 0; i2 < TOTAL_CHANNEL_LENGTH; i2++) {
								n = (bytes.readFloat() * _plotHeight);
								bytes.position = bytes.position + 1020;
								n2 = (bytes.readFloat() * _plotHeight);
								bytes.position = bytes.position - 1024;
								n = (n + n2) / 2;
								
								if(i2 % skipAmount == 0) {
									if(_lineStyle == SOLID || _lineStyle == LINES) {
										g.lineTo(startX, _plotHeight - n);
									} else if(_lineStyle == DOTS) {
										g.moveTo(startX, _plotHeight - n);
										g.drawRect(startX, _plotHeight - n, 1, 1);
									}
									startX += 2;
								}
							}
						}
						if(_lineStyle == SOLID || _lineStyle == DOTS) g.endFill();
					}
					
					
					// Right channel
					if(_soundChannel == BOTH || _soundChannel == RIGHT) {
						if(_lineStyle == LINES || _lineStyle == SOLID) g.lineStyle(0, _lineColor2);
						if(_lineStyle == SOLID || _lineStyle == DOTS) g.beginFill(_lineColor2);
						g.moveTo(0, _plotHeight);
						bytes.position = 1024;
						startX = 0;
						
						for (var j:int = 0; j < TOTAL_CHANNEL_LENGTH; j++) {
							n = (bytes.readFloat() * _plotHeight);
							
							if(j % skipAmount == 0) {
								if(_lineStyle == SOLID || _lineStyle == LINES) {
									g.lineTo(startX, _plotHeight - n);
								} else if(_lineStyle == DOTS) {
									g.moveTo(startX, _plotHeight - n);
									g.drawRect(startX, _plotHeight - n, 1, 1);
								}
								startX += 2;
							}
						}
						if(_lineStyle == SOLID || _lineStyle == DOTS) g.endFill();
					}
				} catch (error:SecurityError) {
					//trace("Oscilloscope::onPlayTimer - " + error.name + ": " + error.message);
				}
			} else {
				trace("Oscilloscope::onPlayTimer - Error: Sounds are not accessible");
			}
		}
	}
}