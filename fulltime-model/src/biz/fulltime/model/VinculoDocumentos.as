//------------------------------------------------------------------------------
// Copyright Notice 
// (C) Copyright 2009. All Rights Reserved 
// THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF FullTime. 
// The copyright notice above does not evidence any actual or intended publication of such  
// source code 
//------------------------------------------------------------------------------

package biz.fulltime.model {
	import util.Maths;

[Bindable]
[RemoteClass(alias = "uy.com.tmwc.facturator.entity.VinculoDocumentos")]
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
	
	
	public function VinculoDocumentos() {
	}
	
	public function calcularRentaFinanciera(aster:Boolean, serie:String):void {
		if (serie == "A" || serie == "P") {
			vinRtaFin = BigDecimal.ZERO.setScale(2, MathContext.ROUND_HALF_EVEN).toString();
		} else {
//			var montoo:BigDecimal = new BigDecimal(cancela).setScale(4, MathContext.ROUND_HALF_EVEN);
//			var desto:BigDecimal = descuentoPorc ? new BigDecimal(descuentoPorc).setScale(4, MathContext.ROUND_HALF_EVEN) : BigDecimal.ZERO;
//			
//			var desc36:BigDecimal = montoo.multiply(new BigDecimal(36)).divideScaleRound(Maths.ONE_HUNDRED, 4, MathContext.ROUND_HALF_EVEN);
//			var descReal:BigDecimal = montoo.multiply(desto).divideScaleRound(Maths.ONE_HUNDRED, 4, MathContext.ROUND_HALF_EVEN);
//			
//			vinRtaFin = desc36.subtract(descReal).setScale(2, MathContext.ROUND_HALF_EVEN).toString();
			
			var montoDto:BigDecimal = new BigDecimal(descuentoMonto).setScale(4, MathContext.ROUND_HALF_EVEN);
			
			var neto:BigDecimal = new BigDecimal(neto).setScale(4, MathContext.ROUND_HALF_EVEN);
			var porcDesc:BigDecimal = new BigDecimal(36);
			
			var cociente:BigDecimal = Maths.ONE_HUNDRED.subtract(porcDesc).setScale(4, MathContext.ROUND_HALF_EVEN);
			var desc36:BigDecimal = neto.multiply(porcDesc).divideScaleRound(cociente, 4, MathContext.ROUND_HALF_EVEN).setScale(2, MathContext.ROUND_HALF_EVEN);
			
			vinRtaFin = desc36.subtract(montoDto).multiply(cociente.divideScaleRound(Maths.ONE_HUNDRED, 4, MathContext.ROUND_HALF_EVEN)).setScale(2, MathContext.ROUND_HALF_EVEN).toString();
		}
		
	}
	
	public function calcularMontoCancelado(aster:Boolean):void {
		var desto:BigDecimal = descuentoPorc ? new BigDecimal(descuentoPorc).setScale(2, MathContext.ROUND_HALF_EVEN) : BigDecimal.ZERO;
		var netoo:BigDecimal = neto ? new BigDecimal(neto).setScale(4, MathContext.ROUND_HALF_EVEN) : BigDecimal.ZERO;
		
		if (aster) {
			var montoDto:BigDecimal = BigDecimal.ZERO;
			if ((Maths.ONE_HUNDRED.subtract(desto)).compareTo(BigDecimal.ZERO) != 0) { 
				montoDto = netoo.multiply(desto).divideScaleRound(Maths.ONE_HUNDRED.subtract(desto), 4, MathContext.ROUND_HALF_EVEN);
			}
			monto = netoo.add(montoDto).setScale(2, MathContext.ROUND_HALF_EVEN).toString();
		} else {
			monto = netoo.setScale(2, MathContext.ROUND_HALF_EVEN).toString();
		}
	}

	public function get cancela():String {
		var mto:BigDecimal = new BigDecimal(monto ? monto : "0").setScale(2, MathContext.ROUND_HALF_EVEN);
	
		if (recibo && recibo.comprobante.aster) {
			return mto.toString();
		} else {
			var mtoDto:BigDecimal = new BigDecimal(descuentoMonto ? descuentoMonto : "0").setScale(2, MathContext.ROUND_HALF_EVEN);
			
			return mto.add(mtoDto).toString();
		}
	}

	public function set cancela(value:String):void {
		if (recibo && recibo.comprobante.aster) { // Para los comprobantes aster no hago nada
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
	
}

}
