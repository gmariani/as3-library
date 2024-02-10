var pickerBMP:BitmapData = new BitmapData(1,1,false,0×0);
stage.addEventListener(MouseEvent.MOUSE_MOVE, checkColor);

function checkColor(e:Event) {
	pickerBMP.setPixel(0,0,0xFFFFFF); // enter background color of your SWF
	pickerBMP.draw(stage,new Matrix(1,0,0,1,-mouseX,-mouseY));
	trace (pickerBMP.getPixel(0,0));
}