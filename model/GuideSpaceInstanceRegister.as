package com.qk.core.guide.model
{
	import com.qk.core.map.MapManager;
	import com.qk.core.module.ModuleManager;
	import com.qk.core.sceneUI.MenuManager;
	import com.qk.core.sceneUI.SceneUIManager;
	import com.qk.core.sceneUI.view.OpenSkillTipView;
	
	import flash.utils.getQualifiedClassName;
	
	import org.webgame.ds.HashMap;

	/**
	 * 引导需要用到的实例注册（坐标点不需要策划来配，所以这里需要拿到实例来取得target的坐标点） 
	 * @author nieshulong
	 * 
	 */
	public class GuideSpaceInstanceRegister
	{
		private static var _instance:GuideSpaceInstanceRegister;
		public static function get instance():GuideSpaceInstanceRegister
		{
			if(_instance == null)
			{
				_instance = new GuideSpaceInstanceRegister();
			}
			return _instance;
		}
		
		private var _spaceInstanceMap:HashMap;
		public function GuideSpaceInstanceRegister()
		{
		}
		
		public function setup():void
		{
			_spaceInstanceMap = new HashMap();
			register(MenuManager.instance);
			register(MapManager.instance);
			register(SceneUIManager.instance);
			register(ModuleManager.instance);
			register(OpenSkillTipView.instance);
		}
		
		public function dispose():void
		{
			if(_spaceInstanceMap)
			{
				_spaceInstanceMap.clear();
				_spaceInstanceMap = null;
			}
		}
		
		public function register(instance:*):void
		{
			var type:String = getQualifiedClassName(instance);
			_spaceInstanceMap.add(type, instance);
		}
		
		public function unregister(key:*):void
		{
			if(key is Class)
			{
				_spaceInstanceMap.remove(key);
			}
			else
			{
				var curType:String = getQualifiedClassName(instance);
				for each(var type:String in _spaceInstanceMap)
				{
					if(type == curType)
					{
						_spaceInstanceMap.remove(type);
						return;
					}
				}
			}
		}
		
		public function get spaceInstanceMap():HashMap
		{
			return _spaceInstanceMap;
		}
		
		public function set spaceInstanceMap(value:HashMap):void
		{
			_spaceInstanceMap = value;
		}
	}
}