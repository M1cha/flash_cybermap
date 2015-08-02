package org.cyberteam.cybermap.gpx
{
	import com.umapper.umap.utils.rss.rss2_ns;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.PixelSnapping;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	
	import mx.containers.Canvas;
	import mx.core.UIComponent;
	import mx.utils.OnDemandEventDispatcher;
	
	import spark.components.Group;
	import spark.primitives.BitmapImage;
	import spark.primitives.Rect;
	
	public class ElevationGraph extends BitmapImage
	{
		
		
		
		public function drawGPX(gpx:GPX):void {
			var elevation:Object = gpx.getElevation();
			
			// create sprite
			var sprite:UIComponent = new UIComponent();
			var g:Graphics = sprite.graphics;
			sprite.width = elevation.data.length;
			sprite.height = elevation.max;
			
			// draw graph
			g.beginFill(0xffffff, 0.7);
			g.moveTo(0,sprite.height);
			for(var i:uint=0; i<elevation.data.length-1; i++) {
				g.lineTo(i, sprite.height-elevation.data[i]);
			}
			g.lineTo(elevation.data.length-1, sprite.height);
			g.endFill();
			
			// calculate scale
			var scaleX:Number = width/sprite.width;
			var scaleY:Number = height/sprite.height;
			
			// create matrix
			var matrix:Matrix = new Matrix();
			matrix.scale(scaleX, scaleY);
			
			// create bitmapdata
			var bmd:BitmapData = new BitmapData(width, height, true, 0);
			bmd.draw(sprite, matrix, null, null, null, true);
			
			// set new bitmap data
			setBitmapData(bmd);
		}
	}
}