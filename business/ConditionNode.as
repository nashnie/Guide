package com.qk.core.guide.business
{
	import com.qk.core.guide.GuideManager;
	import com.qk.core.guide.model.GuideSpaceInstanceRegister;
	
	import flash.utils.getQualifiedClassName;
	
	import org.webgame.ds.HashMap;

	use namespace guidespace;

	/**
	 *  
	 * @author nieshulong
	 * 
	 */
	public class ConditionNode
	{
		private var _valueFormual:OrCalc;	
		private var _valueTarget:Array;	
		private var _guide:String;		
		private var _childConditions:Array;
		private var _space:String;
		private var _final:Boolean;
		private var _pos:String;
		private var _dir:String;
		private var _isFirstNode:Boolean;
		private var _isGuideSucess:Boolean;
		private var _isShowMask:Boolean = false;
		private var _guideParamTarget:Array;
		
		public function ConditionNode(xml:XML, variable:Object, isFirstNode:Boolean = false)
		{
			_isFirstNode = isFirstNode;
			_valueFormual = new OrCalc(String(xml.@value), variable);
			_valueTarget = String(xml.@target).split(".");
			_guide = String(xml.@guide);
			_guideParamTarget = String(xml.@param).split(".");
			_final = int(xml.@final) == 1;
			_space = String(xml.@space);
			_pos = String(xml.@pos);
			_dir = String(xml.@dir);
			_isShowMask = uint(xml.@mask) == 1;
			_childConditions = new Array();
			for each(var node:XML in xml.condition)
			{
				_childConditions.push(new ConditionNode(node, variable));
			}
		}

		public function tryGuide(module:* = null):Boolean
		{
			if(_space != "")
			{
				var inter:* = getModuleInstanceByName(_space);
				if(inter != null)
				{
					module = inter;
				}
			}
			if(module == null)
			{
				if(_final)
				{
					GuideManager.instance.endGuide(false);
				}
				return false;
			}
			var target:* = getTarget(module, _valueTarget);
			var result:Boolean = _valueFormual.run(target);
			//如果当前判断成立，则进入引导状态
			if(result)
			{
				var isGuideSccess:Boolean = false;
				var isEverGuide:Boolean = false;
				for each(var condition:ConditionNode in _childConditions)
				{
					isEverGuide = true;
					//如果某个条件判断成立了，则中断后续判断
					if(condition.tryGuide(module))
					{
						isGuideSccess = true;
						break;
					}
				}
				if(_guide != "")
				{
					var guide:String = translateGuideValue(module);
					GuideManager.instance.showFuncGuide(target, _dir, guide, _isShowMask, _final);
				}
				else if(_final)
				{
					GuideManager.instance.endGuide(false);
				}
				else if(isGuideSccess == false)
				{
				}
			}
			return result;
		}
		
		private function translateGuideValue(module:*):String
		{
			var target:* = getTarget(module, _guideParamTarget);
			return _guide.replace("$param", target);
		}
		
		private function getModuleInstanceByName(name:String):*
		{
			var instanceMap:HashMap = GuideSpaceInstanceRegister.instance.spaceInstanceMap;
			for each(var instance:* in instanceMap.getValues())
			{
				var type:String = getQualifiedClassName(instance);
				type = type.split("::")[1];
				if (type == name)
				{
					return instance;
				}
			}
			return null;
		}
		
		private function getTarget(module:*, path:Array):*
		{
			var target:* = module;
			for (var i:int = 0; i < path.length; i++)
			{
				if(path[i] == "")
				{
					return target;
				}
				try
				{
					if(target == null)
					{
						return null;
					}
					target = target["getGuideParams"](path[i]);
				}
				catch (error:Error)
				{
					try
					{
						target = target[path[i]];
					}
					catch(error:Error)
					{
						path = path.slice(0, i + 1);
						trace("path", path);
					}
				}
			}
			return target;
		}
	}
}