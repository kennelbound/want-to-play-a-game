require 'xbox-api'
require 'active_model'
require 'concerns/xbox_client'
require_relative './xbox_game'

class XboxFriend
  extend ActiveModel::Callbacks
  include ActiveModel::Dirty

  attr_accessor :id, :name, :pic, :app_pic, :account_tier, :tenure, :rep, :gamer_score

  def self.find(params)
    id = params[:id]
    Rails.cache.fetch("friend:#{id}".to_s) do
      friend = XboxFriend.new
      friend.id = params[:id]
      friend.pic = params[:GameDisplayPicRaw]
      friend.app_pic = params[:AppDisplayPicRaw]
      friend.account_tier = params[:AccountTier]
      friend.tenure = params[:TenureLevel]
      friend.name = params[:Gamertag]
      friend.rep = params[:XboxOneRep]
      friend.gamer_score = params[:Gamerscore]

      friend
    end
  end

  def update
    Rails.cache.write("friend:#{self.id}", self)
  end
end