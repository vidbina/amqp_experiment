#!/usr/bin/env ruby
# encoding: utf-8

require 'rubygems'
require 'amqp'

EventMachine.run do
  connection = AMQP.connect host: '127.0.0.1'

  channel  = AMQP::Channel.new connection
  chinese_queue  = channel.queue 'china.convo.demo', auto_delete: true
  russian_queue  = channel.queue 'russia.convo.demo', auto_delete: true
  american_queue = channel.queue 'states.convo.demo', auto_delete: true

  exchange = channel.direct ''

  chinese_queue.subscribe do |message|
    puts "Mr. Putin, #{message}"
  end

  russian_queue.subscribe do |message|
    puts "Mr. Jinping, #{message}"
  end

  american_queue.subscribe do |message|
    puts "Mr. Obama, #{message}"
    connection.close { EventMachine.stop }
  end

  exchange.publish 'dinner at your place?', routing_key: chinese_queue.name
  exchange.publish 'subderby on friday?', routing_key: russian_queue.name
  exchange.publish 'is the hoop fixed? How about a 1 on 1, now?', routing_key: american_queue.name
end
