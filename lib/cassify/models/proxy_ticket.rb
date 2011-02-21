require 'active_record'
require 'active_record/base'

module Cassify
  class ProxyTicket < ServiceTicket
    belongs_to :granted_by_pgt,
      :class_name => 'Cassify::Model::ProxyGrantingTicket',
      :foreign_key => :granted_by_pgt_id
  end
end