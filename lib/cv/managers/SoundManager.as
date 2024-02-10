package cv.managers {

	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundLoaderContext;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	
	/**
	 * The SoundManager is a singleton that allows you to have various ways to control sounds in your project.
	 * <p />
	 * The SoundManager can load external or library sounds, pause/mute/stop/control volume for one or more sounds at a time, 
	 * fade sounds up or down, and allows additional control to sounds not readily available through the default classes.
	 * <p />
	 * 
	 */
	public class SoundManager {

		// singleton instance
		private static var _instance:SoundManager = new SoundManager();
		private var _soundsDict:Dictionary = new Dictionary(true);
		
		public function SoundManager() {
			if (_instance) { throw new Error("Only one instance of SoundManager is allowed."); }
		}
		
		//--------------------------------------
		//  Properties
		//--------------------------------------
		
		public function get sounds():Dictionary {
		    return this._soundsDict;
		}
		
		//--------------------------------------
		//  Methods
		//--------------------------------------
		
		/**
		 * Adds a sound from the library to the sounds dictionary for playing in the future.
		 * 
		 * @param linkageID The class name of the library symbol that was exported for AS
		 * @param name The string identifier of the sound to be used when calling other methods on the sound
		 * 
		 * @return Boolean A boolean value representing if the sound was added successfully
		 */
		public function addLibrarySound(linkageID:Class, name:String):Boolean {
			for each(var o:Object in this._soundsDict) {
				if (o.name == name) return false;
			}
			
			var sndObj:Object = new Object();
			var snd:Sound = new linkageID();
			
			sndObj.name = name;
			sndObj.sound = snd;
			sndObj.channel = new SoundChannel();
			sndObj.position = 0;
			sndObj.paused = true;
			sndObj.volume = 1;
			sndObj.startTime = 0;
			sndObj.loops = 0;
			sndObj.pausedByAll = false;
			
			this._soundsDict[name] = sndObj;
			
			return true;
		}
		
		/**
		 * Adds an external sound to the sounds dictionary for playing in the future.
		 * 
		 * @param path A string representing the path where the sound is on the server
		 * @param name The string identifier of the sound to be used when calling other methods on the sound
		 * @param buffer The number, in milliseconds, to buffer the sound before you can play it (default: 1000)
		 * @param checkPolicyFile A boolean that determines whether Flash Player should try to download a cross-domain policy file from the loaded sound's server before beginning to load the sound (default: false) 
		 * 
		 * @return Boolean A boolean value representing if the sound was added successfully
		 */
		public function addExternalSound(path:String, name:String, buffer:Number = 1000, checkPolicyFile:Boolean = false):Boolean {
			for each(var o:Object in this._soundsDict) {
				if (o.name == name) return false;
			}
			
			var sndObj:Object = new Object();
			var snd:Sound = new Sound(new URLRequest(path), new SoundLoaderContext(buffer, checkPolicyFile));
			
			sndObj.name = name;
			sndObj.sound = snd;
			sndObj.channel = new SoundChannel();
			sndObj.position = 0;
			sndObj.paused = true;
			sndObj.volume = 1;
			sndObj.startTime = 0;
			sndObj.loops = 0;
			sndObj.pausedByAll = false;
			
			this._soundsDict[name] = sndObj;
			
			return true;
		}
		
		/**
		 * Gets the volume of the specified sound.
		 * 
		 * @param name The string identifier of the sound
		 * 
		 * @return Number The current volume of the sound
		 */
		public function getVolume(name:String):Number {
			return this._soundsDict[name].channel.soundTransform.volume;
		}
		
		/**
		 * Gets the position of the specified sound.
		 * 
		 * @param name The string identifier of the sound
		 * 
		 * @return Number The current position of the sound, in milliseconds
		 */
		public function getPosition(name:String):Number {
			return this._soundsDict[name].channel.position;
		}
		
		/**
		 * Gets the duration of the specified sound.
		 * 
		 * @param name The string identifier of the sound
		 * 
		 * @return Number The length of the sound, in milliseconds
		 */
		public function getDuration(name:String):Number {
			return this._soundsDict[name].sound.length;
		}
		
		/**
		 * Gets the sound object of the specified sound.
		 * 
		 * @param name The string identifier of the sound
		 * 
		 * @return Sound The sound object
		 */
		public function getSound(name:String):Sound {
			return this._soundsDict[name].sound;
		}
		
		/**
		 * Identifies if the sound is paused or not.
		 * 
		 * @param name The string identifier of the sound
		 * 
		 * @return Boolean The boolean value of paused or not paused
		 */
		public function isPaused(name:String):Boolean {
			return this._soundsDict[name].paused;
		}
		
		/**
		 * Identifies if the sound was paused or stopped by calling the stopAll() or pauseAll() methods.
		 * 
		 * @param name The string identifier of the sound
		 * 
		 * @return Number The boolean value of pausedByAll or not pausedByAll
		 */
		public function isPausedByAll(name:String):Boolean {
			return this._soundsDict[name].pausedByAll;
		}
		
		/**
		 * Mutes the volume for all sounds in the sound dictionary.
		 * 
		 * @param unmute Resets the volume to their original setting
		 * 
		 * @return void
		 */
		public function muteAll(unmute:Boolean = false):void {
			for each(var snd:Object in this._soundsDict) {
				this.setVolume(snd.name, unmute ? snd.volume : 0);
			}
		}
		
		/**
		 * Pauses the specified sound.
		 * 
		 * @param name The string identifier of the sound
		 * 
		 * @return void
		 */
		public function pause(name:String):void {
			var snd:Object = this._soundsDict[name];
			snd.paused = true;
			snd.position = snd.channel.position;
			snd.channel.stop();
		}
		
		/**
		 * Pauses all the sounds that are in the sound dictionary.
		 * 
		 * @param useCurrentlyPlayingOnly A boolean that only pauses the sounds which are currently playing (default: true)
		 * 
		 * @return void
		 */
		public function pauseAll(useCurrentlyPlayingOnly:Boolean = true):void {
			for each(var snd:Object in this._soundsDict) {
				if (useCurrentlyPlayingOnly) {
					if (!snd.paused) {
						snd.pausedByAll = true;
						this.pause(snd.name);
					}
				} else {
					this.pause(snd.name);
				}
			}
		}

		/**
		 * Plays or resumes a sound from the sound dictionary with the specified name.
		 * 
		 * @param name The string identifier of the sound to play
		 * @param volume A number from 0 to 1 representing the volume at which to play the sound (default: 1)
		 * @param startTime A number (in milliseconds) representing the time to start playing the sound at (default: 0)
		 * @param loops An integer representing the number of times to loop the sound (default: 0)
		 * 
		 * @return void
		 */
		public function play(name:String, volume:Number = 1, startTime:Number = 0, loops:int = 0):void {
			var snd:Object = this._soundsDict[name];
			snd.volume = volume;
			snd.startTime = startTime;
			snd.loops = loops;
				
			if (snd.paused) {
				snd.channel = snd.sound.play(snd.position, snd.loops, new SoundTransform(snd.volume));
			} else {
				snd.channel = snd.sound.play(startTime, snd.loops, new SoundTransform(snd.volume));
			}
			
			snd.paused = false;
		}
		
		/**
		 * Plays all the sounds that are in the sound dictionary.
		 * 
		 * @param useCurrentlyPlayingOnly A boolean that only plays the sounds which were currently playing before a pauseAll() or stopAll() call (default: false)
		 * 
		 * @return void
		 */
		public function playAll(useCurrentlyPlayingOnly:Boolean = false):void {
			for each(var snd:Object in this._soundsDict) {
				if (useCurrentlyPlayingOnly) {
					if (snd.pausedByAll) {
						snd.pausedByAll = false;
						this.play(snd.name);
					}
				} else {
					this.play(snd.name);
				}
			}
		}
		
		/**
		 * Removes a sound from the sound dictionary.  After calling this, the sound will not be available until it is re-added.
		 * 
		 * @param name The string identifier of the sound to remove
		 * 
		 * @return void
		 */
		public function remove(name:String):void {
			delete this._soundsDict[name];
		}
		
		/**
		 * Removes all sounds from the sound dictionary.
		 * 
		 * @return void
		 */
		public function removeAll():void {
			this._soundsDict = new Dictionary(true);
		}
		
		/**
		 * Stops the specified sound.
		 * 
		 * @param name The string identifier of the sound
		 * 
		 * @return void
		 */
		public function stop(name:String):void {
			var snd:Object = this._soundsDict[name];
			snd.paused = true;
			snd.channel.stop();
			snd.position = snd.channel.position;
		}
		
		/**
		 * Stops all the sounds that are in the sound dictionary.
		 * 
		 * @param useCurrentlyPlayingOnly A boolean that only stops the sounds which are currently playing (default: true)
		 * 
		 * @return void
		 */
		public function stopAll(useCurrentlyPlayingOnly:Boolean = true):void {
			for each(var snd:Object in this._soundsDict) {
				if (useCurrentlyPlayingOnly) {
					if (!snd.paused) {
						snd.pausedByAll = true;
						this.stop(snd.name);
					}
				} else {
					this.stop(snd.name);
				}
			}
		}
		
		/**
		 * Sets the volume of the specified sound.
		 * 
		 * @param name The string identifier of the sound
		 * @param volume The volume, between 0 and 1, to set the sound to
		 * 
		 * @return void
		 */
		public function setVolume(name:String, volume:Number):void {
			var snd:Object = this._soundsDict[name];
			var curTransform:SoundTransform = snd.channel.soundTransform;
			curTransform.volume = volume;
			snd.channel.soundTransform = curTransform;
		}
	}
}