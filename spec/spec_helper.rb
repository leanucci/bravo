$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'bravo'
require 'rspec'
require 'vcr'
require 'byebug'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  c.hook_into :webmock
  c.configure_rspec_metadata!
end

RSpec.configure do |config|
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true
end

Bravo.sale_point        = ENV['SALE'] || '0002'
Bravo.default_concepto  = 'Productos y Servicios'
Bravo.default_documento = 'CUIT'
Bravo.default_moneda    = :peso
Bravo.own_iva_cond      = :responsable_inscripto
Bravo.logger            = { log: false, level: :info }
Bravo.openssl_bin       = ENV["TRAVIS"] ? 'openssl' : '/usr/local/Cellar/openssl/1.0.2d_1/bin/openssl'
Bravo.environment = :test
