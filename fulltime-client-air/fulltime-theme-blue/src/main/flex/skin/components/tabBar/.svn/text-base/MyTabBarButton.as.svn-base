package skin.components.tabBar {

import flash.events.MouseEvent;

import skin.components.tabBar.skin.MyTabBarButtonSkin;

import spark.components.Button;
import spark.components.ButtonBarButton;
import spark.components.supportClasses.TextBase;


[Event(name='closeTab', type='skin.components.tabBar.ISTabBarEvent')]
 
public class MyTabBarButton extends ButtonBarButton {

	[SkinPart(required="false")]
	public var closeButton:Button;

	private var _closeable:Boolean = true;

	public function MyTabBarButton() {
		super();

		//NOTE: this enables the button's children (aka the close button) to receive mouse events
		this.mouseChildren = true;
		
		this.setStyle("skinClass", MyTabBarButtonSkin);
	}

	[Bindable]
	public function get closeable():Boolean {
		return _closeable;
	}

	public function set closeable(val:Boolean):void {
		if (_closeable != val) {
			_closeable = val;
			closeButton.visible = val;
			/*este if es realizado debido a cambios de la version 4.0 a 4.5 de flex*/
			if (labelDisplay is TextBase) {
				(labelDisplay as TextBase).right = (val ? 30 : 14);
			}
		}
	}

	private function closeHandler(e:MouseEvent):void {
		dispatchEvent(new MyTabBarEvent(MyTabBarEvent.CLOSE_TAB, itemIndex, true));
	}

	override protected function partAdded(partName:String, instance:Object):void {
		super.partAdded(partName, instance);

		if (instance == closeButton) {
			closeButton.addEventListener(MouseEvent.CLICK, closeHandler);
			closeButton.visible = closeable;
		} else if (instance == labelDisplay) {
			/*este if es realizado debido a cambios de la version 4.0 a 4.5 de flex*/
			if (labelDisplay is TextBase) {
				(labelDisplay as TextBase).right = (closeable ? 30 : 14);
			}
		}
	}

	override protected function partRemoved(partName:String, instance:Object):void {
		super.partRemoved(partName, instance);

		if (instance == closeButton) {
			closeButton.removeEventListener(MouseEvent.CLICK, closeHandler);
		}
	}
}
}