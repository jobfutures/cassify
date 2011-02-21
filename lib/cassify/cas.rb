require 'uri'
require 'net/https'

module Cassify
  class Cas
    # Takes an existing ServiceTicket object (presumably pulled from the database)
    # and sends a POST with logout information to the service that the ticket
    # was generated for.
    #
    # This makes possible the "single sign-out" functionality added in CAS 3.1.
    # See http://www.ja-sig.org/wiki/display/CASUM/Single+Sign+Out
    def send_logout_notification_for_service_ticket(st)
      uri = URI.parse(st.service)
      http = Net::HTTP.new(uri.host, uri.port)
      #http.use_ssl = true if uri.scheme = 'https'

      time = Time.now
      rand = Cassify::Utils.random_string

      path = uri.path
      path = '/' if path.empty?

      req = Net::HTTP::Post.new(path)
      req.set_form_data(
        'logoutRequest' => %{<samlp:LogoutRequest ID="#{rand}" Version="2.0" IssueInstant="#{time.rfc2822}">
  <saml:NameID></saml:NameID>
  <samlp:SessionIndex>#{st.ticket}</samlp:SessionIndex>
  </samlp:LogoutRequest>}
      )

      begin
        http.start do |conn|
          response = conn.request(req)

          if response.kind_of? Net::HTTPSuccess
            $LOG.info "Logout notification successfully posted to #{st.service.inspect}."
            return true
          else
            $LOG.error "Service #{st.service.inspect} responed to logout notification with code '#{response.code}'!"
            return false
          end
        end
      rescue Exception => e
        $LOG.error "Failed to send logout notification to service #{st.service.inspect} due to #{e}"
        return false
      end
    end
  end
end
