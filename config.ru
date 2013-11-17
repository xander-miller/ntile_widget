require 'dashing'

configure do
 
  set :testy, 'Hello World!'
  set :consumer_key, 'y0I4nwvh7X1rRZ022Krg'
  set :consumer_secret, 'ubnExKTcpiVKumSVB8b14nxdiNGJafbMzXhud3MDk'
  set :oauth_token, '71638693-suGjpFRV2Eha6eS3k4I5hYiYtDNkeRYDIJ0mW97mE'
  set :oauth_token_secret, 'ElTjGAHGFavgRDSCrYTR2hLM2NxqfLo9oqEZtU8om6NgQ'

  helpers do
    def protected!
     # Put any authentication code you want in here.
     # This method is run before accessing any resource.
      
    end
  end
end

map Sinatra::Application.assets_prefix do
  run Sinatra::Application.sprockets
end

run Sinatra::Application