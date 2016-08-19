# -*- encoding: utf-8 -*-
module Bravo
  # Authorization class. Handles interactions wiht the WSAA, to provide
  # valid key and signature that will last for a day.
  #
  class Wsaa
    # Main method for authentication and authorization.
    # When successful, produces the yaml file with auth data.
    #
    def self.login(pkey_path, cert_path)
      tra   = build_tra
      cms   = build_cms(tra, pkey_path, cert_path)
      req   = build_request(cms)
      call_wsaa(req)
    end

    def self.login_to_file(filename, pkey_path, cert_path)
      auth = login(pkey_path, cert_path)
      write_yaml(auth, filename)
      auth
    end

    # Builds the xml for the 'Ticket de Requerimiento de Acceso'
    # @return [String] containing the request body
    #
    # rubocop:disable Metrics/MethodLength
    def self.build_tra
      now = (Time.now) - 120
      @from = now.strftime('%FT%T%:z')
      @to   = (now + ((12 * 60 * 60))).strftime('%FT%T%:z')
      @id   = now.strftime('%s')
      tra  = <<-EOF
<?xml version="1.0" encoding="UTF-8"?>
<loginTicketRequest version="1.0">
  <header>
    <uniqueId>#{ @id }</uniqueId>
    <generationTime>#{ @from }</generationTime>
    <expirationTime>#{ @to }</expirationTime>
  </header>
  <service>wsfe</service>
</loginTicketRequest>
EOF
      tra
    end
    # rubocop:enable Metrics/MethodLength
    # Builds the CMS
    # @return [String] cms
    #
    def self.build_cms(tra, pkey_path, cert_path)
      `echo '#{ tra }' |
        #{ Bravo.openssl_bin } cms -sign -in /dev/stdin -signer #{ cert_path } -inkey #{ pkey_path }  \
        -nodetach -outform der |
        #{ Bravo.openssl_bin } base64 -e`
    end

    # Builds the CMS request to log in to the server
    # @return [String] the cms body
    #
    def self.build_request(cms)
      # rubocop:disable Metrics/LineLength
      request = <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns1="http://wsaa.view.sua.dvadac.desein.afip.gov">
  <SOAP-ENV:Body>
    <ns1:loginCms>
      <ns1:in0>
#{ cms }
      </ns1:in0>
    </ns1:loginCms>
  </SOAP-ENV:Body>
</SOAP-ENV:Envelope>
XML
      request
    end
    # rubocop:enable Metrics/LineLength

    # Calls the WSAA with the request built by build_request
    # @return [Array] with the token and signature
    #
    # rubocop:disable Metrics/AbcSize
    def self.call_wsaa(req)
      # XXX: a request made too soon after a successful one throws an error. deal with it
      response = `echo '#{ req }' |
        curl -k -s -H 'Content-Type: application/soap+xml; action=""' -d @- #{ Authorization.wsaa_url }`

      response = CGI.unescapeHTML(response)
      puts response
      # ns1:coe.alreadyAuthenticated grepear esto para evitar errores
      token = response.scan(%r{\<token\>(.+)\<\/token\>}).flatten.first
      sign  = response.scan(%r{\<sign\>(.+)\<\/sign\>}).flatten.first
      created_at = response.scan(%r{\<generationTime\>(.+)\<\/generationTime\>}).flatten.first
      expires_at = response.scan(%r{\<expirationTime\>(.+)\<\/expirationTime\>}).flatten.first

      { token: token, sign: sign, created_at: created_at, expires_at: expires_at }
    end
    # rubocop:enable Metrics/AbcSize

    # Writes the token and signature to a YAML file in the /tmp directory
    #
    def self.write_yaml(credentials, filename)
      File.write(filename, credentials.to_yaml)
    end
  end
end
