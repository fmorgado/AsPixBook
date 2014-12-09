package pixbook {
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	internal final class Sheet3D {
		//{ Constants & Helpers
		///////////////////////////////////////////////////////////////////////
		private static const MAX_ROTATION:Number = Math.PI;
		private static const SEGMENTS_W:int = 10;
		private static const SEGMENTS_H:int = 6;
		
		private static var matrix:Matrix = new Matrix();
		///////////////////////////////////////////////////////////////////////
		//}
		
		//{ Private variables
		///////////////////////////////////////////////////////////////////////
		/** The triangles of the object, connecting vertices. */
		private var _triangles:Vector.<Triangle3D>;
		/** The vertices of the object. */
		private var _vertices:Vector.<Vertex3D>;
		
		private var _vStripWidths:Vector.<Number>;
		private var _origVerts:Vector.<Vertex3D>;
		private var _vStripRots:Vector.<Number>;
		
		private var _boundary1:Number;
		private var _boundary2:Number;
		private var _boundary1Mod:Number;
		private var _boundary2Mod:Number;
		
		private var _bitmapRect:Rectangle;
		private var _frontMaterial:Material;
		private var _backMaterial:Material;
		///////////////////////////////////////////////////////////////////////
		//}
		
		public function Sheet3D() {
			_triangles = new <Triangle3D>[];
			_vertices = new <Vertex3D>[];
			_vStripRots = new <Number>[];
			
			_bitmapRect = new Rectangle();
			_frontMaterial = new Material();
			_frontMaterial.oneSide = true;
			_backMaterial = new Material();
			_backMaterial.oneSide = true;
			_backMaterial.opposite = true;
		}
		
		public var frontIndex:uint;
		
		public function get smooth():Boolean { return _frontMaterial.smooth; }
		public function set smooth(value:Boolean):void {
			_frontMaterial.smooth = _backMaterial.smooth = value;
		}
		
		public var transparent:Boolean = false;
		
		private function _disposeBitmaps():void {
			if (_frontMaterial.bitmap != null) {
				_frontMaterial.bitmap.dispose();
				_frontMaterial.bitmap = null;
			}
			if (_backMaterial.bitmap != null) {
				_backMaterial.bitmap.dispose();
				_backMaterial.bitmap = null;
			}
			_bitmapRect.width = -1;
			_bitmapRect.height = -1;
		}
		
		public function configure(front:DisplayObject, back:DisplayObject):void {
			var newWidth:int = int(front.width+0.5);
			if (newWidth <= 0) newWidth = 100;
			var newHeight:int = int(front.height+0.5);
			if (newHeight <= 0) newHeight = 100;
			
			if (newWidth != _bitmapRect.width || newHeight != _bitmapRect.height) {
				_disposeBitmaps();
				
				_frontMaterial.bitmap = new BitmapData(newWidth, newHeight, transparent, 0);
				_backMaterial.bitmap = new BitmapData(newWidth, newHeight, transparent, 0);
				
				_bitmapRect.width = newWidth;
				_bitmapRect.height = newHeight;
				
				setupVertices(newWidth, newHeight);
			}
			
			matrix.identity();
			matrix.scale(front.scaleX, front.scaleY);
			
			_frontMaterial.bitmap.fillRect(_bitmapRect, 0);
			_frontMaterial.bitmap.draw(front, matrix, front.transform.colorTransform);
			
			matrix.identity();
			matrix.scale(-back.scaleX, back.scaleY);
			matrix.translate(newWidth, 0);
			
			_backMaterial.bitmap.fillRect(_bitmapRect, 0);
			_backMaterial.bitmap.draw(back, matrix, front.transform.colorTransform);
		}
		
		/** Destroy the instance and its resources. */
		public function destroy():void {
			_disposeBitmaps();
			_frontMaterial = null;
			_backMaterial = null;
			
			_triangles = null;
			_vertices = null;
		}
		
		private var _progress:Number = 0;
		public function get progress():Number { return _progress; }
		public function set progress(value:Number):void {
			if (value < 0)
				value = 0;
			else if (value > 1)
				value = 1;
			_progress = value;
			
			calcVerts(value);
		}
		
		private var _forward:Boolean;
		public function get forward():Boolean { return _forward; }
		public function set forward(forward:Boolean):void {
			_forward = forward;
			if (forward) {
				_boundary1 = 55;
				_boundary2 = 110;
				_boundary1Mod = 1.4;
				_boundary2Mod = 0.3;
			} else {
				_boundary1 = -55;
				_boundary2 = 110;
				_boundary1Mod = 1.35;
				_boundary2Mod = 0.6;
			}
		}
		
		public function project(focus:Number, renderList:Vector.<Triangle3D>):void {
			var length:int = _vertices.length;
			while (length-- > 0) {
				var vertex:Vertex3D = _vertices[length];
				var persp:Number = focus / (focus + vertex.z);
				vertex.screenX = vertex.x * persp;
				vertex.screenY = -vertex.y * persp;
				vertex.screenZ = vertex.z;
			}
			
			length = _triangles.length;
			while (length --) {
				var face:Triangle3D = _triangles[length];
				if (face.visible)
					renderList[renderList.length] = face;
			}
		}
		
		private function calcVerts(progress:Number):void {
			var radians:Number = - progress * MAX_ROTATION;
			var degrees:int = int(progress * MAX_ROTATION * 180 / Math.PI);
			var vertex:Vertex3D;
			var vertex2:Vertex3D;
			
			// [A] Applies to all degrees
			var rMod:Number = _boundary1Mod;
			
			// [B] Applies to all degrees > boundary1
			if (degrees > _boundary1)
				rMod -= (degrees - _boundary1) / (_boundary2 - _boundary1) * _boundary2Mod;
			
			// Recursively multiply vStripRots elements by rMod
			for (var index:int = 0; index < SEGMENTS_W; index++) {
				_vStripRots[index] = radians;
				radians *= rMod;
			}
			
			// [C] Applies to degrees > boundary2. 
			// 	   Grow vStripRots proportionally to MAX_ROT. (Note the 'additive' nature of these 3 steps).
			if (degrees >= _boundary2) {
				for (index = 0; index < _vStripRots.length; index++) {
					var diff:Number = MAX_ROTATION - Math.abs(_vStripRots[index]);
					var rotMult:Number = degrees - _boundary2; // range: 0 to 30
					rotMult = rotMult / (180 - _boundary2); // range: 0 to 1
					_vStripRots[index] -= diff * rotMult; // range: __ to MAX_ROTATION
				}
			}
			
			// Reset vertices
			for (index = 0; index < _vertices.length; index++) {	
				var idx:Number = Math.floor(index / SEGMENTS_H) - 1;
				vertex = _vertices[index];
				vertex2 = _origVerts[index];
				if (idx >= 0) {
					vertex.x = _vStripWidths[idx];
				} else {
					vertex.x = vertex2.x;
				}
				vertex.y = vertex2.y;
				vertex.z = vertex2.z;
			}
			
			// Apply rotation
			for (index = SEGMENTS_H; index < _vertices.length; index++) {
				var idx2:Number = Math.floor(index / SEGMENTS_H) - 1;
				var angleY:Number = _vStripRots[idx2];
				vertex = _vertices[index];
				
				var cos:Number = Math.cos(angleY);
				var sin:Number = Math.sin(angleY);
				var x:Number = vertex.x;
				var z:Number = vertex.z;
				vertex.x = cos * x - sin * z;
				vertex.z = cos * z + sin * x
			}
			
			// 'connect' the rectangles
			for (index = SEGMENTS_H * 2; index < _vertices.length; index++) { // (first 2 edges are fine)
				vertex = _vertices[index];
				vertex2 = _vertices[index - SEGMENTS_H];
				vertex.x += vertex2.x;
				vertex.z += vertex2.z;
				// (y stays constant)
			}
		}
		
		private function setupVertices(width:Number, height:Number):void {
			var stripsU:Vector.<Number> = new <Number>[];
			
			_vertices.length = 0;
			_triangles.length = 0;
			
			// spaces SEGMENTS_W in a logarithmic progression
			for (var i:int = 0; i <= SEGMENTS_W; i++)
				stripsU[i] = Math.log(i+1) / Math.log(SEGMENTS_W+1);
			
			var gridY    :Number = SEGMENTS_H - 1;
			var iW       :Number = width / SEGMENTS_W;
			var iH       :Number = height / gridY;
			
			// Vertices
			for( var ix:int = 0; ix < SEGMENTS_W + 1; ix++ ) {
				for( var iy:int = 0; iy < SEGMENTS_H; iy++ ) {
					var idx:Number = Math.floor(ix / SEGMENTS_H);
					var x:Number = stripsU[idx] * width;
					var y :Number = iy * iH - (height/2);
					_vertices[_vertices.length] = new Vertex3D(x, y, 0);
				}
			}
			
			for (ix = 0; ix < SEGMENTS_W; ix++) {
				for (iy= 0; iy < gridY; iy++) {
					var face:Triangle3D = new Triangle3D(_frontMaterial);
					face.v0 = _vertices[ ix     * SEGMENTS_H + iy     ];
					face.v1 = _vertices[ (ix+1) * SEGMENTS_H + iy     ];
					face.v2 = _vertices[ ix     * SEGMENTS_H + (iy+1) ];
					face.uv0u = stripsU[ix];
					face.uv0v = iy / gridY;
					face.uv1u = stripsU[ix+1];
					face.uv1v = iy / gridY;
					face.uv2u = stripsU[ix];
					face.uv2v = (iy+1) / gridY;
					face.updateMaterialUVMatrix();
					_triangles[_triangles.length] = face;
					
					face = face.clone();
					face.material = _backMaterial;
					_triangles[_triangles.length] = face;
					
					face = new Triangle3D(_frontMaterial);
					face.v0 = _vertices[ (ix+1) * SEGMENTS_H + (iy+1) ];
					face.v1 = _vertices[ ix     * SEGMENTS_H + (iy+1) ];
					face.v2 = _vertices[ (ix+1) * SEGMENTS_H + iy     ];
					face.uv0u = stripsU[ix+1];
					face.uv0v = (iy+1) / gridY;
					face.uv1u = stripsU[ix];
					face.uv1v = (iy+1) / gridY;
					face.uv2u = stripsU[ix+1];
					face.uv2v = iy     / gridY;
					face.updateMaterialUVMatrix();
					_triangles[_triangles.length] = face;
					
					face = face.clone();
					face.material = _backMaterial;
					_triangles[_triangles.length] = face;
				}
			}
			
			// store the (unrotated) verts
			var length:uint = _vertices.length;
			_origVerts = new Vector.<Vertex3D>(length, true);
			while (length --) {
				var original:Vertex3D = new Vertex3D();
				var other:Vertex3D = _vertices[length];
				
				original.x = other.x;
				original.y = other.y;
				original.z = other.z;
				
				_origVerts[length] = original;
			}
			
			// calc rectangle widths			
			_vStripWidths = new <Number>[];
			for (var m:int = 0; m < SEGMENTS_W; m++) {
				_vStripWidths[m] = stripsU[m+1] * width - stripsU[m] * width;
			}
		}
	}
}