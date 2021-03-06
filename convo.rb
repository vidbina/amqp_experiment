#!/usr/bin/env ruby
# encoding: utf-8

require 'rubygems'
require 'amqp'

AMQP.start host: '127.0.0.1' do |connection|
  channel  = AMQP::Channel.new connection

  pm = channel.direct ''
  g3 = channel.fanout 'g3'
  feeds = {
    pu_watch: channel.fanout('plutonium watch'),
    sports: channel.fanout('sports news'),
    cia: channel.fanout('somewhat intelligent')
  }

  channel.queue('china.convo', auto_delete: true).bind(g3).bind(feeds[:sports]).subscribe do |msg|
    puts "Mr. Jinping, #{msg}"
  end

  channel.queue('russia.convo', auto_delete: true).bind(g3).bind(feeds[:pu_watch]).subscribe do |msg|
    puts "Mr. Putin, #{msg}"
  end

  channel.queue('states.convo', auto_delete: true).bind(g3).bind(feeds[:sports]).subscribe do |msg|
    puts "Mr. Obama, #{msg}"
  end

  EventMachine.add_timer(3) do
    pm.delete
    g3.delete
    feeds.each do |k, v|
      v.delete
    end
    connection.close { EventMachine.stop }
  end

  pm.publish 'dinner at your place?', routing_key: 'china.convo' 
  pm.publish 'submarine derby on friday?', routing_key: 'russia.convo'
  pm.publish 'is the hoop fixed? How about a 1 on 1, now?', routing_key: 'states.convo'
  g3.publish 'do not forget that there is a nuclear summit in 3 days'

  feeds[:sports].publish 'the dutch win'
  feeds[:pu_watch].publish 'a goon is looking for some Pu for its kids science fair project'
end
