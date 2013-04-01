#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
$: << "."
require 'model'
require 'pp'

b1 = Bot.new(Bot.coll.find_one({screen_name: 'knowl_KGB'}))
b2 = Bot.new(Bot.coll.find_one({screen_name: 'knowl_bot'}))

puts "HANDLE MENTION"
b1.handle_mentions
b2.handle_mentions

puts "RANDOM UPDATE"
b1.update_status
b2.update_status
