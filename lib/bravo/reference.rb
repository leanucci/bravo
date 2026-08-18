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

    ##
    # Fetches available IVA rates.
    #
    # @return [Array<Hash>] List of IVA rates with :id and :descripcion.
    def alic_iva
      response = client.call(:fe_param_get_tipos_iva, message: {"Auth" => Bravo.auth_hash})
      parse_result(response, :fe_param_get_tipos_iva, :iva_tipo)
    end

    ##
    # Fetches available invoice types.
    #
    # @return [Array<Hash>] List of invoice types with :id and :descripcion.
    def tipos_cbte
      response = client.call(:fe_param_get_tipos_cbte, message: {"Auth" => Bravo.auth_hash})
      parse_result(response, :fe_param_get_tipos_cbte, :cbte_tipo)
    end

    ##
    # Fetches available document types.
    #
    # @return [Array<Hash>] List of document types with :id and :descripcion.
    def tipos_doc
      response = client.call(:fe_param_get_tipos_doc, message: {"Auth" => Bravo.auth_hash})
      parse_result(response, :fe_param_get_tipos_doc, :doc_tipo)
    end

    ##
    # Fetches available tax types (tributos).
    #
    # @return [Array<Hash>] List of tax types with :id and :descripcion.
    def tipos_tributos
      response = client.call(:fe_param_get_tipos_tributos, message: {"Auth" => Bravo.auth_hash})
      parse_result(response, :fe_param_get_tipos_tributos, :tributo_tipo)
    end

    ##
    # Fetches available currency types.
    #
    # @return [Array<Hash>] List of currencies with :id and :descripcion.
    def tipos_monedas
      response = client.call(:fe_param_get_tipos_monedas, message: {"Auth" => Bravo.auth_hash})
      parse_result(response, :fe_param_get_tipos_monedas, :moneda)
    end

    ##
    # Fetches available optional field types.
    #
    # @return [Array<Hash>] List of optional types with :id and :descripcion.
    def tipos_opcional
      response = client.call(:fe_param_get_tipos_opcional, message: {"Auth" => Bravo.auth_hash})
      parse_result(response, :fe_param_get_tipos_opcional, :opcional_tipo)
    end

    ##
    # Fetches configured sales points (puntos de venta).
    #
    # @return [Array<Hash>] List of sales points with :nro, :emision_tipo, :bloqueado, :fch_baja.
    def ptos_venta
      response = client.call(:fe_param_get_ptos_venta, message: {"Auth" => Bravo.auth_hash})
      parse_ptos_venta(response)
    end

    ##
    # Fetches available country types.
    #
    # @return [Array<Hash>] List of countries with :id and :descripcion.
    def tipos_paises
      response = client.call(:fe_param_get_tipos_paises, message: {"Auth" => Bravo.auth_hash})
      parse_result(response, :fe_param_get_tipos_paises, :pais_tipo)
    end

    ##
    # Fetches IVA receiver conditions for invoicing.
    #
    # @param clase_cmp [String, nil] Optional filter by invoice class (A, B, C).
    # @return [Array<Hash>] List of conditions with :id, :descripcion, :clase_comprobante.
    def condicion_iva_receptor(clase_cmp = nil)
      body = {"Auth" => Bravo.auth_hash}
      body["ClaseCmp"] = clase_cmp if clase_cmp

      response = client.call(:fe_param_get_condicion_iva_receptor, message: body)
      parse_condicion_iva_receptor_response(response.to_hash)
    end

    ##
    # Fetches exchange rate for a currency.
    #
    # @param moneda [Symbol] Currency symbol (:peso, :dolar, :euro, etc).
    # @return [Float] Exchange rate to ARS.
    def exchange_rate(moneda)
      return 1 if moneda == :peso

      response = client.call(:fe_param_get_cotizacion, message: {
        "Auth" => Bravo.auth_hash,
        "MonId" => Bravo::MONEDAS[moneda][:codigo]
      })

      response.to_hash[:fe_param_get_cotizacion_response][:fe_param_get_cotizacion_result][:result_get][:mon_cotiz].to_f
    end

    ##
    # Fetches the last authorized invoice number.
    #
    # @param cbte_tipo [String] Invoice type code.
    # @param pto_vta [String, nil] Sales point number (defaults to Bravo.sale_point).
    # @return [Integer] Last authorized invoice number.
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

    def parse_result(response, operation, item_key)
      response_key = "#{operation}_response".to_sym
      result_key = "#{operation}_result".to_sym
      result = response.to_hash[response_key][result_key][:result_get][item_key]

      result = [result] unless result.is_a?(Array)
      result.map do |item|
        {
          id: item[:id].to_i,
          descripcion: item[:desc]
        }
      end
    end

    def parse_ptos_venta(response)
      result = response.to_hash[:fe_param_get_ptos_venta_response][:fe_param_get_ptos_venta_result][:result_get]
      return [] unless result

      ptos = result[:pto_venta]
      ptos = [ptos] unless ptos.is_a?(Array)

      ptos.map do |pto|
        {
          nro: pto[:nro].to_i,
          emision_tipo: pto[:emision_tipo],
          bloqueado: pto[:bloqueado],
          fch_baja: pto[:fch_baja]
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
