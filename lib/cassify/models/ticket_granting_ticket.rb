require 'active_record'
require 'active_record/base'

module Cassify
  class TicketGrantingTicket < Ticket
    set_table_name 'casserver_tgt'

    serialize :extra_attributes

    has_many :granted_service_tickets,
      :class_name => 'Cassify::Model::ServiceTicket',
      :foreign_key => :granted_by_tgt_id
  end
end