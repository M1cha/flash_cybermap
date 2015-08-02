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
	
	import org.github.material.MaterialUtils;
	
	import spark.components.Group;
	import spark.components.Label;
	import spark.primitives.BitmapImage;
	import spark.primitives.Rect;
	
	public class ElevationGraph extends Group
	{
		private var mBitmapImage:CustomBitmapImage = null;
		private var mLabel:Label = null;
		
		public function ElevationGraph() {
			mBitmapImage = new CustomBitmapImage();
			mBitmapImage.left = 0;
			mBitmapImage.top = 0;
			mBitmapImage.right = 0;
			mBitmapImage.bottom = 0;
			addElement(mBitmapImage);
			
			mLabel = new Label();
			mLabel.text = "Select a Track :)";
			mLabel.setStyle("fontFamily", "RobotoMedium");
			mLabel.setStyle("fontSize", MaterialUtils.dp2px(20));
			mLabel.setStyle("verticalAlign", "middle");
			mLabel.setStyle("textAlign", "center");
			mLabel.percentWidth = 100;
			mLabel.percentHeight = 100;
			addElement(mLabel);
		}
		
		public function onStatusUpdate(gpx:GPX, status:uint):void {
			mLabel.text = "Loading "+status+"/"+gpx.points.length+" ...";
		}
		
		public function onLoadingFinished(gpx:GPX, elevation:Object):void {
			if(elevation==null) {
				mLabel.text = "A error occured!"
				return;
			}
			
			mLabel.text = "";
			mBitmapImage.visible = true;
			
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
			mBitmapImage.setBitmapDataPublic(bmd);
		}
		
		public function drawGPX(gpx:GPX):void {
			mBitmapImage.visible = false;
			gpx.getElevation(onStatusUpdate, onLoadingFinished);
		}
	}
}
import flash.display.BitmapData;

import spark.primitives.BitmapImage;

class CustomBitmapImage extends BitmapImage {
	
	public function setBitmapDataPublic(bmd:BitmapData):void {
		setBitmapData(bmd);
	}
}