# -*- coding: utf-8 -*-
require 'mongo'
require 'bson'
require 'twitter'

class Database
  def self.db
    @db ||= ::Mongo::Connection.new.db('af13')
  end

  def self.coll(name)
    self.db.collection(name)
  end
end


class Tweet
  def self.coll
    Database.coll('tweet')
  end

  def self.store(tw)
    data = tw.to_hash
    self.coll.update({id: data[:id]}, data, {upsert: true})
  end

  def self.find(tweet_id)
    self.coll.find_one({id: tweet_id})
  end
end


class MentionedTweet
  def self.coll
    Database.coll('mentioned')
  end

  def self.store(tw, bot_name)
    return if self.coll.find_one({tweet_id: tw.id})
    data = {
      tweet_id: tw.id,
      bot_name: bot_name,
      tweeted: []
    }
    return self.coll.update({tweet_id: data[:tweet_id]}, data, {upsert: true})
  end

  def self.unhandled_tweets(bot_name)
    tweets = self.coll.find({bot_name: {:$ne => bot_name}}).to_a
    tweets.delete_if{|tweet| tweet["tweeted"].include? bot_name}
      .map{|tweet| self.new(tweet)}
  end

  def initialize(data)
    @data = data
  end

  def tweet_id
    @data["tweet_id"]
  end

  def tweeted!(bot_name)
    MentionedTweet.coll.update({_id: @data["_id"]}, {:$push => {tweeted: bot_name}})
  end
end


class UpdatedTweet
  def self.coll
    Database.coll('updated')
  end

  def self.store(tweet_id, source_id)
    data = {
      tweet_id: tweet_id,
      source_id: source_id,
      replied: 0
    }
    self.coll.update({source_id: data[:source_id]}, data, {upsert: true})
  end

  def self.find(tweet_id)
    tweet = self.coll.find_one({tweet_id: tweet_id})
    return unless tweet
    self.new(tweet)
  end

  def initialize(data)
    @data = data
  end

  def source_id
    @data["source_id"]
  end

  def replied?
    @data["replied"] == 1
  end

  def replied!
    UpdatedTweet.coll.update(
      {_id: @data["_id"]},
      {:$set => {replied: 1}}
      )
  end
end


class Bot
  def self.coll
    Database.coll('bot')
  end

  def self.store(consumer, access)
    data = {
      :consumer_key => consumer[:key],
      :consumer_secret => consumer[:secret],
      :oauth_token => access[:token],
      :oauth_token_secret => access[:secret]
    }
    client = Twitter::Client.new(data)
    data[:bot_id] = client.user.id
    data[:screen_name] = client.user.screen_name
    self.coll.update({bot_id: data[:bot_id]}, data, {upsert: true})
  end

  def self.find(bot_id)
    self.new(self.coll.find_one({bot_id: bot_id}))
  end

  def initialize(data)
    @client = Twitter::Client.new(
      :consumer_key => data["consumer_key"],
      :consumer_secret => data["consumer_secret"],
      :oauth_token => data["oauth_token"],
      :oauth_token_secret => data["oauth_token_secret"]
      )
    @screen_name = data["screen_name"]
  end

  def mention(text, status_id, src_id)
    begin
      status = @client.update(text, {in_reply_to_status_id: status_id})
      UpdatedTweet.store(status.id, src_id)
    rescue => e
      puts text
      pp e
    end
  end

  def handle_mentions
    mentions = @client.mentions_timeline(count: 20)
    mentions.each{|tw|
      Tweet.store(tw)
      utw = UpdatedTweet.find(tw.in_reply_to_status_id)
      if (utw != nil) and not utw.replied?
        pp utw.replied?
        pp utw.source_id
        utw.replied!
        stw = Tweet.find(utw.source_id)
        tweet_text = "@#{stw["user"]["screen_name"]} " +
        tw.text.gsub(/@[\w_0-9]+ */, '')
        bot = Bot.find(stw["in_reply_to_user_id"])
        bot.mention(tweet_text, stw["in_reply_to_status_id"], tw.id)
      end

      if utw == nil
        MentionedTweet.store(tw, @screen_name)
      end
    }
  end

  def update_status
    followers = @client.followers.map{|u| u[:screen_name]}
    unhandleds = MentionedTweet.unhandled_tweets(@screen_name)
    unhandleds.each{|src|
      src.tweeted!(@screen_name)
      u = followers.shuffle[0]
      tw = Tweet.find(src.tweet_id)
      begin
        pp tweet_text = "@#{u} " + tw["text"].gsub(/@[\w_0ー9]+ */, '')
        status = @client.update(tweet_text)
      rescue => e
        puts tweet_text
        pp e
      end
      utw = UpdatedTweet.store(status.id, src.tweet_id) if status
    }
  end
end
