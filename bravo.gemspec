require_relative "lib/bravo/version"

Gem::Specification.new do |s|
  s.name = "bravo"
  s.version = Bravo::VERSION
  s.authors = ["Leandro Marcucci"]
  s.email = ["leanucci@gmail.com"]

  s.summary = "AFIP electronic invoicing adapter"
  s.description = "Ruby adapter for AFIP's WSFE (Web Service de Facturación Electrónica)"
  s.homepage = "https://github.com/leanucci/bravo"
  s.license = "MIT"

  s.required_ruby_version = ">= 2.7.0"

  s.files = Dir.glob("{lib}/**/*") + %w[LICENSE.txt README.md CHANGELOG VERSION]
  s.require_paths = ["lib"]

  s.add_dependency "savon", "~> 2.0"
  s.add_dependency "wsaa-ruby", "~> 0.2"

  s.add_development_dependency "rspec", "~> 3.0"
  s.add_development_dependency "vcr", "~> 6.0"
  s.add_development_dependency "webmock", "~> 3.0"
end
