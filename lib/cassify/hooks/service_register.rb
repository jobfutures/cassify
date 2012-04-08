module Cassify
  class ServiceRegister
    def register_service(user, service_path)
      ticket_granting_ticket  = generate_ticket_granting_ticket(user, service_path)
      service_ticket          = generate_service_ticket(service_path, ticket_granting_ticket)      
    end

    def generate_service_ticket(service_path, ticket_granting_ticket)
      ticket = Cassify::ServiceTicket.create!(
        :service            => service_path,
        :username           => ticket_granting_ticket.username,
        :granted_by_tgt     => ticket_granting_ticket,
        :client_hostname    => service_path
      )
    end

    def generate_ticket_granting_ticket(user, service_url)
      ticket_granting_ticket = Cassify::TicketGrantingTicket.generate!(user.id, service_url)
    end
  end
end

Warden::Manager.after_set_user do |user, auth, opts|
  debugger
  if service_path   = auth.raw_session["#{opts[:scope]}_return_to"] && auth.cookies['tgt'].nil?
    service_ticket  = Cassify::ServiceRegister.new.register_service(user, service_path)
    auth.cookies.permanent['tgt'] = {
      :value   => service_ticket.granted_by_tgt.to_s,
      :expires => 1.day.from_now
    }
  end
end

Warden::Manager.before_logout do |user,auth,opts|
  auth.cookies.delete('tgt')
end

