module Cassify
  module Models
    class Ticket < ActiveRecord::Base
      def to_s
        ticket
      end
      
      def self.cleanup
        puts Time.now - Cassify::Settings.max_lifetime
        Cassify::CasLog.info "Destroying #{self.expired.count} expired #{self.name.demodulize}"
        delete_all ["created_on < ?", expiry_bound]
      end
      
      def consume!
        self.update_attribute(:consumed, Time.now)
      end

      def expired?
        self.created_on < Time.at(Time.now.to_i - ::Cassify::Settings.maximum_unused_login_ticket_lifetime)
      end
      
      def self.expiry_bound
        Time.at(Time.now.to_i - ::Cassify::Settings.max_lifetime.to_i)
      end

      def self.expired
        where("created_on < ?", expiry_bound)
      end
    end
  end
end
