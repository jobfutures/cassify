require 'active_record'
require 'active_record/base'

module Cassify
  class ProxyGrantingTicket < Ticket
    set_table_name 'casserver_pgt'
    belongs_to :service_ticket
    has_many :granted_proxy_tickets,
      :class_name => 'Cassify::Model::ProxyTicket',
      :foreign_key => :granted_by_pgt_id
  end
end