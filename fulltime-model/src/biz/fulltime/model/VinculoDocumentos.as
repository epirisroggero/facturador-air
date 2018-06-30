//------------------------------------------------------------------------------
// Copyright Notice 
// (C) Copyright 2009. All Rights Reserved 
// THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF FullTime. 
// The copyright notice above does not evidence any actual or intended publication of such  
// source code 
//------------------------------------------------------------------------------

package biz.fulltime.model {
import flash.utils.Dictionary;

import util.Maths;

[Bindable]
[RemoteClass(alias="uy.com.tmwc.facturator.entity.VinculoDocumentos")]
public class VinculoDocumentos {

	public var docIdVin1:String;

	public var docIdVin2:String;

	public var monto:String = "0.00";

	public var neto:String = "0.00";

	public var vinRtaFin:String = "0.00";

	public var descuentoPorc:String = "0.00";

	public var descuentoMonto:String = "0.00";

	public var factura:Documento;

	public var recibo:Documento;

	private var _cambios:Dictionary = new Dictionary();
	
	private var keys:Array = ["descuentoPorc", "descuentoMonto", "neto", "cancela"];


	public function VinculoDocumentos() {
		cambios["descuentoPorc"] = false;
		cambios["descuentoMonto"] = false;
		cambios["neto"] = false;
		cambios["cancela"] = false;
	}

	public function calcularRentaFinanciera(aster:Boolean, serie:String):void {
		if (serie == "A" || serie == "P") {
			vinRtaFin = BigDecimal.ZERO.setScale(2, MathContext.ROUND_HALF_EVEN).toString();
		} else {
			var montoDto:BigDecimal = new BigDecimal(descuentoMonto).setScale(4, MathContext.ROUND_HALF_EVEN);

			var neto:BigDecimal = new BigDecimal(neto).setScale(4, MathContext.ROUND_HALF_EVEN);
			var porcDesc:BigDecimal = new BigDecimal(36);

			var cociente:BigDecimal = Maths.ONE_HUNDRED.subtract(porcDesc).setScale(4, MathContext.ROUND_HALF_EVEN);
			var desc36:BigDecimal = neto.multiply(porcDesc).divideScaleRound(cociente, 4, MathContext.ROUND_HALF_EVEN).setScale(2, MathContext.ROUND_HALF_EVEN);

			var rtaFin:BigDecimal = desc36.subtract(montoDto).multiply(cociente.divideScaleRound(Maths.ONE_HUNDRED, 4, MathContext.ROUND_HALF_EVEN)).setScale(2, MathContext.ROUND_HALF_EVEN);

			vinRtaFin = rtaFin.toString();
		}
	}
	
	public function cambioPorcDto(aster:Boolean):void {
		var netoo:BigDecimal = (neto && neto.length > 0) ? new BigDecimal(neto).setScale(4, MathContext.ROUND_HALF_EVEN) : BigDecimal.ZERO.setScale(4, MathContext.ROUND_HALF_EVEN);
		
		var porcDesc:BigDecimal = descuentoPorc ? new BigDecimal(descuentoPorc).setScale(4, MathContext.ROUND_HALF_EVEN) : BigDecimal.ZERO;
		var cociente:BigDecimal = Maths.ONE_HUNDRED.subtract(porcDesc).setScale(4, MathContext.ROUND_HALF_EVEN);
		
		var montoDto:BigDecimal = BigDecimal.ZERO;
		if (cociente.compareTo(BigDecimal.ZERO) > 0) {
			montoDto = netoo.multiply(porcDesc).divideScaleRound(cociente, 4, MathContext.ROUND_HALF_EVEN).setScale(4, MathContext.ROUND_HALF_EVEN);
		}		
		descuentoMonto = montoDto.toString();
	 
		if (aster) {
			monto = netoo.add(montoDto).setScale(4, MathContext.ROUND_HALF_EVEN).toString();
		} else {
			monto = netoo.setScale(4, MathContext.ROUND_HALF_EVEN).toString();
		}
		
		for each (var key:String in keys) {
			if (key != "descuentoPorc" && cambios[key]) {
				resetCambios();
			}			
		}
	}
	
	public function cambioMontoDto(aster:Boolean):void {
		var montoDesc_:String = descuentoMonto;
		var neto_:BigDecimal = (neto && neto.length > 0) ? new BigDecimal(neto).setScale(4, MathContext.ROUND_HALF_EVEN) : BigDecimal.ZERO.setScale(4, MathContext.ROUND_HALF_EVEN);
	
		var montoDto:BigDecimal = montoDesc_ ? new BigDecimal(montoDesc_).setScale(4, MathContext.ROUND_HALF_EVEN) : BigDecimal.ZERO;
		var cociente:BigDecimal = neto_.add(montoDto).setScale(4, MathContext.ROUND_HALF_EVEN);
		
		if (cociente.compareTo(BigDecimal.ZERO) > 0) {
			descuentoPorc = Maths.ONE_HUNDRED.multiply(montoDto).divideScaleRound(cociente, 4, MathContext.ROUND_HALF_EVEN).setScale(2, MathContext.ROUND_HALF_EVEN).toString();
		} else {
			descuentoPorc = BigDecimal.ZERO.toString();
		}
		var desto:BigDecimal = descuentoPorc ? new BigDecimal(descuentoPorc).setScale(2, MathContext.ROUND_HALF_EVEN) : BigDecimal.ZERO;
		
		if (aster) {
			monto = neto_.add(montoDto).setScale(4, MathContext.ROUND_HALF_EVEN).toString();
		} else {
			monto = neto_.setScale(4, MathContext.ROUND_HALF_EVEN).toString();
		}
		
		for each (var key:String in keys) {
			if (key != "descuentoMonto" && cambios[key]) {
				resetCambios();
			}			
		}

	}
	
	public function cambioMontoNeto(aster:Boolean):void {
		var netoo:BigDecimal = (neto && neto.length > 0) ? new BigDecimal(neto).setScale(4, MathContext.ROUND_HALF_EVEN) : BigDecimal.ZERO.setScale(4, MathContext.ROUND_HALF_EVEN);

		var porcDesc:BigDecimal = descuentoPorc ? new BigDecimal(descuentoPorc).setScale(4, MathContext.ROUND_HALF_EVEN) : BigDecimal.ZERO;
		var cociente:BigDecimal = Maths.ONE_HUNDRED.subtract(porcDesc).setScale(4, MathContext.ROUND_HALF_EVEN);
		
		var montoDto:BigDecimal = BigDecimal.ZERO;
		if (cociente.compareTo(BigDecimal.ZERO) > 0) {
			montoDto = netoo.multiply(porcDesc).divideScaleRound(cociente, 4, MathContext.ROUND_HALF_EVEN).setScale(4, MathContext.ROUND_HALF_EVEN);
		}		
		descuentoMonto = montoDto.toString();
		
		if (aster) {
			monto = netoo.add(montoDto).setScale(4, MathContext.ROUND_HALF_EVEN).toString();
		} else {
			monto = netoo.setScale(4, MathContext.ROUND_HALF_EVEN).toString();
		}
		
		for each (var key:String in keys) {
			if (key != "neto" && cambios[key]) {
				resetCambios();
			}			
		}

	}
	
	public function cambioMontoCancelado(aster:Boolean):void {
		if (aster) {
			//calcularNetoyDsto(monto);
			return;
		}
		var desto:BigDecimal = descuentoPorc ? new BigDecimal(descuentoPorc).setScale(2, MathContext.ROUND_HALF_EVEN) : BigDecimal.ZERO;
		var netoo:BigDecimal = neto ? new BigDecimal(neto).setScale(4, MathContext.ROUND_HALF_EVEN) : BigDecimal.ZERO;
		
		if (aster) {
			var montoDto:BigDecimal = BigDecimal.ZERO;
			if ((Maths.ONE_HUNDRED.subtract(desto)).compareTo(BigDecimal.ZERO) != 0) {
				montoDto = netoo.multiply(desto).divideScaleRound(Maths.ONE_HUNDRED.subtract(desto), 4, MathContext.ROUND_HALF_EVEN);
			}
			monto = netoo.add(montoDto).setScale(4, MathContext.ROUND_HALF_EVEN).toString();
		} else {
			monto = netoo.setScale(4, MathContext.ROUND_HALF_EVEN).toString();
		}

		for each (var key:String in keys) {
			if ((key != "cancela") && cambios[key]) {
				resetCambios();
			}			
		}
	}

	public function get cancela():String {
		var mto:BigDecimal = new BigDecimal(monto ? monto : "0").setScale(2, MathContext.ROUND_HALF_EVEN);

		if (recibo && recibo.comprobante.aster) {
			return mto.toString();
		} else {
			var mtoDto:BigDecimal = new BigDecimal(descuentoMonto ? descuentoMonto : "0").setScale(4, MathContext.ROUND_HALF_EVEN);

			return mto.add(mtoDto).toString();
		}
	}

	/*
	public function set cancela(value:String):void {
		if (recibo && recibo.comprobante.aster) { // Para los comprobantes aster
			monto = new BigDecimal(value).setScale(2, MathContext.ROUND_HALF_EVEN).toString();
			//calcularNetoyDsto(monto);
			neto = calcularMontoNeto().toString();
			descuentoMonto = calcularMontoDto().toString();
			return;
		}
		if (!value || value.length < 1) {
			value = "0";
		}
		var cancelaMonto:BigDecimal = new BigDecimal(value);
		var cancelaNeto:BigDecimal = new BigDecimal(neto);
		var desMonto:BigDecimal = cancelaMonto.subtract(cancelaNeto);

		var desPorc:BigDecimal = BigDecimal.ZERO;
		if (cancelaMonto.compareTo(BigDecimal.ZERO) > 0) {
			desPorc = desMonto.multiply(Maths.ONE_HUNDRED).divideScaleRound(cancelaMonto, 2, MathContext.ROUND_HALF_EVEN);
		}
		descuentoPorc = desPorc.setScale(2, MathContext.ROUND_HALF_EVEN).toString();
		descuentoMonto = desMonto.setScale(2, MathContext.ROUND_HALF_EVEN).toString();
	}
	*/
	/*private function calcularNetoyDsto(monto:String) {
		var porcDesc_:String = descuentoPorc
		var porcDescu:BigDecimal = porcDesc_ ? new BigDecimal(porcDesc_).setScale(4, MathContext.ROUND_HALF_EVEN) : BigDecimal.ZERO;
		var multiplicador1:BigDecimal = Maths.ONE_HUNDRED.subtract(porcDescu).divideScaleRound(Maths.ONE_HUNDRED, 4, MathContext.ROUND_HALF_EVEN); // .64
		var multiplicador2:BigDecimal = porcDescu.divideScaleRound(Maths.ONE_HUNDRED, 4, MathContext.ROUND_HALF_EVEN); // .36
		
		if (!cambios["neto"]) { // cambio el neto en caso de este no estar fijo
			neto = new BigDecimal(monto).multiply(multiplicador1).setScale(2, MathContext.ROUND_HALF_EVEN).toString();
		}
		descuentoMonto = new BigDecimal(monto).multiply(multiplicador2).setScale(2, MathContext.ROUND_HALF_EVEN).toString();	
	}*/
	
	private function calcularPorcentageDto():BigDecimal {
		var cancelaMonto:BigDecimal = new BigDecimal(monto);
		var desMonto:BigDecimal = new BigDecimal(descuentoMonto);
		
		var desPorc:BigDecimal = BigDecimal.ZERO;
		if (cancelaMonto.compareTo(BigDecimal.ZERO) > 0) {
			desPorc = desMonto.multiply(Maths.ONE_HUNDRED).divideScaleRound(cancelaMonto, 2, MathContext.ROUND_HALF_EVEN);
		}
		return desPorc;
	}

	private function calcularMontoDto():BigDecimal {
		var netoo:BigDecimal = (neto && neto.length > 0) ? new BigDecimal(neto).setScale(4, MathContext.ROUND_HALF_EVEN) : BigDecimal.ZERO.setScale(4, MathContext.ROUND_HALF_EVEN);
		var porcDesc:BigDecimal = descuentoPorc ? new BigDecimal(descuentoPorc).setScale(4, MathContext.ROUND_HALF_EVEN) : BigDecimal.ZERO;
		
		var montoDto:BigDecimal = BigDecimal.ZERO;
		
		var cociente:BigDecimal = Maths.ONE_HUNDRED.subtract(porcDesc).setScale(4, MathContext.ROUND_HALF_EVEN);
		if (cociente.compareTo(BigDecimal.ZERO) > 0) {
			montoDto = netoo.multiply(porcDesc).divideScaleRound(cociente, 4, MathContext.ROUND_HALF_EVEN).setScale(4, MathContext.ROUND_HALF_EVEN);
		}		
		return montoDto;
	}

	private function calcularMontoNeto():BigDecimal {
		var descPorcValue:BigDecimal = descuentoPorc ? new BigDecimal(descuentoPorc).setScale(4, MathContext.ROUND_HALF_EVEN) : BigDecimal.ZERO;
		var multiplicador1:BigDecimal = Maths.ONE_HUNDRED.subtract(descPorcValue).divideScaleRound(Maths.ONE_HUNDRED, 4, MathContext.ROUND_HALF_EVEN);
		var neto:BigDecimal = new BigDecimal(monto).multiply(multiplicador1).setScale(2, MathContext.ROUND_HALF_EVEN);

		return neto;
	}
	
	private function calcularMontoCancelado():BigDecimal {
		var netoo:BigDecimal = (neto && neto.length > 0) ? new BigDecimal(neto).setScale(4, MathContext.ROUND_HALF_EVEN) : BigDecimal.ZERO.setScale(4, MathContext.ROUND_HALF_EVEN);
		var porcDesc:BigDecimal = descuentoPorc ? new BigDecimal(descuentoPorc).setScale(4, MathContext.ROUND_HALF_EVEN) : BigDecimal.ZERO;

		var montoDto:BigDecimal = BigDecimal.ZERO;

		var cociente:BigDecimal = Maths.ONE_HUNDRED.subtract(porcDesc).setScale(4, MathContext.ROUND_HALF_EVEN);
		if (cociente.compareTo(BigDecimal.ZERO) > 0) {
			montoDto = netoo.multiply(porcDesc).divideScaleRound(cociente, 4, MathContext.ROUND_HALF_EVEN).setScale(4, MathContext.ROUND_HALF_EVEN);
		}		
		return netoo.add(montoDto);
	}
	
	
	private function resetCambios():void {
		for each (var key:String in keys) {
			cambios[key] = false;
		}		
	}

	public function get cambios():Dictionary {
		return _cambios;
	}


}

}
