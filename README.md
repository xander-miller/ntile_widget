#Ntile Widget#
A [Dashing widget](https://github.com/Shopify/dashing) that shows numbers in statistical context. This widget is also available in a [GitHub Gist](https://gist.github.com/PareidoliaX/6757706) for easy installation using the Dashing command line.

![Demo Dashboard Screenshot](http://i.imgur.com/Dd0dCjI.png)

##Description##
A Dashing widget (and an associated job) that will take any set of timestamped data, divid that data by day (or any other unit of time) and compare those units of time, and displays the current day in statistical context of previous days. It currently has three modes of operation [Quartile](http://en.wikipedia.org/wiki/Quartile), [Quintile](http://en.wiktionary.org/wiki/quintile) and [Percentile](http://en.wiktionary.org/wiki/percentile) (hench 'N'tile). The code is designed to take in a variety of data sources. Examples include:
+ Display number of new users your app has attracted this week compared to previous weeks.
+ Display how many customer service tickets have been closed by an individual employee today in the context of their daily performance.
+ Display the performance of a sales team by amount sold this month in the context of previous month's performance. 

##Dependencies##
The job uses the 'Faker' gem and 'Active Support' gem to generate example data. These gems would not be necessary in deployment. Nonetheless if you want to run the example data add the folowing lines to your gem file.
```
gem 'faker'
gem 'activesupport'
```

##Installation##

###Gist Installation###
On the command line:
```
dashing install 6757706
```
Done.

**Note:** If you want the widget to work as in the example you'll still need to install the example dashboard and add the example data gem dependencies to your gemfile.

###Manual Installation###
Alternatively, if you prefer not to use Dashing Gist Installation, on the command line, use the Dashing generate command to make an ntile job and ntile widget:
```
dashing g widget Ntile
dashing g job Ntile
```
Then replace the following files with the ones provided in this gist:
1. Replace `ntile.rb` in the `/jobs/` directory.
2. Replace `ntile.coffee`, `ntile.scss` and `ntile.html` in the `/widget/ntile/` directory. 

###Install Example Dashboard###
To install an example dashboard identical to the one, in the screen shot. Use the Dashing generate command to create an exsales Dashboard:
```
dashing g dashboard Exsales
```
Then replace the generated dashboard file with the one provided in this gist:
1. Replace `exsales.erb` in the `/dashboards/` directory. 

##Usage##
The job that parses the data for display is implement as an Object Class called Cooper (An antiquated trade that made buckets, the object arranges data into buckets... Hey, I think it's clever). To create a Cooper instance based on your data arranged in an array with a hash representing each tuple or event. The keys for each event hash must be symbols, and the timestamp must be a Ruby Time instance. Here is a sample of appropriate data:
```ruby
[{:timestamp=>2013-08-01 09:32:13 -0400, :event_type=>"Sale", :employee=>"Daniel B.", :sale_amount=>1172},
{:timestamp=>2013-08-01 19:37:53 -0400, :event_type=>"Sale", :employee=>"Ariane C.", :sale_amount=>271},
{:timestamp=>2013-08-01 19:48:31 -0400, :event_type=>"Sale", :employee=>"David U.", :sale_amount=>107},
{:timestamp=>2013-08-01 06:02:12 -0400, :event_type=>"Sale", :employee=>"Verner D.", :sale_amount=>1494},
{:timestamp=>2013-08-01 11:42:22 -0400, :event_type=>"Sale", :employee=>"Emilie H.", :sale_amount=>233},
{:timestamp=>2013-08-01 02:06:19 -0400, :event_type=>"Sale", :employee=>"David U.", :sale_amount=>1316},
{:timestamp=>2013-08-01 03:46:49 -0400, :event_type=>"Sale", :employee=>"Verner D.", :sale_amount=>1256},
{:timestamp=>2013-08-01 06:43:34 -0400, :event_type=>"Sale", :employee=>"Serena N.", :sale_amount=>558},
{:timestamp=>2013-08-01 10:36:14 -0400, :event_type=>"Sale", :employee=>"Ariane C.", :sale_amount=>1322},
{:timestamp=>2013-08-01 21:25:51 -0400, :event_type=>"Sale", :employee=>"Brandy M.", :sale_amount=>72},
{:timestamp=>2013-08-01 06:01:37 -0400, :event_type=>"Sale", :employee=>"Aiden J.", :sale_amount=>475},
{:timestamp=>2013-08-01 21:18:28 -0400, :event_type=>"Sale", :employee=>"Daniel B.", :sale_amount=>38},
{:timestamp=>2013-08-01 07:09:59 -0400, :event_type=>"Sale", :employee=>"Daniel B.", :sale_amount=>1156},
{:timestamp=>2013-08-01 08:14:10 -0400, :event_type=>"Sale", :employee=>"Daniel B.", :sale_amount=>223},
{:timestamp=>2013-08-01 22:52:59 -0400, :event_type=>"Sale", :employee=>"Verner D.", :sale_amount=>1201},
{:timestamp=>2013-08-01 10:33:43 -0400, :event_type=>"Sale", :employee=>"Ariane C.", :sale_amount=>521},
{:timestamp=>2013-08-01 12:38:22 -0400, :event_type=>"Sale", :employee=>"Daniel B.", :sale_amount=>1103},
{:timestamp=>2013-08-01 13:34:24 -0400, :event_type=>"Sale", :employee=>"Emilie H.", :sale_amount=>576},
{:timestamp=>2013-08-01 10:08:12 -0400, :event_type=>"Sale", :employee=>"Emilie H.", :sale_amount=>796},
{:timestamp=>2013-08-01 08:24:24 -0400, :event_type=>"Sale", :employee=>"Verner D.", :sale_amount=>1135},
{:timestamp=>2013-08-01 15:13:23 -0400, :event_type=>"Sale", :employee=>"Aiden J.", :sale_amount=>1348},
{:timestamp=>2013-08-01 01:05:56 -0400, :event_type=>"Sale", :employee=>"Ariane C.", :sale_amount=>573},
{:timestamp=>2013-08-01 05:37:17 -0400, :event_type=>"Sale", :employee=>"Ariane C.", :sale_amount=>217},
{:timestamp=>2013-08-01 07:49:41 -0400, :event_type=>"Sale", :employee=>"David U.", :sale_amount=>508},
{:timestamp=>2013-08-01 02:32:02 -0400, :event_type=>"Sale", :employee=>"Daniel B.", :sale_amount=>692},
{:timestamp=>2013-08-01 06:22:43 -0400, :event_type=>"Sale", :employee=>"Verner D.", :sale_amount=>548},]
```
Once your data is formated the next critical step is creating an instance of Cooper for your data with the appropriate optional parameters. The optional parameters have the following function:
+ `:ntile` Selects the display mode default it `5` for Quintile other modes are `4` for Quartile and `100` for Percentile.
+ `:timestamp_label` Indicates the symbol used in the dataset for the timestamp data, default is `:timestamp`.
+ `:bucket_shape` buckets are devided by a Cooper instance based on the [Ruby Time Class `strftime` method](http://www.ruby-doc.org/core-2.0.0/Time.html#method-i-strftime). The default vaule is `'%b%d%y'` which will create a unique label for each day. To change the periods Cooper uses just write a `strftime` statement that uniquily identifies those periods. Eg. `'%V%G'` for week based. 
+ `:sum_label` Toggles the buckets between count and suming modes by setting it to the symbol of the tuple you want to sum. Default value is `nil` for count mode. Eg. If you wanted to sum the dollar amount of sales using the preceeding sample data you would set it to the symbol `:sales_amount`.

After the Cooper instance has been created it is just a matter of matching function calls to different elements in the scheduler in the same manner as the example widgets.
```ruby
send_event('sales', { value: sales_cooper.calc_current_value, 
    rank: sales_cooper.calc_current_rank,
    suffix: sales_cooper.rank_suffix,
    mode: sales_cooper.ntile_mode,
    next_text: sales_cooper.next_text,
    next_rank_value: sales_cooper.next_rank_value })
```
Enjoy!
