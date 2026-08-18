module Bravo
  ##
  # Fetches authentication credentials from AFIP's WSAA service.
  #
  # Uses the wsaa-ruby gem to obtain TOKEN and SIGN credentials.
  # Credentials are cached by the gem until expiration.
  class AuthData

    class << self
      ##
      # Fetches authentication credentials and sets TOKEN/SIGN constants.
      #
      # @raise [Wsaa::ConfigurationError] If pkey or cert configuration is invalid.
      # @raise [Wsaa::AuthenticationError] If authentication fails.
      def fetch
        environment = Bravo.auth_url.include?("homo") ? :testing : :production

        Wsaa.configure do |config|
          config.pkey = Bravo.pkey
          config.cert = Bravo.cert
          config.service = "wsfe"
          config.environment = environment
        end

        credentials = Wsaa.authenticate

        Bravo.const_set(:TOKEN, credentials.token) unless Bravo.const_defined?(:TOKEN)
        Bravo.const_set(:SIGN, credentials.sign) unless Bravo.const_defined?(:SIGN)
      end
    end
  end
end
