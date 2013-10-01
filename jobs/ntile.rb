#Required to generate fake data.
require 'faker'
require 'active_support/all'

#Required to run in production
require 'time'



#Generate Dummy Data
def fake_it duration = 128
  sales_staff = ["David U.","Daniel B.","Serena N."]
  6.times do
    sales_staff << "#{Faker::Name.first_name} #{Faker::Name.last_name.first}."
  end
  support_staff = ["David U.","Daniel B.","Serena N."]
  2.times do
    support_staff << "#{Faker::Name.first_name} #{Faker::Name.last_name.first}."
  end
  fake_data = []
  for each_day in 0..duration
    # Sign Ups
    rand(5..17).times do
      fake_data << { 
        timestamp: (Date.today - each_day).to_time + rand(1.day), 
        event_type: "Sign-Up"
      }
    end
    # Sales
    rand(64).times do
      fake_data << { 
        timestamp: (Date.today - each_day).to_time + rand(1.day), 
        event_type: "Sale", 
        employee: sales_staff[rand(sales_staff.length)], 
        sale_amount: rand(10...1500)
      }
    end
    # Support Ticket Closed
    rand(20..56).times do
      fake_data << { 
        timestamp: (Date.today - each_day).to_time + rand(1.day), 
        event_type: "Support", 
        employee: support_staff[rand(support_staff.length)] 
      }
    end
  end
  fake_data
end

def fake_event #Generate a single fake event.
  an_event = {}
  sales_staff = ["David U.","Daniel B.","Serena N."]
  support_staff = ["David U.","Daniel B.","Serena N."]
  type = rand(1..6)
  type = 2 if type > 3
  case type
  when 1
    an_event = {
      timestamp: Time.now,
      event_type: "Sign-Up"
    }
  when 2
    an_event = {
      timestamp: Time.now,
      event_type: "Sale", 
      employee: sales_staff[rand(sales_staff.length)], 
      sale_amount: rand(10...3000)
    }
  when 3
    an_event = {
      timestamp: Time.now,
      event_type: "Support", 
      employee: support_staff[rand(support_staff.length)] 
    }
  end
  an_event
end

class Cooper # Maker of Barrels and Buckets and in this case sorter of buckets too.
  attr_reader :current_rank, :current_value

  @@coopers = []

  def initialize(data_set, opt_params = {})
    params = {ntile: 5, timestamp_label: :timestamp, bucket_shape: '%b%d%y', sum_label: nil}.merge!(opt_params)
    @data_set = data_set
    @ntile = params[:ntile]
    @timestamp_label = params[:timestamp_label]
    @sum_label = params[:sum_label]
    @bucket_shape = params[:bucket_shape]
    @buckets = {}
    coop
    @tally = []
    tally_buckets
    @current_rank = calc_current_rank
    @current_value = calc_current_value
    @current_bucket_label = Time.now.strftime(@bucket_shape).to_sym
    @@coopers << self
  end

  def update_current(event)
    @buckets[:current] << event
    tally_buckets
  end

  def coop
    @data_set.each do |item|
      bucket_label = item[@timestamp_label].strftime(@bucket_shape).to_sym
      @buckets.key?(bucket_label) ? @buckets[bucket_label] << item : @buckets[bucket_label] = [item]      
    end
    if @buckets[@current_bucket_label]
      @buckets[:current] = @buckets.delete(@current_bucket_label.to_sym)
    else
      @buckets[:current] = []      
    end
    @buckets  
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
    @tally.each {|tuple| rank = tuple[2] if tuple[0] == :current}
    @current_rank = rank
    rank
  end

  def calc_current_value
    value = 0
    @tally.each do |tuple| 
      if tuple[0] == :current
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
    rank_up
  end

  def next_text
    return_str = ""
    if @tally[-1][0] == :current
      return_str = "Best Ever! "
    elsif @tally[-1][2] == @current_rank
      return_str = "Beat the Record "
    else
      return_str = "Next Rank at "
    end
    return_str
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
    mode
  end

  def rank_suffix
    Cooper.calc_rank_suffix(calc_current_rank)
  end

  def current_bucket_current?
    return_value = false
    test_label = Time.now.strftime(@bucket_shape).to_sym
    return_value = true if @current_bucket_label == test_label
    return_value
  end

  private

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

#Generate and then separate out data sets needed for each widget instance.
fake_data = fake_it

signup_data = [].replace(fake_data)
signup_data.keep_if {|item| item[:event_type] == "Sign-Up"}

sales_data = [].replace(fake_data)
sales_data.keep_if {|event| event[:event_type] == "Sale"}
puts sales_data

