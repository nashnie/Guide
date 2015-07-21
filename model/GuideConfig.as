package com.qk.core.guide.model
{
	/**
	 *
	 * @author nieshulong
	 *  
	 */	
	public class GuideConfig
	{
		[Embed(source="../../../Client/config/xml/guide.xml", mimeType="application/octet-stream")]
		private var XmlClass:Class;
		private var _xml:XML;  
		public function GuideConfig()
		{
			_xml = XML(new XmlClass());
		}
		
		public function get xml():XML
		{
			return _xml;
		}
		
		public function getGuideNodeXml(guideId:String):XML
		{
			return _xml.guide.(@id == guideId)[0];
		}
		
		public function get totalStep():uint
		{
			return _xml.totalStep[0].@num;
		}
	}
}