package skin.components.buttonBar {

import skin.components.buttonBar.skin.HatchedButtonSkin;

import spark.components.ButtonBarButton;

public class HatchedButton extends ButtonBarButton {

	[Bindable]
	[SkinPart]
	public var hatchRect:HatchRect;

	private var _hideBottomLine:Boolean = true;

	public function HatchedButton() {
		super();
		this.setStyle("skinClass", HatchedButtonSkin);
	}

	override protected function partAdded(partName:String, instance:Object):void {
		super.partAdded(partName, instance);
		if (partName == "hatchRect") {
			hatchRect.alwaysDrawBottomLine = !_hideBottomLine;
		}
	}

	public function get hideBottomLine():Boolean {
		return _hideBottomLine;
	}

	public function set hideBottomLine(val:Boolean):void {
		if (val != _hideBottomLine) {
			_hideBottomLine = val;
			if (hatchRect) {
				hatchRect.alwaysDrawBottomLine = !_hideBottomLine;
			}
		}
	}

}
}