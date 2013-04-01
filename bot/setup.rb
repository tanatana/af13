#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
$: << "."
require 'model'
require 'pp'

CONSUMER = {
  key: 'L4Hk08CfaoVOKPrlHi59Q',
  secret: 'X4R13PqxxEOAtLWV2T1h9FiesUPjDWNFWnstTiLRHM'
}

ACCESS_A = {
  token: '155474987-v8cuyjBOAUvkOzgPGdJhywysnj4MQ2McIqceqCtM',
  secret: 'VGkJgVGmruTXdgAxQjfcLuSlKBNs07IH1FcDqh45K0'
}

ACCESS_B = {
  token: '592636799-PI8lpAe9uWBT1tbXx2kcNE5y75FTxNLUMPLaRWt4',
  secret: 'lNIu5arjPIlwWIXLMv4RMkN6Vk0MNGl9Hm8RO43ZEE'
}

Bot.store(CONSUMER, ACCESS_A)
Bot.store(CONSUMER, ACCESS_B)
