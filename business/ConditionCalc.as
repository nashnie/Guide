package com.qk.core.guide.business
{
	import avmplus.getQualifiedClassName;
	
	public class ConditionCalc
	{
		private static const MAX_OPERATOR_LEN:uint = 2;
		private var _operator:String = "";
		private var _value:*;

		public function ConditionCalc(condition:String, variables:Object)
		{
			translateOperator(condition, variables);
		}

		public function calc(value:*):Boolean
		{
			switch (_operator)
			{
				case Operators.EQUAL:
					return value == _value;
				case Operators.BIGGER:
					return value > _value;
				case Operators.SMALLER:
					return value < _value;
				case Operators.BIGGER_EQUAL:
					return value >= _value;
				case Operators.SMALL_EQUAL:
					return value <= _value;
				case Operators.UNEQUAL:
					return value != _value;
				case "":
					return true;
			}
			return true;
		}

		private function translateOperator(str:String, variables:Object):void
		{
			if (str.length < MAX_OPERATOR_LEN)
			{
				return;
			}
			_operator = str.substr(0, MAX_OPERATOR_LEN);
			translateValue(str.substr(MAX_OPERATOR_LEN), variables);
		}

		private function translateValue(str:String, variables:Object):void
		{
			for(var key:String in variables)
			{
				str = str.replace("{" + key + "}", variables[key]);
			}
			switch(str)
			{
				case "true":
					_value = true;
					return;
				case "false":
					_value = false;
					return;
				case "null":
					_value = null;
					return;
				case "undefined":
					_value = undefined;
					return;
				default:
					_value = str;
			}
		}
	}
}
