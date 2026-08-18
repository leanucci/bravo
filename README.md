# Bravo

[![CI](https://github.com/leanucci/bravo/actions/workflows/ci.yml/badge.svg)](https://github.com/leanucci/bravo/actions/workflows/ci.yml)
[![Gem Version](https://badge.fury.io/rb/bravo.svg)](https://badge.fury.io/rb/bravo)

Ruby gem for Argentine electronic invoicing (facturación electrónica). Obtains CAE (Código de Autorización Electrónico) through AFIP's WSFE web service.

## Requirements

- Ruby 2.7+
- Valid AFIP certificate and private key registered for WSFE service

## Installation

Add to your Gemfile:

```ruby
gem 'bravo'
```

Or install directly:

```bash
gem install bravo
```

## Dependencies

Bravo 2.0 uses [wsaa-ruby](https://github.com/leanucci/wsaa-ruby) for WSAA authentication. The gem handles certificate signing and token management automatically.

## Configuration

```ruby
require 'bravo'

Bravo.pkey = "/path/to/private_key"
Bravo.cert = "/path/to/certificate.crt"
Bravo.cuit = "20123456789"
Bravo.sale_point = "0001"
Bravo.own_iva_cond = :responsable_inscripto

# Environment URLs
Bravo.auth_url = "https://wsaahomo.afip.gov.ar/ws/services/LoginCms"      # Testing
Bravo.service_url = "https://wswhomo.afip.gov.ar/wsfev1/service.asmx?WSDL" # Testing

# For production, use:
# Bravo.auth_url = "https://wsaa.afip.gov.ar/ws/services/LoginCms"
# Bravo.service_url = "https://servicios1.afip.gov.ar/wsfev1/service.asmx?WSDL"

# Defaults
Bravo.default_documento = "CUIT"
Bravo.default_concepto = "Productos y Servicios"
Bravo.default_moneda = :peso
```

## Usage

### Authorize an Invoice (FECAESolicitar)

```ruby
bill = Bravo::Bill.new(
  net: 100.00,
  iva_cond: :consumidor_final,
  doc_num: "20123456789"
)
bill.aliciva_id = 5  # 21% IVA

if bill.authorize
  puts "CAE: #{bill.response.cae}"
  puts "Due date: #{bill.response.cae_due_date}"
else
  puts "Error: #{bill.response.errors}"
end
```

### Query Reference Data

```ruby
reference = Bravo::Reference.new

# Invoice types
reference.tipos_cbte
# => [{id: 1, descripcion: "Factura A"}, ...]

# Document types
reference.tipos_doc
# => [{id: 80, descripcion: "CUIT"}, ...]

# IVA rates
reference.alic_iva
# => [{id: 5, descripcion: "21%"}, ...]

# Currency types
reference.tipos_monedas
# => [{id: 1, descripcion: "Pesos Argentinos"}, ...]

# Tax types (tributos)
reference.tipos_tributos

# Optional field types
reference.tipos_opcional

# Country types
reference.tipos_paises

# Sales points
reference.ptos_venta
# => [{nro: 1, emision_tipo: "CAE", bloqueado: "N", fch_baja: nil}, ...]

# IVA receiver conditions
reference.condicion_iva_receptor
reference.condicion_iva_receptor("A")  # Filter by invoice class

# Exchange rate
reference.exchange_rate(:dolar)
# => 350.50

# Last authorized invoice number
reference.ultimo_comprobante("01")
# => 1234
```

### Query Authorized Invoices

```ruby
reference = Bravo::Reference.new

# Query a specific invoice
invoice = reference.consultar_comprobante("01", 1234)
# => {cbte_tipo: 1, cbte_nro: 1234, cae: "12345678901234", ...}
```

### CAEA (Anticipated Authorization)

```ruby
reference = Bravo::Reference.new

# Request CAEA for a period
caea = reference.solicitar_caea("202608", 2)  # August 2026, second half
# => {caea: "12345678901234", periodo: "202608", orden: 2, ...}

# Query existing CAEA
caea = reference.consultar_caea("202608", 2)
```

## Breaking Changes in 2.0

- **Savon upgraded from 0.7.x to 2.0** - Internal change, but may affect code accessing `client` directly
- **Authentication via wsaa-ruby** - No longer uses bash script; errors come from wsaa-ruby
- **Authorizer class removed** - Was unused after refactor
- **Ruby 2.7+ required** - Older versions no longer supported

## Development

```bash
bundle install
CUIT=20123456789 bundle exec rspec
```

To record new VCR cassettes:

```bash
CUIT=20123456789 VCR_RECORD=1 bundle exec rspec
```

## License

MIT License. See [LICENSE.txt](LICENSE.txt).

## Credits

- Leandro Marcucci
- Emilio Tagua (contributions and advice)
