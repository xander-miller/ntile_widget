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
  
  events_cooper.add_event(an_event)
  # Route a newly generated event to the appropriate Cooper instances.
  if an_event[:event_type] == "Sign-Up"
    signup_cooper.add_event(an_event)
  elsif an_event[:event_type] == "Sale"
    sales_cooper.add_event(an_event)
    case an_event[:employee]
    when "David U."
      david_sales_cooper.add_event(an_event)
    when "Daniel B."
      daniel_sales_cooper.add_event(an_event)
    when "Serena N."
      serena_sales_cooper.add_event(an_event)
    end
  end


  # Send Updates to be displayed
  send_event('events', events_cooper.update_widget)

  send_event('signup', signup_cooper.update_widget)

  send_event('sales', sales_cooper.update_widget)

  send_event('david', david_sales_cooper.update_widget)

  send_event('daniel', daniel_sales_cooper.update_widget)

  send_event('serena', serena_sales_cooper.update_widget)
end