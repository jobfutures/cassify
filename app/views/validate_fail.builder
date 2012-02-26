xml.tag!("cas:serviceResponse", 'xmlns:cas' => "http://www.yale.edu/tp/cas") do
  xml.tag!("cas:authenticationFailure", {:code => error.code}, error.to_s)
end