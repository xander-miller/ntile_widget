class Cooper # Maker of Barrels and Buckets and in this case sorter of buckets too.
  attr_reader :current_rank, :current_value

  @@coopers = []

  def initialize(data_set, opt_params = {})
    params = {ntile: 5, timestamp_label: :timestamp, bucket_shape: '%b%d%y', sum_label: nil}.merge!(opt_params)
    data_set ? @data_set = data_set : @data_set = []
    @ntile = params[:ntile]
    @timestamp_label = params[:timestamp_label]
    @sum_label = params[:sum_label]
    @bucket_shape = params[:bucket_shape] 
    coop
    tally_buckets
    @current_rank = calc_current_rank
    @current_value = calc_current_value
    current
    @@coopers << self
  end

  def add_event(event)
    @buckets[current] << event
    tally_buckets
  end

  def coop
    @buckets = {current => []}
    @data_set.each do |item|
      label = bucket_label(item[@timestamp_label])     
      @buckets.key?(label) ? @buckets[label] << item : @buckets[label] = [item]      
    end
    @buckets  
  end

  def update_widget
    { 
      value: calc_current_value, 
      rank: calc_current_rank,
      suffix: rank_suffix,
      mode: ntile_mode,
      next_text: next_text,
      next_rank_value: next_rank_value 
    }
  end


  def tally_buckets()
    @tally = []
    @buckets.each do |key,bucket| 
      if @sum_label
        bucket_sum = 0
        bucket.each {|event| bucket_sum += event[@sum_label]}
        @tally << [key,bucket_sum]
      else
        @tally << [key,bucket.count]
      end
    end
    @tally.sort! {|a,b| a[1] <=> b[1]}
    @tally.each_index do |index|
      @tally[index] = [@tally[index],(index.to_f/(@tally.length.to_f/@ntile)).to_i + 1].flatten!
    end
  end

  def calc_current_rank
    rank = 0
    @tally.each {|tuple| rank = tuple[2] if tuple[0] == current}
    @current_rank = rank
    rank
  end

  def calc_current_value
    value = 0
    @tally.each do |tuple| 
      if tuple[0] == current
        value = tuple[1]
      end
    end
    @current_value = value
    value
  end

  def next_rank_value
    rank_up = 0
    calc_current_rank
    @tally.each do |tuple|
      rank_up = tuple[1] + 1 if (rank_up == 0) and (@current_rank < tuple[2])
    end
    rank_up = @current_value if rank_up == 0
  end

  def next_text
    return_str = ""
    if @tally[-1][0] == @current_label
      return_str = "Best Ever! "
    elsif @tally[-1][2] == @current_rank
      return_str = "Beat the Record "
    else
      return_str = "Next Rank at "
    end
  end

  def ntile_mode
    mode = ""
    if @ntile == 5
      mode = "Qunitile"
    elsif @ntile == 4
      mode = "Quartile"
    elsif @ntile == 100
      mode = "Percentile"
    end
  end

  def rank_suffix
    Cooper.calc_rank_suffix(calc_current_rank)
  end


  def current
    @current_label = Time.now.strftime(@bucket_shape).to_sym
  end

  private

  def bucket_label(timestamp)
    timestamp.strftime(@bucket_shape).to_sym
  end

  def self.calc_rank_suffix(rank)
    suffix = ""
    if (rank.to_s[-1] == "1") and (rank != 12)
      suffix = "st" 
    elsif (rank.to_s[-1] == "2") and (rank != 12)
      suffix = "nd" 
    elsif (rank.to_s[-1] == "3") and (rank != 13)
      suffix = "rd"
    else
      suffix = "th"
    end
    suffix
  end
end