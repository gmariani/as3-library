package cv.util {
	
	import flash.filters.BitmapFilter;
	import flash.filters.ColorMatrixFilter;
	import flash.filters.ConvolutionFilter;

	public class AccessibilityUtil {
		
		public static function getInvertFilter():BitmapFilter {
			var invertBitmapFilter = new ColorMatrixFilter();
			invertBitmapFilter.matrix = new Array(-1, 0, 0, 0, 255, 0, -1, 0, 0, 255, 0, 0, -1, 0, 255, 0, 0, 0, 1, 0);
			return invertBitmapFilter;
		}
		
		public static function getBWFilter():BitmapFilter {
			var bwBitmapFilter = new ColorMatrixFilter();
			bwBitmapFilter.matrix = new Array(0.33, 0.33, 0.33, 0, 0, 0.33, 0.33, 0.33, 0, 0, 0.33, 0.33, 0.33, 0, 0, 0, 0, 0, 1, 0);
			return bwBitmapFilter;
		}
		
		public static function getHighContrastFilter(amount:uint=0):BitmapFilter {
			var arrMatrix:Array = new Array(0, 0, 0, 0, amount, 0, 0, 0, 0);
			return new ConvolutionFilter(3, 3, arrMatrix, 1, -255);
		}
	}
}