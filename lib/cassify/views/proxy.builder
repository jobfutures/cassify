if @validator.success
  xml.tag!("cas:serviceResponse", 'xmlns:cas' => "http://www.yale.edu/tp/cas") do
    xml.tag!("cas:proxySuccess") do
      xml.tag!("cas:proxyTicket", @validator.proxy_ticket.to_s)
    end
  end
else
  xml.tag!("cas:serviceResponse", 'xmlns:cas' => "http://www.yale.edu/tp/cas") do
    xml.tag!("cas:proxyFailure", {:code => @validator.error.code}, @validator.error.to_s)
  end
end
