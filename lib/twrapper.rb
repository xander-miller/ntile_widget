class Twrapper #Wraps Twitter Job functions to make creation of multiple Ntile widgets DRY
  attr_reader :cooper, :name

  def initialize search_term, name, opt_params = {}
    params = {search_params: {}, bucket_shape: '%b%y%d%H'}.merge!(opt_params)
    @search_term = search_term
    @name = name
    @bucket_shape = params[:bucket_shape]
    initial_twitter_data
  end

  def initial_twitter_data
    tweets = Twitter.search("#{@search_term}", count: 100).results
    if tweets.last
      (1..10).each do
        more_tweets = Twitter.search("#{@search_term}", count: 100, max_id: tweets.last.id).results
        if more_tweets
          tweets << more_tweets 
          tweets.flatten!
        else
          break
        end
      end
    end

    twaps = tweets.map do |tweet|
      { id: tweet.id, timestamp: tweet.created_at }
    end

    twaps.sort! {|x,y| x[:id] <=> y[:id] }
    @last_twap = twaps.last
    @cooper = Cooper.new(twaps, bucket_shape: @bucket_shape, ntile: 100)
  end

  def update_cooper
    new_tweets = Twitter.search("#{@search_term}", since_id: @last_twap[:id], count: 100).results
    new_twaps = new_tweets.map do |tweet|
      { id: tweet.id, timestamp: tweet.created_at }
    end
    new_twaps.each do |twap| 
      @cooper.add_event(twap)
    end
    @last_twap = new_twaps.first unless new_twaps.empty? 
    new_twaps = []
  end


  private
  


end