package com.qk.core.guide
{
	import com.qk.core.guide.business.Guide;
	import com.qk.core.guide.business.guidespace;
	import com.qk.core.guide.model.GuideConfig;
	import com.qk.core.guide.model.GuideDirectionType;
	import com.qk.core.guide.model.GuideModel;
	import com.qk.core.guide.model.GuideSpaceInstanceRegister;
	import com.qk.core.guide.view.GuideArrowView;
	import com.qk.core.layer.LayerDef;
	import com.qk.core.layer.LayerManager;
	import com.qk.core.net.CommandID;
	import com.qk.core.net.SocketConnection;
	import com.qk.core.util.Globals;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.utils.ByteArray;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	
	import starling.events.EventDispatcher;
	
	use namespace guidespace;
	
	/**
	 * 引导
	 * @author nieshulong
	 * 
	 */
	public class GuideManager extends EventDispatcher
	{
		private static var _instance:GuideManager;
		public static function get instance():GuideManager
		{
			if(_instance == null)
			{
				_instance = new GuideManager();
			}
			return _instance;
		}
		/**
		 * 引导持续时间 总共60s
		 */		
		private static const GUIDE_COUNTDOWN_DURATION:uint = 300;
		/**
		 * 引导持续时间 总共60s
		 */		
		private static const GUIDE_DURATION_COUNT:uint = 180;
		/**
		 * 最大引导步骤 
		 */		
		private static const MAX_GUIDE_STEP:uint = 32;
		/**
		 *引导逻辑配置 
		 */		
		private var _guideConfig:GuideConfig;
		private var _curGuide:Guide;
		private var _container:DisplayObjectContainer;
		/**
		 *引导技能，武将，装备，挂机等功能 
		 */		
		private var _curFuncArrow:GuideArrowView;
		/**
		 *引导一些点击提示的箭头比如任务，对话框，副本选择等。
		 */		
		private var _curTipsArrow:GuideArrowView;
		/**
		 *是否新手引导 
		 */		
		private var _isNoviceGuideEnd:Boolean = false;
		private var _isFuncGuideRuning:Boolean = false;
		private var _totalGuideStep:uint;
		private var _intervalId:uint;
		private var _tipsGuideModel:GuideModel;
		private var _moduleTipsGuideModel:GuideModel;
		private var _count:uint = GUIDE_DURATION_COUNT;
		private var _cacheGuideId:uint;
		
		public function GuideManager()
		{
		}
		
		public function setup():void
		{
			SocketConnection.addCmdListener(CommandID.RETURN_BUFF, onSetCacheGuideIndex);
			GuideSpaceInstanceRegister.instance.setup();
			_container = LayerManager.instance.getLayer(LayerDef.BOX);
			_guideConfig = new GuideConfig();
			_curFuncArrow = new GuideArrowView();
			_curTipsArrow = new GuideArrowView();
			_tipsGuideModel = new GuideModel();
			_moduleTipsGuideModel = new GuideModel();
			_totalGuideStep = _guideConfig.totalStep;
		}
		
		public function cacheGuideIndex(guideId:uint):void
		{
			var bytes:ByteArray = Globals.helperBytes;
			bytes.writeByte(guideId);
			SocketConnection.send(CommandID.REQUEST_BUFF, bytes);
		}
		
		private function onSetCacheGuideIndex(byte:ByteArray):void
		{
			_cacheGuideId = byte.readByte();
			autoStartGuide();
		}
		/**
		 *  
		 * 系统启动时候自动开启新手引导
		 */		
		public function autoStartGuide():void
		{
			var isGuided:Boolean = false;
			for(var guideId:uint = 1; guideId <= _totalGuideStep; guideId++)
			{
				isGuided = guideId <= _cacheGuideId;
				if(isGuided == false)
				{
					startGuideById(String(guideId));
					break;
				}
			}
			if(isGuided)
			{
				endNoviceGuide();
				_isNoviceGuideEnd = true;
			}
		}
		
		public function hideTipsGuide():void
		{
			_curTipsArrow.hide();
		}
		
		public function get isFuncGuideRuning():Boolean
		{
			return _isFuncGuideRuning;
		}
		
		guidespace function endGuide(isGuideOver:Boolean = false, isCheckTriggerGuide:Boolean = true):void
		{
			if(_curFuncArrow)
			{
				_curFuncArrow.hide();
			}
			if(_curGuide == null)
			{
				return;
			}
			_curGuide.stop();
			cacheGuideIndex(uint(_curGuide.guideId));
			stopCheckAutoEndGuide();
			_isFuncGuideRuning = false;
			if(_curGuide.nextGuide == null)
			{
				_curGuide.dispose();
				_curGuide = null;
			}
			else if(_curGuide.nextGuide != null && isGuideOver == false)
			{
				_curGuide = _curGuide.nextGuide;
				if(isCheckTriggerGuide)
				{
					checkTriggerGuide();
				}
			}
		}
		
		public function checkTriggerGuide():void
		{
			if(_curGuide)
			{
				_curGuide.checkGuide();
				_curGuide.run();
			}
			_curFuncArrow.visible = true;
		}
		
		public function showTipsGuide(target:DisplayObject, dir:String = GuideDirectionType.RIGHT, label:String = "", isDragable:Boolean = false):void
		{
			if(target == null)
			{
				return;
			}
			if(_curTipsArrow.target == target)
			{
				return;
			}
			hideTipsGuide();
			_tipsGuideModel.target = target;
			_tipsGuideModel.dir = dir;
			_tipsGuideModel.label = label;
			_tipsGuideModel.isDragable = isDragable;
			_container.addChild(_curTipsArrow);
			_curTipsArrow.moveTo(_tipsGuideModel.target, _tipsGuideModel.dir, _tipsGuideModel.label, false, _tipsGuideModel.isDragable);
		}
		
		guidespace function showFuncGuide(target:DisplayObject, dir:String = GuideDirectionType.RIGHT, label:String = "", isShowMask:Boolean = false, isFinalGuide:Boolean = false, isDragable:Boolean = true):void
		{
			if(_curGuide && _curGuide.finished && _curFuncArrow.target != target)
			{
				endGuide(false);
				return;
			}
			if(target == null)
			{
				return;
			}
			if(_curFuncArrow.target == target)
			{
				_curFuncArrow.updateGuideContent(label);
				return;
			}
			_container.addChild(_curFuncArrow);
			_curFuncArrow.moveTo(target, dir, label, isShowMask, isDragable);
			if(isFinalGuide && _curGuide)
			{
				_curGuide.finished = true;
			}
			startCheckAutoEndGuide();
			_isFuncGuideRuning = true;
		}
		
		private function startCheckAutoEndGuide():void
		{
			stopCheckAutoEndGuide();
			_intervalId = setInterval(onCheckAutoEndGuide, GUIDE_COUNTDOWN_DURATION);
		}
		
		private function stopCheckAutoEndGuide():void
		{
			_count = GUIDE_DURATION_COUNT;
			clearInterval(_intervalId);
		}
		
		protected function onCheckAutoEndGuide():void
		{
			--_count;
			if(_count == 0)
			{
				endGuide(false);
				stopCheckAutoEndGuide();
			}
		}
			
		private function startGuideById(id:String):void
		{
			_curGuide = createGuide(id);
			checkTriggerGuide();
		}
		
		private function endNoviceGuide():void
		{
			endGuide(true);
			GuideSpaceInstanceRegister.instance.dispose();
		}
		
		private function createGuide(guideId:String, variables:Object = null, nextGuideId:String = ""):Guide
		{
			if(guideId == null || guideId == "")
			{
				return null;
			}
			var guideXml:XML = _guideConfig.getGuideNodeXml(guideId);
			if(guideXml == null)
			{
				return null;
			}
			var guide:Guide = new Guide(guideXml, variables);
			if(nextGuideId != "")
			{
				guide.nextGuide = createGuide(nextGuideId, "");
			}
			else
			{
				guide.nextGuide = createGuide(guide.nextGuideId, "");
			}
			return guide;
		}
	}
}
