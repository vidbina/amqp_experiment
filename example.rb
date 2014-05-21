#!/usr/bin/env ruby
# encoding: utf-8

require 'rubygems'
require 'amqp'

EventMachine.run do
  connection = AMQP.connect host: '127.0.0.1'
  puts "Connected to AMQP broker running v#{AMQP::VERSION} of the amqp gem"

  channel  = AMQP::Channel.new connection
  queue    = channel.queue 'amqpgem.examples.helloworld', auto_delete: true
  exchange = channel.direct ''

  queue.subscribe do |payload|
    puts "Received: #{payload}"
    connection.close
  end

  exchange.publish 'Hello, universe!', routing_key: queue.name
end
