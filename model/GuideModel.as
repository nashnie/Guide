package com.qk.core.guide.model
{
	
	import flash.display.DisplayObject;

	public class GuideModel
	{
		public var target:DisplayObject;
		public var dir:String = GuideDirectionType.RIGHT;
		public var label:String = "";
		public var isDragable:Boolean = false;
	}
}