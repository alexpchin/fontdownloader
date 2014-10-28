class FontEmailer
  
  def send(email)
    
    m = Mandrill::API.new
    message = {  
     :subject=> "Hello from the Mandrill API",  
     :from_name=> "Font Downloader",  
     :text=>"Your downloaded fonts from Font Downloader.",  
     :to=>[  
       {  
         :email=> "#{email}",  ## this uses the email argument passed into this method
         :name=> "Font Ninja"  
       }  
     ],  
     :html=>"<h1>Hi <strong>message</strong>, how are you?</h1>",  
     :from_email=>"no-reply@fontdownloader.com"  
    }  
    sending = m.messages.send message  
    puts sending
    
  end

end