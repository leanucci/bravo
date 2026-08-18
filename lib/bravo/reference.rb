# encoding: utf-8
module Bravo
  class Reference
    attr_reader :client

    def initialize
      Bravo::AuthData.fetch
      @client = Savon::Client.new(Bravo.service_url)
    end

    def alic_iva
      body = {"Auth" => Bravo.auth_hash}

      response = client.fe_param_get_tipos_iva do |soap|
        soap.namespaces["xmlns"] = "http://ar.gov.afip.dif.FEV1/"
        soap.body = body
      end

      response.to_hash
      parse_fe_param_get_tipos_iva_response(response.to_hash)
    end

    def tipos_cbte
      body = {"Auth" => Bravo.auth_hash}

      response = client.fe_param_get_tipos_cbte do |soap|
        soap.namespaces["xmlns"] = "http://ar.gov.afip.dif.FEV1/"
        soap.body = body
      end

      response.to_hash
      parse_fe_param_get_tipos_cbte_response(response.to_hash)
    end

    def condicion_iva_receptor(clase_cmp = nil)
      body = {"Auth" => Bravo.auth_hash}
      body["ClaseCmp"] = clase_cmp if clase_cmp

      response = client.fe_param_get_condicion_iva_receptor do |soap|
        soap.namespaces["xmlns"] = "http://ar.gov.afip.dif.FEV1/"
        soap.body = body
      end

      parse_condicion_iva_receptor_response(response.to_hash)
    end

    def exchange_rate(moneda)
      return 1 if moneda == :peso

      response = client.fe_param_get_cotizacion do |soap|
        soap.namespaces["xmlns"] = "http://ar.gov.afip.dif.FEV1/"
        soap.body = {"Auth" => Bravo.auth_hash, "MonId" => Bravo::MONEDAS[moneda][:codigo]}
      end

      response.to_hash[:fe_param_get_cotizacion_response][:fe_param_get_cotizacion_result][:result_get][:mon_cotiz].to_f
    end

    def ultimo_comprobante(cbte_tipo, pto_vta = nil)
      pto_vta ||= Bravo.sale_point

      response = client.fe_comp_ultimo_autorizado do |soap|
        soap.namespaces["xmlns"] = "http://ar.gov.afip.dif.FEV1/"
        soap.body = {"Auth" => Bravo.auth_hash, "PtoVta" => pto_vta, "CbteTipo" => cbte_tipo}
      end

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
