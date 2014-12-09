# PixBook

A 3D page-flip book implementation.
This library has no dependencies.

See the [example](example/) folder.

The sheet vertices code is from [here](https://github.com/nudoru/Paper-Flip-AS3) (which is itself based on another unknown project, possibly [this one](https://github.com/danro/pv3d-pageflip-as3)).

The 3D triangle drawing code is based on [Papervision3D](https://code.google.com/p/papervision3d/) and was heavily optimized for this particular use-case, both for size and performance.

# Example

	import pixbook.Book;
	
	var book:Book = new Book(stage.stageWidth - 100, stage.stageHeight - 100);
	book.x = book.y = 50;
	addChild(book);
	
	book.addPage(/* DisplayObject Here */);
	book.addPage(/* DisplayObject Here */);
	book.addPage(/* DisplayObject Here */);
	book.addPage(/* DisplayObject Here */);
	...

Hope you enjoy!
