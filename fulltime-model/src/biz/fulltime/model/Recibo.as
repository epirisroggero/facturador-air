package biz.fulltime.model {

import flash.events.Event;

import mx.collections.ArrayCollection;

import util.CatalogoFactory;
import util.Utils;

[Bindable]
[RemoteClass(alias="uy.com.tmwc.facturator.entity.Recibo")]
public class Recibo extends DocumentoBase {

	public var cancela:String;

	public var porcentajeDescuento:String;

	private var _facturasVinculadas:ArrayCollection;
	
	public var pendiente:Boolean = true;

	private var _nuevo:Boolean = false;

	public var departamento:String;
	
	public function Recibo() {
	}

	public function get facturasVinculadas():ArrayCollection {
		if (!_facturasVinculadas) {
			_facturasVinculadas = new ArrayCollection();
		}
		return _facturasVinculadas;
	}

	public function set facturasVinculadas(value:ArrayCollection):void {
		_facturasVinculadas = value;
	}

	public function get nuevo():Boolean {
		return _nuevo;
	}

	public function set nuevo(value:Boolean):void {
		_nuevo = value;
	}
	
	public function getDepartamento():String {
		if (departamento && departamento.length > 0) {
			return departamento;
		} else if (cliente) {
			departamento = null;
			
			var dptoCodigo:String = cliente.contacto.deptoIdCto;
			for each (var dpto:Object in CatalogoFactory.getInstance().departamentos) {
				if (dptoCodigo == dpto.codigo) {
					departamento = dpto.nombre;
					break;
				}
			}
			return departamento;
		}
		return null;
	}
	
	public function cargarDepartamento(contacto:Contacto):void {
		if (contacto) {
			var dptoCodigo:String = contacto.deptoIdCto;
			for each (var dpto:Object in CatalogoFactory.getInstance().departamentos) {
				if (dptoCodigo == dpto.codigo) {
					departamento = dpto.nombre;
					break;
				}
			}
		}
	}
	
	public override function clienteLoaded():void {
		if (cliente.contacto.ctoRUT && cliente.contacto.ctoRUT.length == 12) {
			rut = cliente.contacto.ctoRUT;
			tipoDoc = "R";
		} else {
			rut = Utils.clean_ci(cliente.contacto.ctoDocumento);
			if (cliente.contacto.ctoDocumentoTipo == "R") {
				tipoDoc = "R";
			} else {
				tipoDoc = "C";
			}
			
		}
		dispatchEvent(new Event("_changeTipoDoc"));
		
		razonSocial = cliente.contacto.ctoRSocial;
		direccion = cliente.contacto.ctoDireccion;
		
		if (cliente.contacto.ctoTelefono) {
			if (cliente.contacto.ctoTelefono.length > 30) {
				telefono = cliente.contacto.ctoTelefono.substring(0, 30);
			} else {
				telefono = cliente.contacto.ctoTelefono;
			}
		} else {
			telefono = null;
		}
		
		departamento = null;
		if (cliente.contacto) {
			cargarDepartamento(cliente.contacto);
		}
		
	}


	public static function getNuevoDocumento(comprobante:Comprobante = null):Recibo {
		var fecha:Date = new Date();
		fecha.hours = 12;
		fecha.minutes = 0;
		fecha.seconds = 0;
		
		var recibo:Recibo = new Recibo();
		recibo.comprobante = comprobante;
		recibo.nuevo = true;
		recibo.fechaDoc = fecha;
		recibo.fechaEmision = fecha;
		recibo.registroFecha = new Date();
		recibo.registroHora = new Date();
		
//		if (GeneralOptions.getInstance().loggedUser.permisoId == Usuario.USUARIO_SUPERVISOR) {
//			doc.usuIdAut = GeneralOptions.getInstance().loggedUser.codigo;
//		}
		return recibo;
	}


}

}
