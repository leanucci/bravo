# encoding: utf-8
require 'bundler/setup'
require 'bravo/version'
require 'bravo/constants'
require 'savon'
require 'bravo/core_ext/hash'
require 'bravo/core_ext/string'

module Bravo
  # Exception Class for missing or invalid attributes
  #
  class NullOrInvalidAttribute < StandardError; end
  # Exception Class for missing or invalid certifficate
  #
  class MissingCertificate < StandardError; end

  class MissingCredentials < StandardError; end
  # This class handles the logging options
  #
  class Logger
    # @param opts [Hash] receives a hash with keys `log`, `pretty_xml` (both
    # boolean) or the desired log level as `level`
    attr_accessor :log, :pretty_xml, :level

    def initialize(opts = {})
      self.log = opts.fetch(:log, false)
      self.pretty_xml = opts.fetch(:pretty_xml, log)
      self.level = opts.fetch(:level, :debug)
    end

    # @return [Hash] returns a hash with the proper logging optios for Savon.
    def logger_options
      { log: log, pretty_print_xml: pretty_xml, log_level: level }
    end
  end

  autoload :Authorizer,     'bravo/authorizer'
  autoload :Bill,           'bravo/bill'
  autoload :Constants,      'bravo/constants'
  autoload :Authorization,  'bravo/authorization'
  autoload :Wsaa,           'bravo/wsaa'
  autoload :Reference,      'bravo/reference'
  autoload :Request,        'bravo/request'

  extend self

  attr_accessor :sale_point, :default_documento, :default_concepto, :default_moneda,
    :own_iva_cond, :openssl_bin

  attr_reader :environment

  # Used to set the environment. Validates the value with the existing environments
  #
  def self.environment=(env)
    env = env.to_sym
    if Bravo::URLS.keys.include?(env)
      @environment = env
    else
      raise "invalid environment: #{ env }. Choose one from [#{ Bravo::URLS.keys.join(', ') }]"
    end
  end

  # Receiver of the logging configuration options.
  # @param opts [Hash] pass a hash with `log`, `pretty_xml` and `level` keys to set
  # them.
  def self.logger=(opts)
    @logger = Logger.new(opts)
  end

  # Sets the logger options to the default values or returns the previously set
  # logger options
  # @return [Logger]
  def self.logger
    @logger ||= Logger.new
  end

  # Returs the formatted logger options to be used by Savon.
  def self.logger_options
    logger.logger_options
  end

  def self.own_iva_cond=(iva_cond_symbol)
    if Bravo::BILL_TYPE.key?(iva_cond_symbol)
      @own_iva_cond = iva_cond_symbol
    else
      raise(NullOrInvalidAttribute.new, "El valor de  own_iva_cond: (#{ iva_cond_symbol }) es inválido.")
    end
  end
end
