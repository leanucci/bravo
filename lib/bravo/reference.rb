# encoding: utf-8
module Bravo
  ##
  # Queries reference data from AFIP's WSFE service.
  #
  # Provides methods to fetch IVA rates, invoice types, and other parameters.
  class Reference
    attr_reader :client

    def initialize
      Bravo::AuthData.fetch
      @client = Savon.client(wsdl: Bravo.service_url, log: false)
    end

    def alic_iva
      response = client.call(:fe_param_get_tipos_iva, message: {"Auth" => Bravo.auth_hash})
      parse_fe_param_get_tipos_iva_response(response.to_hash)
    end

    def tipos_cbte
      response = client.call(:fe_param_get_tipos_cbte, message: {"Auth" => Bravo.auth_hash})
      parse_fe_param_get_tipos_cbte_response(response.to_hash)
    end

    def condicion_iva_receptor(clase_cmp = nil)
      body = {"Auth" => Bravo.auth_hash}
      body["ClaseCmp"] = clase_cmp if clase_cmp

      response = client.call(:fe_param_get_condicion_iva_receptor, message: body)
      parse_condicion_iva_receptor_response(response.to_hash)
    end

    def exchange_rate(moneda)
      return 1 if moneda == :peso

      response = client.call(:fe_param_get_cotizacion, message: {
        "Auth" => Bravo.auth_hash,
        "MonId" => Bravo::MONEDAS[moneda][:codigo]
      })

      response.to_hash[:fe_param_get_cotizacion_response][:fe_param_get_cotizacion_result][:result_get][:mon_cotiz].to_f
    end

    def ultimo_comprobante(cbte_tipo, pto_vta = nil)
      pto_vta ||= Bravo.sale_point

      response = client.call(:fe_comp_ultimo_autorizado, message: {
        "Auth" => Bravo.auth_hash,
        "PtoVta" => pto_vta,
        "CbteTipo" => cbte_tipo
      })

      response.to_hash[:fe_comp_ultimo_autorizado_response][:fe_comp_ultimo_autorizado_result][:cbte_nro].to_i
    end

    private

    def parse_fe_param_get_tipos_cbte_response(response_hash)
      result = response_hash[:fe_param_get_tipos_cbte_response][:fe_param_get_tipos_cbte_result][:result_get][:cbte_tipo]

      result.map do |comprobante|
        {
          id: comprobante[:id].to_i,
          descripcion: comprobante[:desc]
        }
      end
    end

    def parse_fe_param_get_tipos_iva_response(response_hash)
      result = response_hash[:fe_param_get_tipos_iva_response][:fe_param_get_tipos_iva_result][:result_get][:iva_tipo]

      result.map do |iva|
        {
          id: iva[:id].to_i,
          descripcion: iva[:desc]
        }
      end
    end

    def parse_condicion_iva_receptor_response(response_hash)
      result = response_hash[:fe_param_get_condicion_iva_receptor_response][:fe_param_get_condicion_iva_receptor_result]

      return [] unless result[:result_get]

      condiciones = result[:result_get][:condicion_iva_receptor]
      condiciones = [condiciones] unless condiciones.is_a?(Array)

      condiciones.map do |c|
        {
          id: c[:id].to_i,
          descripcion: c[:desc],
          clase_comprobante: c[:cmp_clase]
        }
      end
    end
  end
end
