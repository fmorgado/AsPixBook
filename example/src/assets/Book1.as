package assets {
	import flash.display.DisplayObject;
	
	public final class Book1 {
		[Embed(source="book1/1.png", smoothing="true")]
		private static const IMAGE_1:Class;
		[Embed(source="book1/2.png", smoothing="true")]
		private static const IMAGE_2:Class;
		[Embed(source="book1/3.png", smoothing="true")]
		private static const IMAGE_3:Class;
		[Embed(source="book1/4.png", smoothing="true")]
		private static const IMAGE_4:Class;
		[Embed(source="book1/5.png", smoothing="true")]
		private static const IMAGE_5:Class;
		[Embed(source="book1/6.png", smoothing="true")]
		private static const IMAGE_6:Class;
		[Embed(source="book1/7.png", smoothing="true")]
		private static const IMAGE_7:Class;
		[Embed(source="book1/8.png", smoothing="true")]
		private static const IMAGE_8:Class;
		[Embed(source="book1/9.png", smoothing="true")]
		private static const IMAGE_9:Class;
		[Embed(source="book1/10.png", smoothing="true")]
		private static const IMAGE_10:Class;
		[Embed(source="book1/11.png", smoothing="true")]
		private static const IMAGE_11:Class;
		[Embed(source="book1/12.png", smoothing="true")]
		private static const IMAGE_12:Class;
		[Embed(source="book1/13.png", smoothing="true")]
		private static const IMAGE_13:Class;
		[Embed(source="book1/14.png", smoothing="true")]
		private static const IMAGE_14:Class;
		[Embed(source="book1/15.png", smoothing="true")]
		private static const IMAGE_15:Class;
		[Embed(source="book1/16.png", smoothing="true")]
		private static const IMAGE_16:Class;
		
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
			result[12] = new IMAGE_13();
			result[13] = new IMAGE_14();
			result[14] = new IMAGE_15();
			result[15] = new IMAGE_16();
			return result;
		}
		
	}
}