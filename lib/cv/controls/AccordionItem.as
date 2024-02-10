
package cv.controls {
	
	import flash.display.Graphics;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import gs.TweenLite;

	public class AccordionItem extends Sprite {
		
		private var btnHeader:ButtonHeader;
		private var sprUpSkin:DisplayObject = new Accordion_upSkin();
		private var sprDownSkin:DisplayObject = new Accordion_downSkin();
		private var sprOverSkin:DisplayObject = new Accordion_overSkin();
		private var sprSelUpSkin:DisplayObject = new Accordion_selectedUpSkin();
		private var sprSelDownSkin:DisplayObject = new Accordion_selectedDownSkin();
		private var sprSelOverSkin:DisplayObject = new Accordion_selectedOverSkin();
		private var doContent:DisplayObject;
		private var sprMask:Sprite = new Sprite();
		private var _isOpen:Boolean = false;
		
		public function AccordionItem(strLabel:String, sprContent:DisplayObject) {
			// Add Mask
			sprMask.graphics.beginFill(0xFF0000, .5);
			sprMask.graphics.drawRect(0, 0, 1, 1);
			sprMask.graphics.endFill();
			addChild(sprMask);
			
			// Add Content
			doContent = sprContent;
			doContent.mask = sprMask;
			addChild(doContent);
			
			// Add Header
			btnHeader = new ButtonHeader(sprUpSkin, sprDownSkin, sprOverSkin, sprSelUpSkin, sprSelDownSkin, sprSelOverSkin);
			btnHeader.addLabel(strLabel);
			addChild(btnHeader);
			
			draw();
			close();
		}
		
		override public function set height(n:Number):void {
			n -= btnHeader.height;
			sprMask.height = n;
			draw();
		}
		override public function get height():Number {
			return btnHeader.height + sprMask.height;
		}
		
		override public function set width(n:Number):void {
			sprMask.width = n;
			btnHeader.width = n;
			draw();
		}
		override public function get width():Number {
			return btnHeader.width;
		}
		
		public function set label(str:String):void {
			btnHeader.label = str;
			draw();
		}
		public function get label():String { return btnHeader.label }
		
		public function get content():DisplayObject { return doContent }
		
		public function get isOpen():Boolean { return _isOpen }
		
		public function get contentHeight():Number { return doContent.height }
		public function get contentWidth():Number { return doContent.width }
		
		public function get headerHeight():Number { return btnHeader.height }
		public function get headerWidth():Number { return btnHeader.width }
		
		public function open():void {
			_isOpen = true;
			btnHeader.isSelected = true;
			btnHeader.setState(ButtonHeader.OVER_STATE);
			TweenLite.to(sprMask, .5, {height:doContent.height});
		}
		
		public function close():void {
			_isOpen = false;
			btnHeader.isSelected = false;
			btnHeader.setState(ButtonHeader.UP_STATE);
			TweenLite.to(sprMask, .5, {height:0});
		}
		
		public function toggle():void {
			if(_isOpen) {
				close();
			} else {
				open();
			}
		}
		
		private function draw():void {
			sprMask.width = btnHeader.width;
			sprMask.y = doContent.y = btnHeader.y + btnHeader.height + 1;
			sprMask.height = !_isOpen ? 0 : doContent.height + 1;
		}
	}
}

import flash.display.DisplayObject;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFieldAutoSize;
import flash.events.MouseEvent;
import flash.events.Event;
import flash.display.Sprite;

class ButtonHeader extends Sprite {
	
	public static const UP_STATE:String = "up_state";
	public static const DOWN_STATE:String = "down_state";
	public static const OVER_STATE:String = "over_state";
	
    private var sprUpSkin:DisplayObject;
	private var sprDownSkin:DisplayObject;
	private var sprOverSkin:DisplayObject;
	private var sprSelUpSkin:DisplayObject;
	private var sprSelDownSkin:DisplayObject;
	private var sprSelOverSkin:DisplayObject;
	private var txtLabel:TextField;
	private var _isSelected:Boolean = false;
	private var arrStates:Array = new Array();

