#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
$: << "."
require 'model'
require 'pp'
require 'config'

Bot.store(CONSUMER, ACCESS_KGB)
Bot.store(CONSUMER, ACCESS_KNOWL)
