# AGENTS.md

This file provides guidance to AI agents working on this repository.

## Skills

Reusable workflows are located in `agents/skills/`. Read and follow these when applicable:

- `feature.md` - Complete feature development workflow (issue -> PR -> CI -> merge -> release)

## Writing Convention

Use ASD-STE100 (Simplified Technical English) for all communication:

- Write short sentences (20 words maximum)
- Use active voice
- Use approved vocabulary only
- Use one meaning per word
- Write instructions as commands

## Coding Conventions

### RDoc Documentation

Add RDoc comments to all public classes and methods. Follow this format:

```ruby
##
# Short description of the class or method.
#
# @param name [Type] Description of the parameter.
# @return [Type] Description of the return value.
# @raise [ErrorClass] Description of when this error occurs.
#
# @example
#   result = method_name(arg)
#   # => expected output
```

Apply this requirement to all new code and modified code.

### Git Commits

- Make commits atomic: include only one coherent change or fix
- Do not mix unrelated work in a single commit
- Write succinct commit messages that describe the change
- Add both co-authors to each commit message:
  ```
  Co-Authored-By: Leandro Marcucci <leanucci@gmail.com>
  Co-Authored-By: Claude <noreply@anthropic.com>
  ```

## Project Overview

Bravo is a Ruby gem for Argentine electronic invoicing (facturación electrónica). It interfaces with AFIP's web services to obtain CAE (Código de Autorización Electrónica) for invoices.

## Build & Test Commands

```bash
bundle install          # Install dependencies
rake spec               # Run all RSpec tests (default task)
rake rdoc               # Generate documentation
```

Run a single test file:
```bash
bundle exec rspec spec/bravo/bill_spec.rb
```

## Required Environment

- Ruby 2.7.8 (see `.ruby-version`)
- `CUIT` environment variable must be set for tests
- Valid AFIP X.509 certificate and private key in `spec/fixtures/`

## Architecture

### Core Classes

- **`Bravo`** (`lib/bravo.rb`) - Main module with configuration attributes
- **`Bravo::Bill`** (`lib/bravo/bill.rb`) - Invoice creation and authorization via FECAESolicitar
- **`Bravo::AuthData`** (`lib/bravo/auth_data.rb`) - Fetches TOKEN/SIGN from WSAA
- **`Bravo::Authorizer`** (`lib/bravo/authorizer.rb`) - Credential holder for PKI cert/key paths
- **`Bravo::Reference`** (`lib/bravo/reference.rb`) - Query reference data from AFIP
- **`Bravo::Constants`** (`lib/bravo/constants.rb`) - AFIP codes for bill types, currencies, IVA

### Authentication Flow

1. `AuthData.fetch()` obtains TOKEN and SIGN from WSAA
2. Credentials are cached per calendar day in `/tmp/bravo_DD_MM_YYYY.yml`
3. `Bravo.auth_hash` provides SOAP authentication headers

### SOAP Communication

Uses Savon 0.7.8 for AFIP web services:
- **WSAA (auth)**: `https://wsaahomo.afip.gov.ar/ws/services/LoginCms`
- **WSFE (billing)**: `https://wswhomo.afip.gov.ar/wsfev1/service.asmx?WSDL`

### Core Extensions

Custom methods in `lib/bravo/core_ext/`:
- `Float#round_with_precision` - Exact 2-decimal currency calculations
- `Hash#symbolize_keys`, `Hash#underscore_keys` - XML to Ruby mapping
- `String#underscore` - CamelCase to snake_case conversion

## Key Patterns

- Configuration via module-level `attr_accessor` on `Bravo` module
- Response objects built as dynamic Structs from SOAP response fields
- Hash key transformations for AFIP XML format compatibility
- Custom exception: `Bravo::NullOrInvalidAttribute`
