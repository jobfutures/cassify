require 'active_record'
require 'active_record/base'

module Cassify
  class ServiceTicket < Ticket
    set_table_name 'casserver_st'
    include Consumable

    belongs_to :granted_by_tgt,
      :class_name => 'Cassify::Model::TicketGrantingTicket',
      :foreign_key => :granted_by_tgt_id
    has_one :proxy_granting_ticket,
      :foreign_key => :created_by_st_id

    def matches_service?(service)
      Cassify::CAS.clean_service_url(self.service) ==
        Cassify::CAS.clean_service_url(service)
    end
  end
end