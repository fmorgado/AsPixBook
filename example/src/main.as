package {
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.system.System;
	
	//import assets.Book1;
	import assets.Book2;
	
	import pixbook.Book;
	
	[SWF(width="800", height="600", backgroundColor='#3d3935', frameRate='60')]
	public final class main extends Sprite {
		
		private var _book:Book;
		
		public function main():void {
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.addEventListener(Event.RESIZE, _onStageResize);
			_buildUI();
			
			_onClickOk(null);
		}
		
		private function _onStageResize(event:Event):void {
			_book.setSize(stage.stageWidth - 100, stage.stageHeight - 100);
		}
		
		private function _onBookIndexChange(event:Event):void {
			trace('_onBookIndexChange:   ' + _book.pageIndex);
		}
		
		[Embed(source="assets/icons/icon_ok.png")]
		private static const ICON_OK:Class;
		[Embed(source="assets/icons/icon_first.png")]
		private static const ICON_FIRST:Class;
		[Embed(source="assets/icons/icon_last.png")]
		private static const ICON_LAST:Class;
		[Embed(source="assets/icons/icon_next.png")]
		private static const ICON_NEXT:Class;
		[Embed(source="assets/icons/icon_previous.png")]
		private static const ICON_PREVIOUS:Class;
		[Embed(source="assets/icons/icon_delete.png")]
		private static const ICON_DELETE:Class;
		[Embed(source="assets/icons/icon_refresh.png")]
		private static const ICON_REFRESH:Class;
		
		private function _buildUI():void {
			buildButton(ICON_OK,       10, 50, _onClickOk);
			buildButton(ICON_FIRST,    10, 100, _onClickFirst);
			buildButton(ICON_PREVIOUS, 10, 150, _onClickPrevious);
			buildButton(ICON_NEXT,     10, 200, _onClickNext);
			buildButton(ICON_LAST,     10, 250, _onClickLast);
			buildButton(ICON_DELETE,   10, 300, _onClickDelete);
			buildButton(ICON_REFRESH,  10, 350, _onClickRefresh);
		}
		
		private function _onClickFirst(event:MouseEvent):void {
			if (_book != null) _book.gotoFirstPage();
		}
		private function _onClickPrevious(event:MouseEvent):void {
			if (_book != null) _book.gotoPreviousPage();
		}
		private function _onClickNext(event:MouseEvent):void {
			if (_book != null) _book.gotoNextPage();
		}
		private function _onClickLast(event:MouseEvent):void {
			if (_book != null) _book.gotoLastPage();
		}
		private function _onClickDelete(event:MouseEvent):void {
			if (_book != null) {
				_book.destroy();
				_book = null;
			}
		}
		private function _onClickOk(event:MouseEvent):void {
			if (_book == null) {
				addChild(_book = new Book(100, 100, 10));
				_book.x = _book.y = 50;
				_book.onIndexChange(_onBookIndexChange);
				_book.addAllPages(Book2.getContents());
				_onStageResize(null);
			}
		}
		private function _onClickRefresh(event:MouseEvent):void {
			System.gc();
		}
		
		private function buildButton(icon:Class, x:Number, y:Number, listener:Function):Sprite {
			var button:Sprite = new Sprite();
			button.addChild(new icon());
			button.x = x;
			button.y = y;
			button.addEventListener(MouseEvent.CLICK, listener);
			addChild(button);
			return button;
		}
		
	}
	
}