package util {
import com.meychi.ascrypt3.TEA;

//-------------------------------------------------------------
public class EncryptUtils {
	
	internal static const ENCRYPTION_KEY:String = "02011972";

	public static function encryptString(s:String):String {
		var tea:TEA = new TEA();
		var encryptedString:String = tea.encrypt(s, ENCRYPTION_KEY);
		return encryptedString;
	}

	public static function decryptString(s:String):String {
		var tea:TEA = new TEA();
		var decryptedString:String = tea.decrypt(s, ENCRYPTION_KEY);
		return decryptedString;
	}
}
}