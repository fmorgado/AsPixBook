package pixbook {
	import flash.display.Graphics;
	import flash.geom.Matrix;
	
	internal final class Triangle3D {
		public var drawMatrix:Matrix;
		public var screenZ:Number;
		
		public var uv0u:Number;
		public var uv0v:Number;
		public var uv1u:Number;
		public var uv1v:Number;
		public var uv2u:Number;
		public var uv2v:Number;
		
		/** Used to store references to the vertices. */
		public var v0:Vertex3D;
		public var v1:Vertex3D;
		public var v2:Vertex3D;
		
		/** stores the material for this face. */
		public var material:Material;
		
		public function clone():Triangle3D {
			var result:Triangle3D = new Triangle3D();
			result.drawMatrix.copyFrom(drawMatrix);
			result.uv0u = uv0u;
			result.uv0v = uv0v;
			result.uv1u = uv1u;
			result.uv1v = uv1v;
			result.uv2u = uv2u;
			result.uv2v = uv2v;
			result.v0 = v0;
			result.v1 = v1;
			result.v2 = v2;
			result.material = material;
			return result;
		}
		
		/**
		* The Face3D constructor lets you create linear textured or solid colour triangles.
		*
		* @param	vertices	An array of Vertex3D objects for the three vertices of the triangle.
		* @param	material	A MaterialObject3D object that contains the material properties of the triangle.
		* @param	uv			An array of {x,y} objects for the corresponding UV pixel coordinates of each triangle vertex.
		*/
		public function Triangle3D(material:Material = null) {
			drawMatrix = new Matrix();
			this.material = material;
		}
		
		private static var _matrix1:Matrix = new Matrix();
		private static var _matrix2:Matrix = new Matrix();
		
		public function render(graphics:Graphics):void {
			//material.drawTriangle(this, graphics);
			if (material.bitmap == null) return;
			
			var triangleMatrix:Matrix = drawMatrix;
			
			var x0:Number = v0.screenX;
			var y0:Number = v0.screenY;
			var x1:Number = v1.screenX;
			var y1:Number = v1.screenY;
			var x2:Number = v2.screenX;
			var y2:Number = v2.screenY;
			
			_matrix1.setTo(x1 - x0, y1 - y0, x2 - x0, y2 - y0, x0, y0);
			_matrix2.copyFrom(triangleMatrix);
			_matrix2.concat(_matrix1);
			
			material.drawTo(graphics, _matrix2);
			
			graphics.moveTo(x0, y0);
			graphics.lineTo(x1, y1);
			graphics.lineTo(x2, y2);
			graphics.lineTo(x0, y0);
			graphics.endFill();
		}
		
		public function get visible():Boolean {
			var x0:Number = v0.screenX;
			var y0:Number = v0.screenY;
			
			if (material.oneSide){
				if (material.opposite){
					if ((v2.screenX - x0) * (v1.screenY - y0) - (v2.screenY - y0) * (v1.screenX - x0) > 0)
						return false;
				} else {
					if ((v2.screenX - x0) * (v1.screenY - y0) - (v2.screenY - y0) * (v1.screenX - x0) < 0)
						return false;
				}
			}
			screenZ = (v0.screenZ + v1.screenZ + v2.screenZ) / 3;
			return true;
		}
		
		public function updateMaterialUVMatrix():void {
			var w  :Number = material.width;
			var h  :Number = material.height;
			var u0 :Number = w * uv0u;
			var v0 :Number = h * (1 - uv0v);
			var u1 :Number = w * uv1u;
			var v1 :Number = h * (1 - uv1v);
			var u2 :Number = w * uv2u;
			var v2 :Number = h * (1 - uv2v);
			
			// Fix perpendicular projections
			if ( (u0 == u1 && v0 == v1) || (u0 == u2 && v0 == v2) ) {
				u0 -= (u0 > 0.05)? 0.05 : -0.05;
				v0 -= (v0 > 0.07)? 0.07 : -0.07;
			}
			
			if( u2 == u1 && v2 == v1 ) {
				u2 -= (u2 > 0.05)? 0.04 : -0.04;
				v2 -= (v2 > 0.06)? 0.06 : -0.06;
			}
			
			drawMatrix.a = 0;
			drawMatrix.setTo((u1-u0), (v1-v0), (u2-u0), (v2-v0), u0, v0);
			drawMatrix.invert();
		}
		
	}
}