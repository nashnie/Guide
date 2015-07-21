package com.qk.core.guide.business
{
	/**
	 *  
	 * @author nieshulong
	 * 
	 */
	public class AndCalc
	{
		private var _andCalcs:Array;
		public function AndCalc(condition:String, variables:Object)
		{
			var clacs:Array = condition.split(Operators.AND);
			_andCalcs = new Array();
			for each(var formula:String in clacs)
			{
				_andCalcs.push(new ConditionCalc(formula, variables));
			}
		}
		
		public function run(value:*):Boolean
		{
			for each(var calc:ConditionCalc in _andCalcs)
			{
				if(!calc.calc(value))
				{
					return false;				
				}
			}
			return true;
		}
	}
}