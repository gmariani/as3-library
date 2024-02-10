
package cv.util {

	import flash.geom.Point;
	
	//--------------------------------------
    //  Class description
    //--------------------------------------
	/**
	 * A collection of useful geometry related functions. Some are actually replacements for built in Math
	 * class methods becuase they are more effecient than the default.
     *
     * @langversion 3.0
     * @playerversion Flash 9
	 */
	public class GeomUtil {
		
		/**
		 * Gets the angle of the target point based on the given differences in distance.
		 * 
		 * @param	point1<Point> The first point
		 * @param	point2<Point> The second point to base the angle on
		 * @return The angle between the two points in radians
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		public static function getAngle(point1:Point, point2:Point):Number {
			return Math.atan2((point1.y - point2.y), (point1.x - point2.x));
		}
		
		/**
		 * Used to determine the distance between two points.
		 * 
		 * @param	x1<Number> The x of point 1
		 * @param	x2<Number> The x of point 2
		 * @param	y1<Number> The y of point 1
		 * @param	y2<Number> The y of point 2
		 * @return An object with the difference between the x coordinates, dx. The difference
		 * 			between the y coordinates, dy. The actual distance, dist, and the distance
		 * 			squared, distSQ.
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		public static function getDistance(x1:Number, x2:Number, y1:Number, y2:Number):Object {
			var dx:Number = x1 - x2;
			var dy:Number = y1 - y2;
			var distSQ:Number = dx * dx + dy * dy;
			return { dx:dx, dy:dy, dist:Math.sqrt(distSQ), distSQ:distSQ };
		}
		
		/**
		 * Used to determine the distance between two 3D points.
		 * 
		 * @param	x1<Number> The x of point 1
		 * @param	x2<Number> The x of point 2
		 * @param	y1<Number> The y of point 1
		 * @param	y2<Number> The y of point 2
		 * @param	z1<Number> The z of point 1
		 * @param	z2<Number> The z of point 2
		 * @return The distance between the two points.
		 */
		public static function getDistance3D(x1:Number, x2:Number, y1:Number, y2:Number, z1:Number, z2:Number):Number {
			var dx:Number = x1 - x2;
			var dy:Number = y1 - y2;
			var dz:Number = z1 - z2;
			return Math.sqrt(dx * dx + dy * dy + dz * dz);
		}
		
		/**
		 * Takes a given coordinate and rotates it in a 2D space. This is used
		 * for calculations like collosions detection.
		 * 
		 * @param	x<Number> The x coordinate
		 * @param	y<Number> The y coordinate
		 * @param	sin<Number> The sine of the angle to rotate
		 * @param	cos<Number> The cosine of the angle to rotate
		 * @param	reverse<Number> Which direction to rotate
		 * @return The adjusted point after rotation.
		 * 
		 * @see #getAngle()
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		public static function rotateCoord(x:Number, y:Number, sin:Number, cos:Number, reverse:Boolean):Point {
			var pt:Point = new Point();
			if(reverse) {
				pt.x = x * cos + y * sin;
				pt.y = y * cos - x * sin;
			} else {
				pt.x = x * cos - y * sin;
				pt.y = y * cos + x * sin;
			}
			return pt;
		}
		
		/**
		 * Rotates a Point around another Point by the specified angle.
		 * 
		 * @param point The Point to rotate.
		 * @param centerPoint The Point to rotate this Point around.
		 * @param angle The angle (in degrees) to rotate this point.
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		*/
		public static function rotatePoint(point:Point, centerPoint:Point, angle:Number):void {
			var radians:Number = MathUtil.degreesToRadians(angle);
			var baseX:Number   = point.x - centerPoint.x;
			var baseY:Number   = point.y - centerPoint.y;
			
			point.x = (Math.cos(radians) * baseX) - (Math.sin(radians) * baseY) + centerPoint.x;
			point.y = (Math.sin(radians) * baseX) + (Math.cos(radians) * baseY) + centerPoint.y;
		}
		
		/**
		 * Returns the degree to rotate to point in that direction. This assumes you are at
		 * point 0,0.
		 * 
		 * @param	x<Number> The target x velocity.
		 * @param	y<Number> The target y velocity.
		 * @return The degrees to rotate
		 * 
		 * @see #rad2Deg()
		 * @see #getAngle()
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		public static function turnToPath(point:Point):Number {
			return MathUtil.radiansToDegrees(GeomUtil.getAngle(new Point(), point));
		}
	}
}