#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
$: << "."
require 'model'
require 'pp'

b1 = Bot.new(Bot.coll.find_one({screen_name: 'eye_of_phelrine'}))
b2 = Bot.new(Bot.coll.find_one({screen_name: 'proof_tana'}))

puts "HANDLE MENTION"
b1.handle_mentions
b2.handle_mentions

puts "RANDOM UPDATE"
b1.update_status
b2.update_status
