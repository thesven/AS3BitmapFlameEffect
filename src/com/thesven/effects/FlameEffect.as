package com.thesven.effects{
	import flash.geom.Matrix;
	import flash.display.BlendMode;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.filters.ConvolutionFilter;
	import flash.display.Bitmap;
	import flash.filters.ColorMatrixFilter;
	import flash.display.BitmapData;
	import flash.display.Sprite;

	/**
	 * @author msvendsen
	 */
	public class FlameEffect extends Sprite {
		
		[Embed(source="fire-color.png")]
		private var FireColor : Class;
		
		private var _fireColor:BitmapData;
		private var _currentFireColor:int = 0;
		
		private var _canvas:Sprite;
		private var _grey:BitmapData;
		private var _spread:ConvolutionFilter;
		private var _cooling:BitmapData;
		private var _color:ColorMatrixFilter;
		private var _offset:Array;
		private var _fire:BitmapData;
		private var _palette:Array;
		private var _zeroArray:Array;
		private var _fireBitmap:Bitmap;
		
		private var _displayRect:Rectangle;
		private var _scaleMat:Matrix;
		
		private const ZERO_POINT:Point = new Point();
		
		public function FlameEffect(canvas:Sprite, displayArea:Rectangle) {
			
			_canvas = canvas;
			_displayRect = displayArea;
			
			_scaleMat = new Matrix();
			_scaleMat.scale(0.5, 0.5);
			
			this.scaleX = this.scaleY = 2;
			
			init();
			
		}
		
		private function init():void{
			
			_fireColor = Bitmap(new FireColor).bitmapData;	
		
			_grey = new BitmapData(_displayRect.width / 2, _displayRect.height / 2, false);
			_spread = new ConvolutionFilter(3, 3, [0, 1, 0,  1, 1, 1,  0, 1, 0], 5);
			_cooling = new BitmapData(_displayRect.width / 2, _displayRect.height / 2, false, 0x0);
			_offset = [new Point(), new Point()];
			_fire = new BitmapData(_displayRect.width / 2, _displayRect.height / 2, false, 0x0);
			
			_fireBitmap = new Bitmap(_fire);
			_fireBitmap.blendMode = BlendMode.ADD;
			addChild(_fireBitmap);
			
			createCooling(0.16);
			createPalette(_currentFireColor);
			
		}
		
		public function update(e:Event) : void {
			
			_grey.draw(_canvas, _scaleMat);
			_grey.applyFilter(_grey, _grey.rect, ZERO_POINT, _spread);
			_cooling.perlinNoise(50, 50, 2, 982374, false, false, 0, true, _offset);
			_offset[0].x += 4.0;
            _offset[1].y += 2.0;
            _cooling.applyFilter(_cooling, _cooling.rect, ZERO_POINT, _color);
            _grey.draw(this._cooling, null, null, BlendMode.SUBTRACT);
            _grey.scroll(0, 3);
            _fire.paletteMap(_grey, _grey.rect, ZERO_POINT, _palette, _zeroArray, _zeroArray, _zeroArray);
			
		}
		
		private function createCooling(a:Number):void {
            _color = new ColorMatrixFilter([
                a, 0, 0, 0, 0,
                0, a, 0, 0, 0,
                0, 0, a, 0, 0,
                0, 0, 0, 1, 0
            ]);
        }
		
		private function createPalette(idx:int):void {
            _palette = [];
            _zeroArray = [];
            for (var i:int = 0; i < 256; i++) {
                _palette.push(_fireColor.getPixel(i, idx * 32));
                _zeroArray.push(0);
            }
        }
		
	}
}
