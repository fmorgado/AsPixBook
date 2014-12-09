package assets {
	import flash.display.DisplayObject;
	
	public final class Book2 {
		[Embed(source="book2/1.png", smoothing="true")]
		private static const IMAGE_1:Class;
		[Embed(source="book2/2.png", smoothing="true")]
		private static const IMAGE_2:Class;
		[Embed(source="book2/3.png", smoothing="true")]
		private static const IMAGE_3:Class;
		[Embed(source="book2/4.png", smoothing="true")]
		private static const IMAGE_4:Class;
		[Embed(source="book2/5.png", smoothing="true")]
		private static const IMAGE_5:Class;
		[Embed(source="book2/6.png", smoothing="true")]
		private static const IMAGE_6:Class;
		[Embed(source="book2/7.png", smoothing="true")]
		private static const IMAGE_7:Class;
		[Embed(source="book2/8.png", smoothing="true")]
		private static const IMAGE_8:Class;
		[Embed(source="book2/9.png", smoothing="true")]
		private static const IMAGE_9:Class;
		[Embed(source="book2/10.png", smoothing="true")]
		private static const IMAGE_10:Class;
		[Embed(source="book2/11.png", smoothing="true")]
		private static const IMAGE_11:Class;
		[Embed(source="book2/12.png", smoothing="true")]
		private static const IMAGE_12:Class;
		
		public static function getContents():Vector.<DisplayObject> {
			var result:Vector.<DisplayObject> = new Vector.<DisplayObject>();
			result[0]  = new IMAGE_1();
			result[1]  = new IMAGE_2();
			result[2]  = new IMAGE_3();
			result[3]  = new IMAGE_4();
			result[4]  = new IMAGE_5();
			result[5]  = new IMAGE_6();
			result[6]  = new IMAGE_7();
			result[7]  = new IMAGE_8();
			result[8]  = new IMAGE_9();
			result[9]  = new IMAGE_10();
			result[10] = new IMAGE_11();
			result[11] = new IMAGE_12();
			return result;
		}
		
	}
}