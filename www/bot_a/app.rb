# -*- coding: utf-8 -*-
$:.unshift File.dirname(__FILE__)
Bundler.require(:default)
require 'erb'

CONSUMER_KEY, CONSUMER_SECRET, AF0401= File.open("consumer.cfg").read.split("\n")

class App < Sinatra::Base
  configure do
    include ERB::Util

    use Rack::Session::Cookie, :secret => "change me",
                               :expire_after => 3600 * 24 * 2
    set :logging, true
    set :dump_errors, true
    set :show_exceptions, true
  end

  use OmniAuth::Builder do
    provider :twitter, CONSUMER_KEY, CONSUMER_SECRET
  end

  helpers do
    def encode(str, solt = 'solt')
      enc = OpenSSL::Cipher::Cipher.new('aes256')
      enc.encrypt
      enc.pkcs5_keyivgen(solt)
      (enc.update(str) + enc.final).unpack("H*").join
    rescue
      false
    end

    def decode(str, solt = 'solt')
      dec = OpenSSL::Cipher::Cipher.new('aes256')
      dec.decrypt
      dec.pkcs5_keyivgen(solt)
      (dec.update(Array.new([str]).pack("H*")) + dec.final)
    rescue  
      false
    end
  end  

  get '/auth/twitter/callback' do
    auth = request.env["omniauth.auth"]
    access_token = auth["extra"]["access_token"]
    curr_user = auth["extra"]["raw_info"]
    
    # サーバにデータを投げる

    # 終わったらリダイレクト
    "finish"
  end

  get '/' do
    enc = encode("test", AF0401)
    dec = decode(enc, AF0401)

    "hi!"
  end
end
