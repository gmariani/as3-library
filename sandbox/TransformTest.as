package {
	
	import flash.display.MovieClip;
	import flash.utils.getTimer;
	import flash.geom.Matrix;
	import flash.display.Sprite;
	import flash.geom.Point;
	
	public class TransformTest extends MovieClip {
		private var l:int;
		private var list:Array = new Array();
		private var spr:Sprite = new Sprite();
		private var pt:Point = new Point(10, 10);
		
		public function TransformTest() {
			var i:uint;
			
			spr.graphics.beginFill(0x000000, 1);
			spr.graphics.drawCircle(0, 0, 10);
			spr.graphics.endFill();
			this.addChild(spr);
			
			//Create the source array
			for(i = 0; i < 1000000; i++) {
				list.push(Math.random());
			}
			l = list.length;
			trace("List of " + l + " elements.");
			
			//test0();  // Transform: 		1M 2578ms, 2583ms, 2572ms
			//test1();  // Standard:		1M 3597ms, 3609ms, 3569ms
		}
		
		public function test0():void {
			var ts:Number = getTimer();
			var i:int = l - 1; 
			while(i--) {
				spr.transform.matrix = new Matrix(spr.scaleX * 0.98, spr.scaleY * 0.98, 0, 0, spr.x + pt.x, spr.y + pt.y);
			}
			trace("Transform: "+(getTimer()-ts)+"ms");
		}
		
		public function test1():void {
			var ts:Number = getTimer();
			var i:int = l - 1; 
			while(i--) {
				spr.scaleX *= 0.98;
				spr.scaleY *= 0.98;
				spr.x += pt.x;
				spr.y += pt.y;
			}
			trace("Standard: "+(getTimer()-ts)+"ms");
		}
	}
}