david_sales_data = [].replace(sales_data)
david_sales_data.keep_if {|event| event[:employee] == "David U."}

serena_sales_data = [].replace(sales_data)
serena_sales_data.keep_if {|event| event[:employee] == "Serena N."}

daniel_sales_data = [].replace(sales_data)
daniel_sales_data.keep_if {|event| event[:employee] == "Daniel B."}

# Generate separate widgets.
events_cooper = Cooper.new(fake_data, {ntile: 100})
signup_cooper = Cooper.new(signup_data)
sales_cooper = Cooper.new(sales_data, {ntile: 100, sum_label: :sale_amount})
david_sales_cooper = Cooper.new(david_sales_data, {ntile: 100, sum_label: :sale_amount})
serena_sales_cooper = Cooper.new(serena_sales_data, {ntile: 100, sum_label: :sale_amount})
daniel_sales_cooper = Cooper.new(daniel_sales_data, {ntile: 100, sum_label: :sale_amount})

# :first_in sets how long it takes before the job is first run. In this case, it is run immediately
SCHEDULER.every '3s', :first_in => 0 do |job|
  an_event = fake_event
  
  events_cooper.update_current(an_event)
  # Route a newly generated event to the appropriate Cooper instances.
  if an_event[:event_type] == "Sign-Up"
    signup_cooper.update_current(an_event)
  elsif an_event[:event_type] == "Sale"
    sales_cooper.update_current(an_event)
    case an_event[:employee]
    when "David U."
      david_sales_cooper.update_current(an_event)
    when "Daniel B."
      daniel_sales_cooper.update_current(an_event)
    when "Serena N."
      serena_sales_cooper.update_current(an_event)
    end
  end

  # Checks to see if dashboard has run into a new bucket period and then rebuilds buckets if it has.
  events_cooper = Cooper.new(fake_data, {ntile: 100}) unless events_cooper.current_bucket_current?
  signup_cooper = Cooper.new(signup_data) unless signup_cooper.current_bucket_current?
  sales_cooper = Cooper.new(sales_data, {ntile: 100, sum_label: :sale_amount}) unless sales_cooper.current_bucket_current?
  david_sales_cooper = Cooper.new(david_sales_data, {ntile: 100, sum_label: :sale_amount}) unless david_sales_cooper.current_bucket_current?
  serena_sales_cooper = Cooper.new(serena_sales_data, {ntile: 100, sum_label: :sale_amount}) unless serena_sales_cooper.current_bucket_current?
  daniel_sales_cooper = Cooper.new(daniel_sales_data, {ntile: 100, sum_label: :sale_amount}) unless daniel_sales_cooper.current_bucket_current?



  # Send Updates to be displayed
  send_event('events', { value: events_cooper.calc_current_value, 
    rank: events_cooper.calc_current_rank,
    suffix: events_cooper.rank_suffix,
    mode: events_cooper.ntile_mode,
    next_text: events_cooper.next_text,
    next_rank_value: events_cooper.next_rank_value })

  send_event('signup', { value: signup_cooper.calc_current_value, 
    rank: signup_cooper.calc_current_rank,
    suffix: signup_cooper.rank_suffix,
    mode: signup_cooper.ntile_mode,
    next_text: signup_cooper.next_text,
    next_rank_value: signup_cooper.next_rank_value })

  send_event('sales', { value: sales_cooper.calc_current_value, 
    rank: sales_cooper.calc_current_rank,
    suffix: sales_cooper.rank_suffix,
    mode: sales_cooper.ntile_mode,
    next_text: sales_cooper.next_text,
    next_rank_value: sales_cooper.next_rank_value })

  send_event('david', { value: david_sales_cooper.calc_current_value, 
    rank: david_sales_cooper.calc_current_rank,
    suffix: david_sales_cooper.rank_suffix,
    mode: david_sales_cooper.ntile_mode,
    next_text: david_sales_cooper.next_text,
    next_rank_value: david_sales_cooper.next_rank_value })

  send_event('daniel', { value: daniel_sales_cooper.calc_current_value, 
    rank: daniel_sales_cooper.calc_current_rank,
    suffix: daniel_sales_cooper.rank_suffix,
    mode: daniel_sales_cooper.ntile_mode,
    next_text: daniel_sales_cooper.next_text,
    next_rank_value: daniel_sales_cooper.next_rank_value })

  send_event('serena', { value: serena_sales_cooper.calc_current_value, 
    rank: serena_sales_cooper.calc_current_rank,
    suffix: serena_sales_cooper.rank_suffix,
    mode: serena_sales_cooper.ntile_mode,
    next_text: serena_sales_cooper.next_text,
    next_rank_value: serena_sales_cooper.next_rank_value })
end