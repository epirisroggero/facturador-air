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

	public var descuentoPorc:String = "0.00";

	public var descuentoMonto:String = "0.00";

	public var neto:String = "0.00";
	
	public var monto:String = "0.00";

	public var vinRtaFin:String = "0.00";

	public var factura:Documento;

	public var recibo:Documento;
	
	public var nuevo:Boolean = false;

	private var _cambios:Dictionary = new Dictionary();
	
	private var keys:Array = [
		"descuentoPorc", 
		"descuentoMonto", 
		"neto", 
		"cancela"
	];


	public function VinculoDocumentos() {
		for each (var index:int in keys) {
			cambios[keys[index]] = false;
		}
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
		cambios["descuentoPorc"] = true;

		var porcentageDto:BigDecimal = descuentoPorc ? new BigDecimal(descuentoPorc).setScale(2, MathContext.ROUND_HALF_EVEN) : BigDecimal.ZERO;
		var montoDto:BigDecimal = descuentoMonto ? new BigDecimal(descuentoMonto).setScale(2, MathContext.ROUND_HALF_EVEN) : BigDecimal.ZERO;
		var montoNeto:BigDecimal = neto ? new BigDecimal(neto).setScale(4, MathContext.ROUND_HALF_EVEN) : BigDecimal.ZERO;
		var montoCancelado:BigDecimal = monto ? new BigDecimal(monto).setScale(4, MathContext.ROUND_HALF_EVEN) : BigDecimal.ZERO;
		
		if (cambios["neto"]) {
			// 1.1) Cancelado =  100/0.64 = 156.25   esto es neto / ( 1 - % del descuento )
			// 1.2) Luego monto del descuento =  100/0.64 – 100 = 56.25 esto es (neto / (1-% del descuento )) – neto
			montoCancelado = calcularMontoCancelado(porcentageDto, null, montoNeto, aster);
			montoDto = calcularMontoDescuento(null, porcentageDto, montoNeto, aster);		
			
		} else if (cambios["cancela"]) {
			// 2.1) neto = 156.25 * 0.64 = 100  esto es  Cancelado * (1 - % del dto )				
			// 2.2) monto del descuento = 156 *36 /100 = 56.25  esto es Cancelado * % de dto / 100
			montoNeto = calcularMontoNeto(montoCancelado, porcentageDto, null, aster);
			montoDto = calcularMontoDescuento(montoCancelado, porcentageDto, null, aster);
			
		} else {
			// sino ajusto monto de descuento y monto cancelado			
			montoDto = calcularMontoDescuento(null, porcentageDto, montoNeto, aster);
			montoCancelado = calcularMontoCancelado(porcentageDto, null, montoNeto, aster);
		}
			
		descuentoPorc = porcentageDto.toString();
		descuentoMonto = montoDto.toString();
		neto = montoNeto.toString();
		monto = montoCancelado.toString();
					
		for each (var key:String in keys) {
			if (key != "descuentoPorc" && cambios[key]) {
				resetCambios();
			}			
		}
	}
	
	public function cambioMontoNeto(aster:Boolean):void {
		cambios["neto"] = true;
		
		var porcentageDto:BigDecimal = descuentoPorc ? new BigDecimal(descuentoPorc).setScale(2, MathContext.ROUND_HALF_EVEN) : BigDecimal.ZERO;
		var montoDto:BigDecimal = descuentoMonto ? new BigDecimal(descuentoMonto).setScale(2, MathContext.ROUND_HALF_EVEN) : BigDecimal.ZERO;
		var montoNeto:BigDecimal = neto ? new BigDecimal(neto).setScale(4, MathContext.ROUND_HALF_EVEN) : BigDecimal.ZERO;
		var montoCancelado:BigDecimal = monto ? new BigDecimal(monto).setScale(4, MathContext.ROUND_HALF_EVEN) : BigDecimal.ZERO;
					
		if (cambios["descuentoPorc"]) {
			// 1.1) Cancelado =  100/0.64 = 156.25   esto es neto / ( 1 - % del descuento )
			// 1.2) Luego monto del descuento =  100/0.64 – 100 = 56.25 esto es (neto / (1-% del descuento )) – neto
			montoCancelado = calcularMontoCancelado(null ,montoDto, montoNeto, aster);
			montoDto = calcularMontoDescuento(null, porcentageDto, montoNeto, aster);

		} else if (cambios["cancela"]) {
			// 5.1) Monto del Descuento =  156.25 – 100 = 56.25  esto es = Monto a Cancelar menos Monto neto = 56.25
			// 5.2) % del descuento = (156.25 – 100)  / 156.25 = 36%  esto es Monto cancelado menos neto dividido cancelado = 36%
			montoDto = calcularMontoDescuento(montoCancelado, null, montoNeto, aster);
			porcentageDto = calcularPorcentageDescuento(montoCancelado, null, montoNeto, aster);
		
		} else {
			// Sinó solo ajusto el monto cancelado			
			montoDto = calcularMontoDescuento(null, porcentageDto, montoNeto, aster);
			montoCancelado = calcularMontoCancelado(null, montoDto, montoNeto, aster);
		}
		
		descuentoPorc = porcentageDto.toString();
		descuentoMonto = montoDto.toString();
		neto = montoNeto.toString();
		monto = montoCancelado.toString();
		
		for each (var key:String in keys) {
			if (key != "neto" && cambios[key]) {
				resetCambios();
			}			
		}
	}	
	
	public function cambioMontoDto(aster:Boolean):void {
		cambios["descuentoMonto"] = true;
		
		var porcentageDto:BigDecimal = descuentoPorc ? new BigDecimal(descuentoPorc).setScale(2, MathContext.ROUND_HALF_EVEN) : BigDecimal.ZERO;
		var montoDto:BigDecimal = descuentoMonto ? new BigDecimal(descuentoMonto).setScale(2, MathContext.ROUND_HALF_EVEN) : BigDecimal.ZERO;
		var montoNeto:BigDecimal = neto ? new BigDecimal(neto).setScale(4, MathContext.ROUND_HALF_EVEN) : BigDecimal.ZERO;
		var montoCancelado:BigDecimal = monto ? new BigDecimal(monto).setScale(4, MathContext.ROUND_HALF_EVEN) : BigDecimal.ZERO;
		
		if (cambios["neto"]) {
			// 3.1)  % de dto =   56.25 / (100 + 56.25) = 36 esto es monto dto. Dividido el neto + monto del descuento = 36 %
			// 3.2) Monto a Cancelar = 56.25 + 100 esto es = monto del descuento + neto
			porcentageDto = calcularPorcentageDescuento(null, montoDto, montoNeto, aster);
			montoCancelado = calcularMontoCancelado(null, montoDto, montoNeto, aster); 
			
		} else if (cambios["cancela"]) {
			// 4.1) % descuento = 56.25 / 156.25 = 36%  esto es = monto del descuento / monto a cancelar
			// 4.2) Monto neto =  156.25 – 56.25 esto es = monto a cancelar menos monto del descuento.
			porcentageDto = calcularPorcentageDescuento(montoCancelado, montoDto, null, aster);
			montoNeto = calcularMontoNeto(montoCancelado, null, montoDto, aster);
		
		} else {
			porcentageDto = calcularPorcentageDescuento(null, montoDto, montoNeto, aster);
			montoCancelado = calcularMontoCancelado(null, montoNeto, montoDto, aster); 
		}
		
		descuentoPorc = porcentageDto.toString();
		descuentoMonto = montoDto.toString();
		neto = montoNeto.toString();
		monto = montoCancelado.toString();

		for each (var key:String in keys) {
			if (key != "descuentoMonto" && cambios[key]) {
				resetCambios();
			}			
		}		
	}
	
	public function cambioMontoCancelado(aster:Boolean):void {
		cambios["cancela"] = true;

		var porcentageDto:BigDecimal = descuentoPorc ? new BigDecimal(descuentoPorc).setScale(2, MathContext.ROUND_HALF_EVEN) : BigDecimal.ZERO;
		var montoDto:BigDecimal = descuentoMonto ? new BigDecimal(descuentoMonto).setScale(2, MathContext.ROUND_HALF_EVEN) : BigDecimal.ZERO;
		var montoNeto:BigDecimal = neto ? new BigDecimal(neto).setScale(4, MathContext.ROUND_HALF_EVEN) : BigDecimal.ZERO;
		var montoCancelado:BigDecimal = monto ? new BigDecimal(monto).setScale(4, MathContext.ROUND_HALF_EVEN) : BigDecimal.ZERO;
		
		if (cambios["descuentoPorc"]) { 
			//Cargo % descuento y Cancelado : 36% y 156.25
			//2.1) neto = 156.25 * 0.64 = 100  esto es  Cancelado * (1 - % del dto )
			//2.2) monto del descuento = 156 *36 /100 = 56.25  esto es Cancelado * % de dto / 100
			montoNeto = calcularMontoNeto(montoCancelado, porcentageDto, null, aster);
			montoDto = calcularMontoDescuento(montoCancelado, porcentageDto, null, aster);
		
		} else if (cambios["descuentoMonto"]) {
			//Cargo Monto Descuento = 56.25 y Monto a Cancelar = 156.25
			//4.1) % descuento = 56.25 / 156.25 = 36%  esto es = monto del descuento / monto a cancelar
			//4.2) Monto neto = 156.25 – 56.25 esto es = monto a cancelar menos monto del descuento.
			porcentageDto = calcularPorcentageDescuento(montoCancelado, montoDto, null, aster);
			montoNeto = calcularMontoNeto(montoCancelado, null, montoDto, aster);
			
		} else if (cambios["neto"]){
			// Cambio Monto neto y monto a cancelar
			//5.1) Monto del Descuento = 156.25 – 100 = 56.25  esto es = Monto a Cancelar menos Monto neto = 56.25
			//5.2) % del descuento = (156.25 – 100)  / 156.25 = 36%  esto es Monto cancelado menos neto dividido cancelado = 36%
			montoDto = calcularMontoDescuento(montoCancelado, null, montoNeto, aster);
			porcentageDto = calcularPorcentageDescuento(montoCancelado, null, montoNeto, aster);
			
		} else {			
			montoDto = calcularMontoDescuento(montoCancelado, porcentageDto, null, aster);
			montoNeto = calcularMontoNeto(montoCancelado, porcentageDto, null, aster);
		}
		
		descuentoPorc = porcentageDto.toString();
		descuentoMonto = montoDto.toString();
		neto = montoNeto.toString();
		monto = montoCancelado.toString();
		
		for each (var key:String in keys) {
			if ((key != "cancela") && cambios[key]) {
				resetCambios();
			}			
		}
	}	

	public function calcularPorcentageDescuento(montoCancelado:BigDecimal, montoDto:BigDecimal, montoNeto:BigDecimal, aster:Boolean):BigDecimal {
		var porcentageDto:BigDecimal = BigDecimal.ZERO;
		
		if (montoDto) {
			var cociente:BigDecimal = BigDecimal.ZERO;
			if (montoNeto) {
				cociente = montoNeto.add(montoDto).setScale(4, MathContext.ROUND_HALF_EVEN);
			} else if (montoCancelado) {
				// Calcular el monto neto.
				montoNeto = calcularMontoNeto(montoCancelado, null, montoDto, aster);
				cociente = montoNeto.add(montoDto).setScale(4, MathContext.ROUND_HALF_EVEN);
			}
			if (cociente.compareTo(BigDecimal.ZERO) > 0) {
				porcentageDto = Maths.ONE_HUNDRED.multiply(montoDto).divideScaleRound(cociente, 4, MathContext.ROUND_HALF_EVEN).setScale(2, MathContext.ROUND_HALF_EVEN);
			}
		} else if (montoNeto) {
			//5.2) % del descuento = (156.25 – 100)  / 156.25 * 100 = 36%  esto es Monto cancelado menos neto dividido cancelado = 36%
			if (montoCancelado && montoCancelado.compareTo(BigDecimal.ZERO) > 0) {
				porcentageDto = montoCancelado.subtract(montoNeto).divideScaleRound(montoCancelado, 4, MathContext.ROUND_HALF_EVEN).multiply(Maths.ONE_HUNDRED);
			}
		}
		
		return porcentageDto;
	}
	
	public function calcularMontoDescuento(montoCancelado:BigDecimal, porcDto:BigDecimal, montoNeto:BigDecimal, aster:Boolean):BigDecimal {
		var montoDto:BigDecimal = BigDecimal.ZERO;
		
		if (montoNeto) {
			if (montoCancelado) {
				// 5.1) Monto del Descuento =  156.25 – 100 = 56.25  esto es = Monto a Cancelar menos Monto neto = 56.25
				montoDto = montoCancelado.subtract(montoNeto).setScale(4, MathContext.ROUND_HALF_EVEN);
			
			} else if (porcDto) {
				var cociente:BigDecimal = Maths.ONE_HUNDRED.subtract(porcDto).setScale(4, MathContext.ROUND_HALF_EVEN);
				if (cociente.compareTo(BigDecimal.ZERO) > 0) {
					montoDto = montoNeto.multiply(porcDto).divideScaleRound(cociente, 4, MathContext.ROUND_HALF_EVEN);
				}
			}
		} else if (montoCancelado) {
			if (porcDto) {
				//2.2) monto del descuento = 156 *36 /100 = 56.25  esto es Cancelado * % de dto / 100
				montoDto = montoCancelado.multiply(porcDto).divideScaleRound(Maths.ONE_HUNDRED, 4, MathContext.ROUND_HALF_EVEN)
			}
		}
		return montoDto;
	}
	
	public function calcularMontoCancelado(porcDto:BigDecimal, montoDto:BigDecimal, montoNeto:BigDecimal, aster:Boolean):BigDecimal {
		var montoCancelado:BigDecimal = BigDecimal.ZERO;

		if (montoNeto) {
			if (porcDto) {
				// 1.1) Cancelado =  100/0.64 = 156.25   esto es neto / ( 1 - % del descuento )
				var cociente:BigDecimal = Maths.ONE_HUNDRED.subtract(porcDto).divideScaleRound(Maths.ONE_HUNDRED, 4, MathContext.ROUND_HALF_EVEN);
				montoCancelado = montoNeto.divideScaleRound(cociente, 4, MathContext.ROUND_HALF_EVEN);
				
			} else if (montoDto) {
				montoCancelado = montoNeto.add(montoDto).setScale(4, MathContext.ROUND_HALF_EVEN);
			}
		} else if (porcDto) {
					
		}		
		
		return montoCancelado;
	}
	
	public function calcularMontoNeto(montoCancelado:BigDecimal, porcentageDto:BigDecimal, montoDto:BigDecimal, aster:Boolean):BigDecimal {
		var neto:BigDecimal = BigDecimal.ZERO;
		if (montoCancelado) {
			if (porcentageDto) {
				var multiplicador:BigDecimal = Maths.ONE_HUNDRED.subtract(porcentageDto).divideScaleRound(Maths.ONE_HUNDRED, 4, MathContext.ROUND_HALF_EVEN);
				neto = montoCancelado.multiply(multiplicador).setScale(2, MathContext.ROUND_HALF_EVEN);
				
			} else if (montoDto) {
				//4.2) Monto neto =  156.25 – 56.25 esto es = monto a cancelar menos monto del descuento.
				neto = montoCancelado.subtract(montoDto);
			}
		} else if (montoDto) {
			if (porcentageDto) {
				
			}
		}
		
		return neto;
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
