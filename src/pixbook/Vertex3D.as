package pixbook {
	
	/** The Vertex3D constructor lets you create 3D vertices. */
	internal final class Vertex3D {
		/** The base X coordinate. */
		public var x :Number;
		/** The base Y coordinate. */
		public var y :Number;
		/** The base Z coordinate. */
		public var z :Number;
		
		/** The projected X coordinate. */
		public var screenX:Number;
		/** The projected Y coordinate. */
		public var screenY:Number;
		/** The projected Z coordinate. */
		public var screenZ:Number;
	
		/**
		 * Creates a new Vertex3D object whose three-dimensional values are specified by the x, y and z parameters.
		 * @param	x	The horizontal coordinate value. The default value is zero.
		 * @param	y	The vertical coordinate value. The default value is zero.
		 * @param	z	The depth coordinate value. The default value is zero.
		 */
		public function Vertex3D(x:Number=0, y:Number=0, z:Number=0) {
			this.x = x;
			this.y = y;
			this.z = z;
		}
		
	}
}