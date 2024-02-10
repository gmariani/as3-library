package
{
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.ProgressEvent;
    import flash.filters.BlurFilter;
    import flash.filters.DisplacementMapFilter;
    import flash.geom.ColorTransform;
    import flash.geom.Point;
    import flash.media.Sound;
    import flash.media.SoundChannel;
    import flash.media.SoundMixer;
    import flash.net.URLRequest;
    import flash.text.TextField;
    import flash.utils.ByteArray;

    public class Spectrum extends Sprite
    {

        public static const BASS_COUNT:uint = 24;

        private var pt:Point;

        private var sound:Sound;

        private var soundChannel:SoundChannel;

        private var dispMap:Sprite;

        private var dispBmp:BitmapData;

        private var loadFld:TextField;

        private var holder:Sprite;

        private var bars:Array;

        private var blurF:BlurFilter;

        private var spectrum:ByteArray;

        private var barCount:uint;

        private var dmF:DisplacementMapFilter;

        private var vizBmp:BitmapData;

        private var rvel:Number = 0;

        public function Spectrum()
        {
            rvel = 0;
            super();
            setup();
            loadMusic();
        }

        private function loadComplete(param1:Event):void
        {
            removeChild(loadFld);
            loadFld = null;
            soundChannel = sound.play(20000);
            addEventListener(Event.ENTER_FRAME, tick);
        }

        private function setup():void
        {
            var _loc1_:uint = 0;
            var _loc2_:Sprite = null;
            var _loc3_:Sprite = null;
            var _loc4_:Sprite = null;
            bars = [];
            holder = new Sprite();
            holder.x = holder.y = 250;
            barCount = 512 - BASS_COUNT * 2 >> 2;
            _loc1_ = 0;
            while (_loc1_ < barCount * 2)
            {
                _loc3_ = new Sprite();
                _loc3_.rotation = (_loc1_ + 0.5) / barCount * 180;
                holder.addChild(_loc3_);
                _loc4_ = new Sprite();
                _loc3_.addChild(_loc4_);
                _loc4_.graphics.beginFill(16777215, 1);
                _loc4_.graphics.drawRect(-60, 10, 1, 80);
                bars.push(_loc4_);
                _loc1_++;
            }
            vizBmp = new BitmapData(600, 600, false, 0);
            dispBmp = vizBmp.clone();
            pt = new Point();
            blurF = new BlurFilter(16, 16, 2);
            addChild(new Bitmap(vizBmp));
            _loc2_ = new Sprite();
            _loc2_.graphics.lineStyle(0, 16777215, 1);
            _loc2_.graphics.drawRect(0, 0, 499, 499);
            addChild(_loc2_);
        }

        private function tick(param1:Event):void
        {
            var _loc2_:ByteArray = null;
            var _loc3_:Number = NaN;
            var _loc4_:uint = 0;
            var _loc5_:Sprite = null;
            var _loc6_:Number = NaN;
            var _loc7_:Number = NaN;
            _loc2_ = spectrum;
            SoundMixer.computeSpectrum(_loc2_, true, 1);
            _loc3_ = 0;
            _loc6_ = 0;
            _loc4_ = 0;
            while (_loc4_ < BASS_COUNT)
            {
                _loc6_ = _loc6_ + _loc2_.readFloat();
                _loc4_++;
            }
            _loc4_ = 0;
            while (_loc4_ < barCount)
            {
                _loc3_ = (_loc2_.readFloat() + _loc2_.readFloat()) * (_loc4_ + 15) / 4 + 0.02 + _loc4_ / 500;
                _loc5_ = bars[_loc4_];
                _loc5_.scaleY = _loc5_.scaleY + (_loc3_ - _loc5_.scaleY) / 5;
                _loc4_++;
            }
            _loc7_ = 0;
            _loc4_ = 0;
            while (_loc4_ < BASS_COUNT)
            {
                _loc6_ = _loc6_ + _loc2_.readFloat();
                _loc4_++;
            }
            _loc4_ = 0;
            while (_loc4_ < barCount)
            {
                _loc3_ = (_loc2_.readFloat() + _loc2_.readFloat()) * (_loc4_ + 15) / 4 + 0.02 + _loc4_ / 500;
                _loc5_ = bars[_loc4_ + barCount];
                _loc5_.scaleY = _loc5_.scaleY + (_loc3_ - _loc5_.scaleY) / 5;
                _loc4_++;
            }
            rvel = rvel + ((soundChannel.rightPeak + soundChannel.leftPeak) * 3 - 1 - rvel) / 10;
            holder.rotation = holder.rotation + rvel;
            vizBmp.colorTransform(vizBmp.rect, new ColorTransform(0.88, 0.93, 0.97, 1));
            vizBmp.draw(holder, holder.transform.matrix, new ColorTransform(1, 1, 1, Math.min(1, 0.05 + (_loc6_ + _loc7_) / 50)));
            vizBmp.applyFilter(vizBmp, vizBmp.rect, pt, blurF);
        }

        private function loadProgress(param1:ProgressEvent):void
        {
            loadFld.text = "Loading music: " + (param1.bytesLoaded / param1.bytesTotal * 100 << 0) + "%";
        }

        private function loadMusic():void
        {
            loadFld = new TextField();
            loadFld.textColor = 16777215;
            loadFld.selectable = false;
            loadFld.width = 300;
            loadFld.text = "Loading music: 0%";
            addChild(loadFld);
            sound = new Sound();
            sound.addEventListener(Event.COMPLETE, loadComplete);
            sound.addEventListener(ProgressEvent.PROGRESS, loadProgress);
            sound.load(new URLRequest("music.mp3"));
            spectrum = new ByteArray();
        }
    }
}
