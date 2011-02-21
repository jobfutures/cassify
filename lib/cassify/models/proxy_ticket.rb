require 'active_record'
require 'active_record/base'

module Cassify
  class ProxyTicket < ServiceTicket
    belongs_to :granted_by_pgt,
      :class_name => 'Cassify::Model::ProxyGrantingTicket',
      :foreign_key => :granted_by_pgt_id

    def self.generate!(target_service, host_name, proxy_granting_ticket)
      proxy_ticket = ProxyTicket.new(
        :ticket             => "PT-" + Cassify::Utils.random_string,
        :service            => target_service,
        :username           => proxy_granting_ticket.service_ticket.username,
        :granted_by_pgt_id  => proxy_granting_ticket.id,
        :granted_by_tgt_id  => proxy_granting_ticket.service_ticket.granted_by_tgt.id,
        :client_hostname    => host_name
      )
      proxy_ticket.save!

      ProxyTicket.logger.debug("Generated proxy ticket '#{proxy_ticket.ticket}' for target service '#{proxy_ticket.service}'" +
        " for user '#{proxy_ticket.username}' at '#{proxy_ticket.client_hostname}' using proxy-granting" +
        " ticket '#{pgt.ticket}'")
      proxy_ticket
    end
  end
end