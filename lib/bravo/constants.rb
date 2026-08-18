# encoding: utf-8
module Bravo
  CBTE_TIPO ={
    "1"=>"Factura A",
    "2"=>"Nota de Débito A",
    "3"=>"Nota de Crédito A",
    "6"=>"Factura B",
    "7"=>"Nota de Débito B",
    "8"=>"Nota de Crédito B",
    "4"=>"Recibos A",
    "5"=>"Notas de Venta al contado A",
    "9"=>"Recibos B",
    "10"=>"Notas de Venta al contado B",
    "63"=>"Liquidacion A",
    "64"=>"Liquidacion B",
    "34"=>"Cbtes. A del Anexo I, Apartado A,inc.f),R.G.Nro. 1415",
    "35"=>"Cbtes. B del Anexo I,Apartado A,inc. f),R.G. Nro. 1415",
    "39"=>"Otros comprobantes A que cumplan con R.G.Nro. 1415",
    "40"=>"Otros comprobantes B que cumplan con R.G.Nro. 1415",
    "60"=>"Cta de Vta y Liquido prod. A",
    "61"=>"Cta de Vta y Liquido prod. B",
    "11"=>"Factura C",
    "12"=>"Nota de Débito C",
    "13"=>"Nota de Crédito C",
    "15"=>"Recibo C",
    "49"=>"Comprobante de Compra de Bienes Usados a Consumidor Final",
    "51"=>"Factura A con Leyenda \"Operación Sujeta a Retención\"",
    "52"=>"Nota de Débito A con Leyenda \"Operación Sujeta a Retención\"",
    "53"=>"Nota de Crédito A con Leyenda \"Operación Sujeta a Retención\"",
    "54"=>"Recibo A con Leyenda \"Operación Sujeta a Retención\"",
    "201"=>"Factura de Crédito electrónica MiPyMEs (FCE) A",
    "202"=>"Nota de Débito electrónica MiPyMEs (FCE) A",
    "203"=>"Nota de Crédito electrónica MiPyMEs (FCE) A",
    "206"=>"Factura de Crédito electrónica MiPyMEs (FCE) B",
    "207"=>"Nota de Débito electrónica MiPyMEs (FCE) B",
    "208"=>"Nota de Crédito electrónica MiPyMEs (FCE) B",
    "211"=>"Factura de Crédito electrónica MiPyMEs (FCE) C",
    "212"=>"Nota de Débito electrónica MiPyMEs (FCE) C",
    "213"=>"Nota de Crédito electrónica MiPyMEs (FCE) C"
  }

  CONCEPTOS = {"Productos"=>"01", "Servicios"=>"02", "Productos y Servicios"=>"03"}

  DOCUMENTOS = {"CUIT"=>"80", "CUIL"=>"86", "CDI"=>"87", "LE"=>"89", "LC"=>"90", "CI Extranjera"=>"91", "en tramite"=>"92", "Acta Nacimiento"=>"93", "CI Bs. As. RNP"=>"95", "DNI"=>"96", "Pasaporte"=>"94", "Doc. (Otro)"=>"99"}

  MONEDAS = {
    :peso  => {:codigo => "PES", :nombre =>"Pesos Argentinos"},
    :dolar => {:codigo => "DOL", :nombre =>"Dolar Estadounidense"},
    :real  => {:codigo => "012", :nombre =>"Real"},
    :euro  => {:codigo => "060", :nombre =>"Euro"},
    :oro   => {:codigo => "049", :nombre =>"Gramos de Oro Fino"}
  }

  ALIC_IVA = [["03", 0], ["04", 0.105], ["05", 0.21], ["06", 0.27], ["11", 0]]

  BILL_TYPE = {
    responsable_inscripto: {
      responsable_inscripto: "01",
      consumidor_final: "06",
      exento: "06",
      responsable_monotributo: "06"
    },
    responsable_monotributo: {
      responsable_inscripto: "01",
      consumidor_final: "11",
      exento: "06",
      responsable_monotributo: "11"
    }
  }

  CONDICION_IVA_RECEPTOR = {
    :responsable_inscripto => 1,
    :responsable_no_inscripto => 2,
    :no_responsable => 3,
    :exento => 4,
    :consumidor_final => 5,
    :responsable_monotributo => 6,
    :no_categorizado => 7,
    :proveedor_exterior => 8,
    :cliente_exterior => 9,
    :iva_liberado => 10,
    :responsable_inscripto_agente_percepcion => 11
  }
end
