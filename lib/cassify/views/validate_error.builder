xml.tag!("cas:serviceResponse", 'xmlns:cas' => "http://www.yale.edu/tp/cas") do
  xml.tag!("cas:authenticationFailure", {:code => @validator.error.code}, @validator.error.to_s)
end