$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'bravo'
require 'rspec'
require 'webmock/rspec'
require 'vcr'

VCR.configure do |config|
  config.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  config.hook_into :webmock
  config.configure_rspec_metadata!
  config.default_cassette_options = {
    record: ENV['VCR_RECORD'] ? :new_episodes : :none,
    match_requests_on: [:method, :uri]
  }
end

WebMock.disable_net_connect!

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.syntax = [:should, :expect]
  end

  config.around(:each) do |example|
    if example.metadata[:vcr]
      VCR.use_cassette(example.metadata[:vcr]) { example.run }
    else
      cassette_name = example.full_description.gsub(/[^\w]/, '_').downcase
      VCR.use_cassette(cassette_name) { example.run }
    end
  end
end

Bravo.pkey = "spec/fixtures/pkey"
Bravo.cert = "spec/fixtures/cert.crt"
Bravo.cuit = ENV["CUIT"] || raise(Bravo::NullOrInvalidAttribute.new, "Please set CUIT env variable.")
Bravo.sale_point = "0002"
Bravo.auth_url = "https://wsaahomo.afip.gov.ar/ws/services/LoginCms"
Bravo.service_url = "https://wswhomo.afip.gov.ar/wsfev1/service.asmx?WSDL"
Bravo.default_concepto = "Productos y Servicios"
Bravo.default_documento = "CUIT"
Bravo.default_moneda = :peso
Bravo.own_iva_cond = :responsable_inscripto
