xml.tag!("cas:serviceResponse", 'xmlns:cas' => "http://www.yale.edu/tp/cas") do
  xml.tag!("cas:authenticationSuccess") do
    xml.tag!("cas:user", @validator.username.to_s)
    @validator.extra_attributes.each do |key, value|
      xml.tag!(key) do
        Cassify::Utils.serialize_extra_attribute(xml, value)
      end
    end
    if @validator.pgtiou
      xml.tag!("cas:proxyGrantingTicket", @validator.pgtiou.to_s)
    end
    if @validator.proxies && !@validator.proxies.empty?
      xml.tag!("cas:proxies") do
        @validator.proxies.each do |proxy_url|
          xml.tag!("cas:proxy", proxy_url.to_s)
        end
      end
    end
  end
end