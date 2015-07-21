package com.qk.core.guide.view
{
	import com.qk.core.manager.StageManager;
	import com.qk.core.manager.UIManager;
	import com.qk.core.util.DisplayUtil;
	import com.qk.core.util.IDispose;
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import org.webgame.utils.AlignType;
	
	/**
	 *  
	 * @author nieshulong
	 * 
	 */	
	public class GuideRectView extends Sprite implements IDispose
	{
		private var _guideRect:MovieClip;
		private var _target:DisplayObject;
		
		public function GuideRectView()
		{
			super();
			this.mouseEnabled = false;
			this.mouseChildren = false;
		}
		
		public function dispose():void
		{
			hide();
			_guideRect = null;
			_target = null;
		}
		
		public function moveTo(target:DisplayObject):void
		{
			if(_guideRect == null)
			{
				_guideRect = UIManager.instance.getMovieClip("ui.zwj.guide.guideRectMc");
				this.addChild(_guideRect);
			}
			if(_target == target)
			{
				return;
			}
			if(target == null)
			{
				hide();
				return;
			}
			StageManager.registResize(alignRectArrow);
			DisplayUtil.playAllMovieClip(_guideRect);
			_target = target;
			_target.parent.addChild(this);
			alignRectArrow();
		}
		
		private function alignRectArrow():void
		{
			if(_target == null)
			{
				return;
			}
			var bounds:Rectangle = _target.getBounds(_target);
			_guideRect.width = bounds.width + 1;
			_guideRect.height = bounds.height + 1;
			var pt:Point = getTargetPoint(_target);
			_guideRect.x = pt.x;
			_guideRect.y = pt.y;
		}
		
		public function hide():void
		{
			DisplayUtil.stopAllMovieClip(this);
			DisplayUtil.removeForParent(this);
			StageManager.unregistResize(alignRectArrow);
			_target = null;
		}
		
		private function getTargetPoint(target:DisplayObject):Point
		{
			var bounds:Rectangle;
			bounds = target.getBounds(target.parent);
			var pt:Point = DisplayUtil.alignPoint(_guideRect, bounds, AlignType.MIDDLE_LEFT);
			return pt;
		}
	}
}