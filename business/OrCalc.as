package com.qk.core.guide.business
{
	public class OrCalc
	{
		private var _orCalcs:Array;
		public function OrCalc(str:String, variables:Object)
		{
			var clacs:Array = str.split(Operators.OR);
			_orCalcs = new Array();
			for each(var formula:String in clacs)
			{
				_orCalcs.push(new AndCalc(formula, variables));
			}
		}
		
		public function run(value:*):Boolean
		{
			for each(var calc:AndCalc in _orCalcs)
			{
				if(calc.run(value))
				{
					return true;
				}
			}
			return false;
		}
	}
}