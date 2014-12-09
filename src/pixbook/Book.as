package pixbook {
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.getTimer;
	
	/** A 3D page-flip book implementation. */
	public class Book extends Sprite {
		// Private Properties
		///////////////////////////////////////////////////////////////////////
		private var _sheets:Vector.<Sheet3D>;
		private var _sheetsCache:Vector.<Sheet3D>;
		private var _renderList:Vector.<Triangle3D>;
		private var _pages:Vector.<DisplayObject>;
		
		private var _containerSprite:Sprite;
		private var _leftContainer:Sprite;
		private var _rightContainer:Sprite;
		
		private var _width:Number;
		private var _height:Number;
		private var _pageWidth:Number;
		private var _focus:Number;
		private var _fieldOfView:Number;
		
		private var _pageIndex:int = -1;
		private var _maxPageIndex:int = -1;
		
		private var _nextSheetTime:int = -1;
		private var _lastRenderTime:int;
		private var _leftIndex:int = -1;
		private var _rightIndex:int = -1;
		///////////////////////////////////////////////////////////////////////
		
		// Constructor & Miscs
		///////////////////////////////////////////////////////////////////////
		/**
		 * Constructor.
		 * @param  width        The width of the book. @default 300
		 * @param  height       The height of the book. @default 200
		 * @param  fieldOfView  The field of view. @default 20
		 */
		public function Book(width:Number = 300, height:Number = 200, fieldOfView:Number = 15) {
			_sheetsCache = new <Sheet3D>[];
			_sheets = new <Sheet3D>[];
			_renderList = new <Triangle3D>[];
			_pages = new <DisplayObject>[];
			
			addChild(_leftContainer = new Sprite());
			addChild(_rightContainer = new Sprite());
			addChild(_containerSprite = new Sprite());
			
			_fieldOfView = fieldOfView;
			setSize(width, height);
			
			addEventListener(Event.ADDED_TO_STAGE, _onAddedToStage);
		}
		
		private function _onAddedToStage(event:Event):void {
			_lastRenderTime = getTimer();
			removeEventListener(Event.ADDED_TO_STAGE, _onAddedToStage);
			addEventListener(Event.REMOVED_FROM_STAGE, _onRemovedFromStage);
			addEventListener(Event.ENTER_FRAME, _onEnterFrame);
		}
		
		private function _onRemovedFromStage(event:Event):void {
			addEventListener(Event.ADDED_TO_STAGE, _onAddedToStage);
			removeEventListener(Event.REMOVED_FROM_STAGE, _onRemovedFromStage);
			removeEventListener(Event.ENTER_FRAME, _onEnterFrame);
		}
		
		private function setLeftIndex(index:int):void {
			if (index != _leftIndex) {
				if (_leftIndex > 0)
					_leftContainer.removeChild(_pages[_leftIndex]);
				_leftIndex = index;
				if (index > 0)
					_leftContainer.addChild(_pages[index]);
			}
		}
		
		private function setRightIndex(index:int):void {
			if (index != _rightIndex) {
				if (_rightIndex >= 0 && _rightIndex < numPages)
					_rightContainer.removeChild(_pages[_rightIndex]);
				_rightIndex = index;
				if (index >= 0 && index < numPages)
					_rightContainer.addChild(_pages[index]);
			}
		}
		
		private function removeAllSheets():void {
			var length:uint = _sheets.length;
			if (length == 0) return;
			
			while (length --)
				_sheetsCache[_sheetsCache.length] = _sheets[length];
			_sheets.length = 0;
			setLeftIndex(_pageIndex - 1);
			setRightIndex(_pageIndex);
		}
		
		/** Remove all pages from the book. */
		public final function removeAllPages():void {
			removeAllSheets();
			setLeftIndex(-1);
			setRightIndex(-1);
			_pageIndex = -1;
		}
		
		/** Destroy the instance and its resources. */
		public function destroy():void {
			if (parent != null)
				parent.removeChild(this);
			
			removeAllPages();
			
			var length:uint = _sheetsCache.length;
			while (length --)
				_sheetsCache[length].destroy();
			_sheetsCache = null;
			
			_renderList = null;
		}
		
		/** The field of view. */
		public final function get fieldOfView():Number { return _fieldOfView; }
		public final function set fieldOfView(value:Number):void {
			_fieldOfView = value;
			var vfov:Number = value * (Math.PI/180);
			_focus = (_height / 2 / Math.tan(vfov));
		}
		
		/** The interval between two page flips, in milliseconds. @default 100 */
		public var flipInterval:int = 100;
		
		/** The duration of a page flip, in milliseconds. @default 600 */
		public var flipDuration:int = 600;
		
		/** Indicates if the pages have transparency. */
		public var transparent:Boolean = true;
		
		/** Indicates if the graphics are smoothed. */
		public var smooth:Boolean = true;
		///////////////////////////////////////////////////////////////////////
		
		// Size Handling
		///////////////////////////////////////////////////////////////////////
		/**
		 * Set the size of the view.
		 * @param  width   The width of the view.
		 * @param  height  The height of the view.
		 */
		public function setSize(width:Number, height:Number):void {
			_width = width;
			_height = height;
			_containerSprite.x = width / 2;
			_containerSprite.y = height / 2;
			fieldOfView = _fieldOfView;
			
			_pageWidth = Math.round(width * 0.5);
			_rightContainer.x = _pageWidth;
			
			removeAllSheets();
			
			var length:uint = _pages.length;
			while (length --) {
				var page:DisplayObject = _pages[length];
				page.width = _pageWidth;
				page.height = height;
			}
		}
		
		/** The width of the view. */
		override public final function get width():Number { return _width; }
		override public final function set width(value:Number):void {
			setSize(value, _height);
		}
		
		/** The height of the view. */
		override public final function get height():Number { return _height; }
		override public final function set height(value:Number):void {
			setSize(_width, value);
		}
		///////////////////////////////////////////////////////////////////////
		
		// Pages Handling
		///////////////////////////////////////////////////////////////////////
		/**
		 * Add a page to the book.
		 * If the book has an even number of pages, the new page will be
		 * displayed on the right, on the left otherwise.
		 * The width of <code>content</code> will be set to half the width of the book.
		 * The height of <code>content</code> will be set to the height of the book.
		 */
		public function addPage(content:DisplayObject):void {
			var index:int = _pages.length;
			
			content.width = _pageWidth;
			content.height = height;
			_pages[index] = content;
			
			if (index % 2 > 0) index ++;
			_maxPageIndex = index;
			
			if (_pageIndex < 0) {
				_rightIndex = 0;
				_rightContainer.addChild(content);
				pageIndex = 0;
			}
		}
		
		/**
		 * Add all pages to the book.
		 * @see addPage
		 */
		public function addAllPages(pages:Vector.<DisplayObject>):void {
			var length:uint = pages.length;
			for (var index:uint = 0; index < length; index++)
				addPage(pages[index]);
		}
		
		/** The number of pages. */
		public function get numPages():uint { return _pages.length; }
		///////////////////////////////////////////////////////////////////////
		
		// Page Index Handling
		///////////////////////////////////////////////////////////////////////
		/** The current page index of the right-side of the book, zero-based. */
		public function get pageIndex():int { return _pageIndex; }
		public function set pageIndex(value:int):void {
			if (numPages == 0)
				throw new Error('No pages to display');
			if (value < 0 || value > _maxPageIndex)
				throw new Error('Invalid page index:  ' + value);
			
			if (value % 2 > 0) value += 1;
			if (value == _pageIndex) return;
			_pageIndex = value;
			dispatchEvent(new Event(INDEX_CHANGE));
		}
		
		/** The maximum page index. */
		public function get maxPageIndex():int { return _maxPageIndex; }
		
		/** Go to the next page. */
		public function gotoNextPage():void {
			if (_pageIndex < _maxPageIndex)
				pageIndex += 2;
		}
		
		/** Go to the previous page. */
		public function gotoPreviousPage():void {
			if (_pageIndex > 0)
				pageIndex -= 2;
		}
		
		/** Go to the first page. */
		public function gotoFirstPage():void {
			pageIndex = 0;
		}
		
		/** Go to the last page. */
		public function gotoLastPage():void {
			pageIndex = _maxPageIndex;
		}
		///////////////////////////////////////////////////////////////////////
		
		// Render Handling
		///////////////////////////////////////////////////////////////////////
		private function addSheet(frontIndex:uint, forward:Boolean):void {
			var sheet:Sheet3D = _sheetsCache.length > 0
				? _sheetsCache.pop()
				: new Sheet3D();
			
			sheet.frontIndex = frontIndex;
			sheet.smooth = smooth;
			sheet.transparent = transparent;
			
			sheet.configure(_pages[frontIndex], _pages[frontIndex + 1]);
			sheet.forward = forward;
			sheet.progress = forward ? 0 : 1;
			
			_sheets[_sheets.length] = sheet;
		}
		
		private function _onEnterFrame(event:Event):void {
			if (_pages.length == 0) return;
			var time:Number = getTimer();
			
			// Create sheets if necessary
			if (time >= _nextSheetTime) {
				if (_leftIndex > _pageIndex) {
					addSheet(_leftIndex - 1, false);
					_nextSheetTime = time + flipInterval;
					setLeftIndex(_leftIndex - 2);
					
				} else if (_rightIndex < _pageIndex) {
					addSheet(_rightIndex,  true);
					_nextSheetTime = time + flipInterval;
					setRightIndex(_rightIndex + 2);
				}
			}
			
			// Handle Times
			var progressDelta:Number = (time - _lastRenderTime) / flipDuration;
			_lastRenderTime = time;
			
			// Advance existing sheets
			_containerSprite.graphics.clear();
			var length:uint = _sheets.length;
			if (_sheets.length == 0) return;
			
			// Advance & project sheets
			while (length-- > 0) {
				var sheet:Sheet3D = _sheets[length];
				var progress:Number = sheet.progress;
				
				if (sheet.frontIndex < _pageIndex) {
					sheet.forward = true;
					progress += progressDelta;
					
				} else {
					sheet.forward = false;
					progress -= progressDelta;
				}
				
				if (progress <= 0) {
					// Backward page flip is completed
					_sheets.splice(length, 1);
					_sheetsCache[_sheetsCache.length] = sheet;
					setRightIndex(_rightIndex - 2);
					
				} else if (progress >= 1) {
					// Forward page flip is completed
					_sheets.splice(length, 1);
					_sheetsCache[_sheetsCache.length] = sheet;
					setLeftIndex(_leftIndex + 2);
					
				} else {
					// Project sheet
					sheet.progress = progress;
					sheet.project(_focus, _renderList);
				}
			}
			
			_renderList.sort(_compareTrianglesZ);
			
			length = _renderList.length;
			while (length--)
				_renderList[length].render(_containerSprite.graphics);
			_renderList.length = 0;
		}
		
		private function _compareTrianglesZ(t1:Triangle3D, t2:Triangle3D):Number {
			return t1.screenZ < t2.screenZ ? -1 : 1;
		}
		///////////////////////////////////////////////////////////////////////
		
		// Listeners Handling
		///////////////////////////////////////////////////////////////////////
		/** The type of the event dispatched when the page index changes. */
		public static const INDEX_CHANGE:String = 'indexChange';
		
		/** Add a listener for when the property <code>pageIndex</code> changes. */
		public final function onIndexChange(listener:Function):void {
			addEventListener(INDEX_CHANGE, listener);
		}
		/** Remove a listener for when the property <code>pageIndex</code> changes. */
		public final function removeOnIndexChange(listener:Function):void {
			removeEventListener(INDEX_CHANGE, listener);
		}
		///////////////////////////////////////////////////////////////////////
	}
}