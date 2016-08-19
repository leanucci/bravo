module Bravo
  Credentials = Struct.new(:authorizations) do
    def find(cuit)
      authorizations.find { |authorization| authorization.cuit == cuit }
    end

    def store(new_auth)
      authorizations.reject! { |authorization| authorization.cuit == new_auth.cuit }
      authorizations << new_auth
    end
  end

  class Authorization
    attr_accessor :cuit, :pkey_path, :cert_path, :token, :sign, :created_at, :expires_at

    def initialize(cuit, pkey, cert)
      @cuit = cuit
      @pkey_path = validate_path(pkey)
      @cert_path = validate_path(cert)
    end

    # Returns the WSFE url for the specified environment
    # @return [String]
    #
    def self.wsfe_url
      raise 'environment not set' unless Bravo.environment
      Bravo::URLS[Bravo.environment][:wsfe]
    end

    # Returns the WSAA url for the specified environment
    # @return [String]
    #
    def self.wsaa_url
      raise 'environment not set' unless Bravo.environment
      Bravo::URLS[Bravo.environment][:wsaa]
    end

    def self.build(cuit, pkey_path, cert_path)
      authorization = new(cuit, pkey_path, cert_path)
      credentials.store(authorization)
      authorization
    end

    def self.credentials
      @credentials ||= Credentials.new([])
    end

    def self.for(cuit)
      credentials_for_cuit = credentials.find(cuit)
      raise ::Bravo::MissingCredentials.new, "missing credentials for #{ cuit }" unless credentials_for_cuit
      credentials_for_cuit
    end

    def self.create(cuit:, pkey_path:, cert_path:)
      authorization = build(cuit, pkey_path, cert_path)
      authorization.authorize!
    end

    def authorized?
      !token.nil? && !sign.nil? && !expires_at.nil? && (expires_at > Time.new)
    end

    def auth_hash
      authorize! unless self.authorized?
      { 'Cuit' => cuit, 'Sign' => sign, 'Token' => token }
    end

    def authorize!
      authorization_data = Wsaa.login(pkey_path, cert_path)

      self.token = authorization_data[:token]
      self.sign  = authorization_data[:sign]
      self.expires_at = Time.parse(authorization_data[:expires_at])
      self.created_at = Time.parse(authorization_data[:created_at])

      self
    end

    private

    def validate_path(path)
      raise(ArgumentError.new, "#{ path } does not exist") unless File.exist? path
      path
    end
  end
end
