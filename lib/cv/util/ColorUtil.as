
package cv.util {
	import flash.geom.ColorTransform;
	
	//--------------------------------------
    //  Class description
    //--------------------------------------
	/**
	 * A collection of useful color related functions. This can help with converting
	 * hex to rgb, or decimal.
     *
     * @langversion 3.0
     * @playerversion Flash 9
	 */
	public class ColorUtil {
		
		/**
		 * Converts a series of individual RGB(A) values to a 32-bit ARGB color value.
		 * 
		 * @param r: A uint from 0 to 255 representing the red color value.
		 * @param g: A uint from 0 to 255 representing the green color value.
		 * @param b: A uint from 0 to 255 representing the blue color value.
		 * @param a: A uint from 0 to 255 representing the alpha value. Default is 255.
		 * @return Returns a hexidecimal color as a String.
		 * @example
		 * 	<code>
		 * 		var hexColor:String = ColorUtil.getColor(128, 255, 0, 255);
		 * 		trace(hexColor); // Traces 80FF00FF
		 * 	</code>
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		*/
		public static function getColor(r:uint, g:uint, b:uint, a:uint = 255):uint {
			return (a << 24) | (r << 16) | (g << 8) | b;
		}
		
		/**
		 * Converts a hexadecimal number to the individual red, green and blue values.
		 * 
		 * @param	col<uint> The hexadecimal number.
		 * @return An object with a 'r', 'g', and 'b' variables.
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		public static function getRGB(col:uint):Object {
			var o:Object = new Object();
			o.r = col >> 16;
			o.g = col >> 8 & 0xFF;
			o.b = col & 0xFF;
			return o;
		}
		
		/**
		 * Converts a hexadecimal number to the individual alpha, red, green and blue values.
		 * 
		 * @param	col<uint> The hexadecimal number.
		 * @return  An object with a 'a', 'r', 'g', and 'b' variables.
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		public static function getARGB(col:uint):Object {
			var o:Object = new Object();
			o.a = col >> 24 & 0xFF;
			o.r = col >> 16 & 0xFF;
			o.g = col >> 8 & 0xFF;
			o.b = col & 0xFF;
			return o;
		}
		
		/**
		 * Converts a decimal number to hexadecimal.
		 * 
		 * @param	n<Number> The number to convert.
		 * @return The returned hexadecimal number.
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		public static function getHex(n:Number):String { return n.toString(16) }
		
		/**
		 * Converts the hexadecimal number to decimal.
		 * 
		 * @param	n<uint> The hexadecimal number in 0xFFFFFF format.
		 * @return The returned decimal number.
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		public static function getDec(n:uint):uint { return uint(n) }
		
		/**
		 * Finds a color that's between the two numbers given.
		 * 
		 * @param	fromColor<uint> The first color
		 * @param	toColor<uint> The second color
		 * @param	progress<Number> The ratio between the two colors you want returned.
		 * @return The color between the two colors.
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		public static function interpolateColor(fromColor:uint, toColor:uint, progress:Number):uint {
			var n:Number = 1 - progress; // Alpha
			var red:uint = uint(((fromColor >>> 16) & 255) * progress + ((toColor >>> 16) & 255) * n);
			var green:uint = uint(((fromColor >>> 8) & 255) * progress + ((toColor >>> 8) & 255) * n);
			var blue:uint = uint(((fromColor) & 255) * progress + ((toColor) & 255) * n);
			var alpha:uint = uint(((fromColor >>> 24) & 255) * progress + ((toColor >>> 24) & 255) * n);
			return (alpha << 24) | (red << 16) | (green << 8) | blue;
		}
		
		/**
		 * Finds a ColorTransform that's between the two ColorTransforms given.
		 * 
		 * @param	fromColor<ColorTransform> The first ColorTransform
		 * @param	toColor<ColorTransform> The second ColorTransform
		 * @param	progress<Number> The ratio between the two ColorTransforms you want returned.
		 * @return The ColorTransform between the two ColorTransforms.
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		public static function interpolateTransform(fromColor:ColorTransform, toColor:ColorTransform, progress:Number):ColorTransform {
			var n:Number = progress, r:Number = 1 - n, sc:Object = fromColor, ec:Object = toColor;
			return new ColorTransform(sc.redMultiplier * r + ec.redMultiplier * n,
									    sc.greenMultiplier * r + ec.greenMultiplier * n,
									    sc.blueMultiplier * r + ec.blueMultiplier * n,
									    sc.alphaMultiplier * r + ec.alphaMultiplier * n,
									    sc.redOffset * r + ec.redOffset * n,
									    sc.greenOffset * r + ec.greenOffset * n,
									    sc.blueOffset * r + ec.blueOffset * n,
									    sc.alphaOffset * r + ec.alphaOffset * n);
		}
	}
}