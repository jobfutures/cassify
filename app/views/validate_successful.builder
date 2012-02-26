xml.tag!("cas:serviceResponse", 'xmlns:cas' => "http://www.yale.edu/tp/cas") do
  xml.tag!("cas:authenticationSuccess") do
    xml.tag!("cas:user", service_ticket.username.to_s)
    service_ticket.granted_by_tgt.extra_attributes || {}.each do |key, value|
      xml.tag!(key) do
        Cassify::Utils.serialize_extra_attribute(xml, value)
      end
    end
  end
end