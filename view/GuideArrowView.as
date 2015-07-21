package com.qk.core.guide.view
{
	import com.qk.core.guide.business.GuidePosition;
	import com.qk.core.guide.model.GuideDirectionType;
	import com.qk.core.layer.LayerDef;
	import com.qk.core.layer.LayerManager;
	import com.qk.core.manager.StageManager;
	import com.qk.core.manager.UIManager;
	import com.qk.core.module.AppModule;
	import com.qk.core.uic.BaseSprite;
	import com.qk.core.util.DisplayUtil;
	import com.qk.core.util.Globals;
	import com.qk.core.util.TweenHelper;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	import org.webgame.utils.AlignType;

	/**
	 * 引导箭头
	 * @author nieshulong
	 * 
	 */
	public class GuideArrowView extends BaseSprite
	{
		private static const CHECK_ARROW_POSITION_DURATION:uint = 500;
		private var _target:DisplayObject;
		private var _direction:String = "";
		private var _arrow:MovieClip;
		private var _guideTxt:TextField;
		private var _label:String;
		private var _mask:Sprite;
		private var _guideBgMc:MovieClip;
		private var _guideBgRect:Rectangle;
		private var _maskBounds:Rectangle;
		private var _isShowMask:Boolean;
		private var _totalTime:uint;
		private var _directionList:Array;
		private var _directionIndex:uint;
		private var _targetPoint:GuidePosition;
		private var _guidePosition:GuidePosition;
		private var _isDragable:Boolean;
		private var _offset:Point;
		private var _layer:DisplayObjectContainer;
		private var _targetModule:AppModule;
		private var _topBottonArrow:MovieClip;
		private var _leftRightArrow:MovieClip;
		
		public function GuideArrowView()
		{
			_offset = new Point();
			_mask = new Sprite();
			_directionList = [GuideDirectionType.TOP, GuideDirectionType.RIGHT, GuideDirectionType.BOTTOM, GuideDirectionType.LEFT];
			this.mouseChildren = false;
			this.mouseEnabled = false;
			_layer = LayerManager.instance.getLayer(LayerDef.BOX);
			_topBottonArrow = UIManager.instance.getMovieClip("baseUI.xdfs.guideArrowMc0");
			_leftRightArrow = UIManager.instance.getMovieClip("baseUI.xdfs.guideArrowMc1");
			_guideTxt = new TextField();
			var textFormat:TextFormat = new TextFormat("Verdana", 12, 0xFFFFFF);
			textFormat.align = TextFieldAutoSize.CENTER;
			_guideTxt.defaultTextFormat = textFormat;
			_guideTxt.wordWrap = false;
			_guideTxt.autoSize = TextFieldAutoSize.CENTER;
		}

		override public function dispose():void
		{
			hide();
			_guidePosition = null;
			_topBottonArrow = null;
			_leftRightArrow = null;
			super.dispose();
		}
		
		public function get target():DisplayObject
		{
			return _target;
		}
		
		public function updateGuideContent(label:String):void
		{
			_label = label;
			if(_guideTxt.text != _label)
			{
				_guideTxt.text = _label;
				autoLayout();
			}
		}
		
		public function update(gap:Number):void
		{
			_totalTime += gap;
			if(_totalTime >= CHECK_ARROW_POSITION_DURATION)
			{
				_totalTime = 0;
				alignView();
				alignViewByDirection();
			}
		}
		
		public function moveTo(target:DisplayObject, dir:String, label:String, isShowMask:Boolean = false, isDragable:Boolean = false):void
		{
			StageManager.registResize(alignView);
			_direction = dir;
			initGuideMc();
			_target = target;
			if(target == null)
			{
				hide();
				return;
			}
			_label = label;
			_target = target;
			_guideTxt.text = _label;
			autoLayout();
			_isShowMask = isShowMask;
			_isDragable = isDragable;
			checkArrowTargetModule();
			alignView(false);
			if(_isShowMask == false && _isDragable)
			{
				Globals.time.addUpdate(update);
			}
			tween1();
		}
		
		private function tween1():void
		{
			TweenHelper.killTweensOf(this);
			switch(_direction)
			{
				case "left":
					TweenHelper.to(this, .4, {x:-10, onComplete:tween2});
					break;
				case "right":
					TweenHelper.to(this, .4, {x:10, onComplete:tween2});
					break;
				case "top":
					TweenHelper.to(this, .4, {y:-10, onComplete:tween2});
					break;
				case "bottom":
					TweenHelper.to(this, .4, {y:10, onComplete:tween2});
					break;
			}
		}
		
		private function tween2():void
		{
			TweenHelper.to(this, .2, {x:0, y:0, onComplete:tween1});
		}
		
		public function hide():void
		{
			if(_arrow)
			{
				_arrow.x = 0;
				_arrow.y = 0;
			}
			_target = null;
			hideMaskForGuide();
			TweenHelper.killTweensOf(this);
			DisplayUtil.removeForParent(this);
			StageManager.unregistResize(alignView);
			Globals.time.removeUpdate(update);
			_directionIndex = 0;
			_targetModule = null;
		}
		
		private function alignView(isTween:Boolean = true):void
		{
			if(target == null)
			{
				return;
			}
			var parent:DisplayObjectContainer = target.parent;
			while(parent && (parent is Stage) == false)
			{
				parent = parent.parent;
			}
			if(parent == null || target.alpha == 0 || target.visible == false)
			{
				hide();
				return;
			}
			_targetPoint = getTargetPoint();
			checkArrowDepth();
			if(Math.abs(_arrow.x - _targetPoint.arrowPos.x) <= 1 && Math.abs(_arrow.y - _targetPoint.arrowPos.y) <= 1)
			{
				_arrow.alpha = 1;
				return;
			}
			TweenHelper.killTweensOf(_arrow);
			if(isTween)
			{
				TweenHelper.to(_arrow, 0.3, {x:_targetPoint.arrowPos.x, y:_targetPoint.arrowPos.y, alpha:1});
			}
			else
			{
				_arrow.alpha = 1.0;
				_arrow.x = _targetPoint.arrowPos.x;
				_arrow.y = _targetPoint.arrowPos.y;
			}
			if(_isShowMask)
			{
				drawMaskForGuide();
			}
			else
			{
				hideMaskForGuide();
			}
		}
		
		private function checkArrowDepth():void
		{
			if(_targetModule && _layer.contains(_targetModule))
			{
				var index:uint = _layer.getChildIndex(_targetModule);
				_layer.addChildAt(this, index + 1);
			}
			else if(_targetModule == null)
			{
				_layer.addChildAt(this, 0);
			}
		}
		
		private function checkArrowTargetModule():void
		{
			var obj:DisplayObject = _target;
			while(obj != null && (obj is Stage) == false)
			{
				if(obj is AppModule)
				{
					break;
				}
				obj = obj.parent;
			}
			_targetModule = obj as AppModule;
		}
		
		private function alignViewByDirection():void
		{
			if(_targetPoint == null)
			{
				return;
			}
			_directionIndex = 0;
			while(_targetPoint.arrowPos.x + _arrow.width > StageManager.stageWidth || _targetPoint.arrowPos.x < 0 || 
				_targetPoint.arrowPos.y + _arrow.height > StageManager.stageHeight || _targetPoint.arrowPos.y < 0)
			{
				DisplayUtil.removeForParent(_arrow);
				_direction = _directionList[_directionIndex];
				initGuideMc();
				_guideTxt.text = _label;
				autoLayout();
				alignView(false);
				++_directionIndex;
				if(_directionIndex >= _directionList.length)
				{
					hide();
					break;
				}
			}
		}
		
		private function initGuideMc():void
		{
			DisplayUtil.removeForParent(_arrow);
			switch(_direction)
			{
				case "left":
					_arrow = _leftRightArrow;
					_arrow.rotationMc.scaleX = -1;
					break;
				case "right":
					_arrow = _leftRightArrow;
					_arrow.rotationMc.scaleX = 1;
					break;
				case "top":
					_arrow = _topBottonArrow;
					_arrow.rotationMc.scaleY = 1;
					break;
				case "bottom":
					_arrow = _topBottonArrow;
					_arrow.rotationMc.scaleY = -1;
					break;
			}
			_guideBgMc = _arrow.rotationMc.bgMc;
			_arrow.addChild(_guideTxt);
			_guideBgRect = _guideBgMc.getBounds(_arrow);
			this.addChild(_arrow);
		}
		
		private function adjustPos(data:Object = null):void
		{
			if(_target != null)
			{
				_guideBgMc.visible = true;
				_guideBgMc.alpha = 0;
				var point:GuidePosition = getTargetPoint();
				_guideBgMc.x = point.guidePos.x;
				_guideBgMc.y = point.guidePos.y;
				TweenHelper.to(_guideBgMc, .5, {alpha:1});
			}
			drawMaskForGuide();
		}
		
		private function drawMaskForGuide():void
		{
			if(_mask == null)
			{
				_mask = new Sprite();
			}
			createMaskBounds();
			_mask.graphics.clear();
			_mask.graphics.beginFill(0x000000, .6);
			_mask.graphics.drawRect(0, 0, StageManager.stage.stageWidth, StageManager.stage.stageHeight);
			_mask.graphics.drawEllipse(_maskBounds.x, _maskBounds.y, _maskBounds.width, _maskBounds.height);
			_mask.graphics.endFill();
			this.addChildAt(_mask, 0);
		}
		
		private function hideMaskForGuide():void
		{
			DisplayUtil.removeForParent(_mask);
		}
		
		private function getTargetPoint():GuidePosition
		{
			var bounds:Rectangle = _target.getBounds(_target);
			if(_guidePosition == null)
			{
				_guidePosition = new GuidePosition();
			}
			_offset.x = 0;
			_offset.y = 0;
			switch(_direction)
			{
				case "left":
					_offset.x = -(_arrow.width + bounds.width) / 2 - 1; 
					break;
				case "right":
					_offset.x = (_arrow.width + bounds.width) / 2 + 1;
					break;
				case "top":
					_offset.y = -(_arrow.height + bounds.height) / 2 - 1;
					break;
				case "bottom":
					_offset.y =  (_arrow.height + bounds.height) / 2 + 1;
					break;
				case "topLeft":
					_offset.y = -_arrow.height;
					_offset.x = -_arrow.width / 2 - 1;
					break;
			}
			var pt:Point = DisplayUtil.alignPoint(_arrow, bounds, AlignType.MIDDLE_CENTER, _offset);
			_guidePosition.arrowPos = _target.localToGlobal(pt);
			return _guidePosition;
		}
		
		private function createMaskBounds():void
		{
			var bounds:Rectangle = _target.getBounds(_target);
			var topLeft:Point = target.localToGlobal(new Point(bounds.left, bounds.top));
			_maskBounds = bounds.clone();
			_maskBounds.x = topLeft.x;
			_maskBounds.y = topLeft.y;
			_maskBounds.inflate(3, 3);
		}
		
		private function autoLayout():void
		{
			var targetWidth:uint;
			if(_direction == GuideDirectionType.LEFT || _direction == GuideDirectionType.RIGHT)
			{
				targetWidth = _guideTxt.width + 40 < 153 ? 153 : _guideTxt.width + 40;
				_guideBgMc.width = targetWidth;
				_guideBgMc.x = 26;
				_guideBgRect = _guideBgMc.getBounds(_arrow);
				_arrow.rotationMc.topLeftMc.x = 0;
				_arrow.rotationMc.topRightMc.x = _guideBgMc.width + _guideBgMc.x - 6;
				_guideTxt.x = ((_guideBgRect.width - _guideTxt.width) >> 1) + _guideBgRect.x;
				_guideTxt.y  = _guideBgRect.y + (_guideBgRect.height - _guideTxt.height) / 2;
			}
			else
			{
				targetWidth = _guideTxt.width + 30 < 172 ? 172 : _guideTxt.width + 30;
				_guideBgMc.width = targetWidth;
				_guideBgRect = _guideBgMc.getBounds(_arrow);
				_arrow.rotationMc.topArrowMc.x = (_guideBgMc.width - _arrow.rotationMc.topArrowMc.width) >> 1;
				_arrow.rotationMc.bottomArrowMc.x = (_guideBgMc.width - _arrow.rotationMc.bottomArrowMc.width) >> 1;
				_guideTxt.x = (_guideBgRect.width - _guideTxt.width) >> 1;
				_guideTxt.y  = _guideBgRect.y + (_guideBgRect.height - _guideTxt.height) / 2;
			}
		}
	}
}
