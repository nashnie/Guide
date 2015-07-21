package com.qk.core.guide.business
{
	import com.qk.core.guide.GuideManager;
	import com.qk.core.util.Globals;
	import com.qk.core.util.IDispose;
	
	use namespace guidespace;

	/**
	 * 
	 * @author nieshulong
	 * 
	 */	
	public class Guide implements IDispose
	{
		private static const GUIDE_ENTER_FRAME:uint = 200;
		private var _conditions:Array;
		private var _lastTime:uint;
		private var _variables:Object;
		private var _guideId:String;
		private var _nextGuideId:String;
		private var _finished:Boolean;
		private var _nextGuide:Guide;
		
		public function Guide(xml:XML, variables:Object = null)
		{
			_conditions = new Array();
			this.variables = variables;
			for each(var module:XML in xml.condition)
			{
				_conditions.push(new ConditionNode(module, variables, true));
			}
			guideId = String(xml.@id);
			nextGuideId = String(xml.@next);
		}

		public function get nextGuide():Guide
		{
			return _nextGuide;
		}

		public function set nextGuide(value:Guide):void
		{
			_nextGuide = value;
		}

		public function get finished():Boolean
		{
			return _finished;
		}

		public function set finished(value:Boolean):void
		{
			_finished = value;
		}

		public function get nextGuideId():String
		{
			return _nextGuideId;
		}

		public function set nextGuideId(value:String):void
		{
			_nextGuideId = value;
		}

		public function get guideId():String
		{
			return _guideId;
		}

		public function set guideId(value:String):void
		{
			_guideId = value;
		}

		public function get variables():Object
		{
			return _variables;
		}

		public function set variables(value:Object):void
		{
			_variables = value;
		}

		public function run():void
		{
			Globals.time.addUpdate(update);
		}
		
		public function stop():void
		{
			Globals.time.removeUpdate(update);
		}
		
		public function update(gap:Number):void
		{
			_lastTime += gap;
			if(_lastTime >= GUIDE_ENTER_FRAME)
			{
				_lastTime = 0;
				checkGuide();
			}
		}
		
		public function checkGuide():void
		{
			for each(var node:ConditionNode in _conditions)
			{
				if(node.tryGuide())
				{
					return;
				}
			}
			GuideManager.instance.showFuncGuide(null);
		}
		
		public function dispose():void
		{
			stop();
			_conditions.length = 0;
			_nextGuide = null;
			_conditions = null;
			_variables = null;
		}
	}
}