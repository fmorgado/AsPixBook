package pixbook {
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.geom.Matrix;
	
	internal final class Material {
		public var bitmap:BitmapData;
		
		/** A Boolean value that determines whether the BitmapData texture is smoothed when rendered. */
		public var smooth:Boolean = false;
		/** A Boolean value that determines whether the texture is tiled when rendered. Defaults to false. */
		public var tiled:Boolean = false;
		/** A Boolean value that indicates whether the faces are single sided. It has preference over doubleSided. */
		public var oneSide:Boolean = true;
		/** A Boolean value that indicates whether the face is flipped. Only used if doubleSided or not singeSided. */
		public var opposite:Boolean = false;
		
		/** The width of the material. */
		public function get width():int { return bitmap == null ? 0 : bitmap.width; }
		/** The height of the material. */
		public function get height():int { return bitmap == null ? 0 : bitmap.height; }
		
		/**
		 * The Material class creates a texture from a BitmapData or a DisplayObject instance.
		 * @param  texture      A reference to an existing MovieClip loaded into memory or on stage
		 */
		public function Material(bitmap:BitmapData = null) {
			this.bitmap = bitmap;
		}
		
		internal function drawTo(graphics:Graphics, matrix:Matrix):void {
			graphics.beginBitmapFill(bitmap, matrix, tiled, smooth);
		}
		
		public function destroy():void {
			if (bitmap != null) {
				bitmap.dispose();
				bitmap = null;
			}
		}
		
	}
}