    public function ButtonHeader(upState:DisplayObject = null, downState:DisplayObject = null, overState:DisplayObject = null, upSelectedState:DisplayObject = null, downSelectedState:DisplayObject = null, overSelectedState:DisplayObject = null) {
		sprUpSkin = upState;
		sprDownSkin = downState;
		sprOverSkin = overState;
		sprSelUpSkin = upSelectedState;
		sprSelDownSkin = downSelectedState;
		sprSelOverSkin = overSelectedState;
		
		addChild(sprUpSkin);
		addChild(sprDownSkin);
		addChild(sprOverSkin);
		addChild(sprSelUpSkin);
		addChild(sprSelDownSkin);
		addChild(sprSelOverSkin);
		
		arrStates = [sprUpSkin, sprDownSkin, sprOverSkin, sprSelUpSkin, sprSelDownSkin, sprSelOverSkin];
		addEventListener(MouseEvent.MOUSE_DOWN, onMouseDownHandler);
		addEventListener(MouseEvent.MOUSE_OUT, onMouseOutHandler);
		addEventListener(MouseEvent.MOUSE_UP, onMouseUpHandler);
		addEventListener(MouseEvent.MOUSE_OVER, onMouseOverHandler);
		setState(UP_STATE);
    }
	
	override public function set width(n:Number):void {
		for each(var state:DisplayObject in arrStates) {
			state.width = n;
		}
		
		txtLabel.width = sprUpSkin.width - 10;
	}
	override public function get width():Number {
		return sprUpSkin.width;
	}
	
	override public function set height(n:Number):void {
		for each(var state:DisplayObject in arrStates) {
			state.height = n;
		}
		
		txtLabel.y = (this.height - txtLabel.height) / 2;
	}
	override public function get height():Number {
		return sprUpSkin.height;
	}
	
	public function addLabel(strLabel:String):void {
		if(!txtLabel) {
			txtLabel = new TextField();
			txtLabel.x = 5;
			txtLabel.width = this.width - 10;
			txtLabel.multiline = true;
			txtLabel.wordWrap = true;
			//txtLabel.setTextFormat(txtFormat);
			txtLabel.selectable = false;
			txtLabel.autoSize = TextFieldAutoSize.LEFT;
			addChild(txtLabel);
		}
		
		txtLabel.text = strLabel;
		this.height = txtLabel.y + txtLabel.height + 3;
		txtLabel.y = (this.height - txtLabel.height) / 2;
	}
	
	public function set label(strLabel:String):void {
		txtLabel.text = strLabel;
		this.height = txtLabel.y + txtLabel.height + 3;
		txtLabel.y = (this.height - txtLabel.height) / 2;
	}
	
	public function get label():String {
		return txtLabel.text;
	}
	
	public function set isSelected(b:Boolean):void {
		_isSelected = b;
	}
	public function get isSelected():Boolean {
		return _isSelected;
	}
	
	public function setState(strState:String):void {
		for each(var state:DisplayObject in arrStates) {
			state.visible = false;
		}
		
		if(_isSelected) {
			switch(strState) {
				case UP_STATE :
					sprSelUpSkin.visible = true;
					break;
				case DOWN_STATE :
					sprSelDownSkin.visible = true;
					break;
				case OVER_STATE :
					sprSelOverSkin.visible = true;
			}
		} else {
			switch(strState) {
				case UP_STATE :
					sprUpSkin.visible = true;
					break;
				case DOWN_STATE :
					sprDownSkin.visible = true;
					break;
				case OVER_STATE :
					sprOverSkin.visible = true;
			}
		}
	}
	
	private function onMouseDownHandler(e:MouseEvent):void {
		setState(DOWN_STATE);
		this.dispatchEvent(new Event("ItemSelected", true));
	}
	private function onMouseOutHandler(e:MouseEvent):void {
		setState(UP_STATE);
	}
	private function onMouseUpHandler(e:MouseEvent):void {
		setState(OVER_STATE);
	}
	private function onMouseOverHandler(e:MouseEvent):void {
		setState(OVER_STATE);
	}
}
