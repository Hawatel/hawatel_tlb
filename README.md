# Hawatel_tlb

Hawatel_tlb is a ruby version of load balancer which the purpose is to dynamic return selected address IP/hostname based on specified algorithm. Depend on settings gem have built features like regularly monitoring status backend nodes, response time, calculating fastest node based on history, flapping detection and more. Currently, supported algorithms are round robin, dynamic ration, fastest, ratio and weighted.
## Installation

Add this line to your application's Gemfile:

```ruby
gem 'hawatel_tlb'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install hawatel_tlb


## Available algorithms
|Name|Description|
|---|---|
|dynamicratio| Dynamic load balancing algorithm based on dynamic ratio weights. Weight for each node is setting up by following formula: 100 - (respond_time / sum_respond_time) * 100 |
|fastest|Algorithm based on history statistics about respond time and 'online' states (flapping detection). Return host with fastest responds time.|
|ratio|Static load balancing algorithm based on ratio weights
|roundrobin|Standard [Round-robin](https://en.wikipedia.org/wiki/Round-robin_scheduling) algorithm with fail node and flapping detection|
|weighted|Algorithm based on specified by user weight, return currently available host with highest metric.  |

## Example Usage

###### Create client 
``` ruby
client = HawatelTlb::Client.new
```

###### Add hosts to group
``` ruby
client.add({:host => 'api.example.com', :port => 80, :weight => 0, :state => 'enable'})
client.add({:host => 'api.example2.com', :port => 80, :weight => 0, :state => 'enable'})
client.add({:host => 'api.example3.com', :port => 80, :weight => 0, :state => 'enable'})
```

###### Set  algorithm
``` ruby
client.configure({:mode => 'fastest'})
```

###### Call API request 
``` ruby
p client.node
{:host=>"example2.com", :port=>80}

Net::HTTP.get(client.node[:host], '/q=seach_example')
```


## Contributing

See [CONTRIBUTING](CONTRIBUTING.md)

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

