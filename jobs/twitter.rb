require 'twitter'
require 'time'


#### Get your twitter keys & secrets:
#### https://dev.twitter.com/docs/auth/tokens-devtwittercom
Twitter.configure do |config|
  config.consumer_key = ENV['YOUR_CONSUMER_KEY']
  config.consumer_secret = ENV['YOUR_CONSUMER_SECRET']
  config.oauth_token = ENV['YOUR_OAUTH_TOKEN']
  config.oauth_token_secret = ENV['YOUR_OAUTH_SECRET']
end

twrappers = []

twrappers << Twrapper.new('#owl','owl')
twrappers << Twrapper.new('#unicorn','unicorn')

twrappers << Twrapper.new('shopify','shopify', bucket_shape: '%b%y%d')
twrappers << Twrapper.new('#AskJPM','askJPM', bucket_shape: '%b%y%d')
twrappers << Twrapper.new('to:justinbieber marry me','justin', bucket_shape: '%b%y%d')
twrappers << Twrapper.new('to:dhh','dhh', bucket_shape: '%b%y%d')

SCHEDULER.every '1m', :first_in => 0 do |job|
  twrappers.each {|twrapper| twrapper.update_cooper}

  twrappers.each {|twrapper| send_event(twrapper::name, twrapper::cooper.update_widget) }
end