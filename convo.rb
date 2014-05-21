#!/usr/bin/env ruby
# encoding: utf-8

require 'rubygems'
require 'amqp'

AMQP.start host: '127.0.0.1' do |connection|
  channel  = AMQP::Channel.new connection

  channel.queue('china.convo', auto_delete: true).subscribe do |msg|
    puts "Mr. Jinping, #{msg}"
  end

  channel.queue('russia.convo', auto_delete: true).subscribe do |msg|
    puts "Mr. Putin, #{msg}"
  end

  channel.queue('states.convo', auto_delete: true).subscribe do |msg|
    puts "Mr. Obama, #{msg}"
  end

  exchange = channel.direct ''

  EventMachine.add_timer(3) do
    exchange.delete
    connection.close { EventMachine.stop }
  end

  exchange.publish 'dinner at your place?', routing_key: 'china.convo' 
  exchange.publish 'submarine derby on friday?', routing_key: 'russia.convo'
  exchange.publish 'is the hoop fixed? How about a 1 on 1, now?', routing_key: 'states.convo'
end
