require 'xbox-api'
require 'active_model'
require 'concerns/xbox_client'
require_relative './xbox_game'

class XboxGamer
  extend ActiveModel::Callbacks
  include ActiveModel::Dirty

  attr_accessor :name, :id, :games_one, :games_360, :games_win, :friends

  def initialize(name, id = nil)
    self.name = name
    self.id = id
    self.games_one = []
    self.games_360 = []
    self.games_win = []
    self.friends = []
  end

  # @param [Hash] tag
  # @return [XboxGamer
  def self.find(params)
    tag = params[:tag]
    id = params[:id]

    puts "Attempting to fetch #{tag}"
    Rails.cache.fetch("gamer_tag:#{tag}".to_s) do
      puts 'Not found, fetching from remote...'
      begin
        begin
          # @type [XboxApi::Gamer]
          remote_model = XboxApi::Gamer.new(tag, XboxClient::client, id)
          gamer = XboxGamer.new(tag, remote_model.xuid)

          friends = remote_model.friends
          friends.each do |remote_friend|
            puts "Attempting to store #{remote_friend.inspect}"
            gamer.friends << XboxFriend.find(remote_friend)
          end if !friends.blank? && !friends.is_a?(Hash)

          remote_model.xboxonegames[:titles].each do |title|
            gamer.games_one << get_game(title)
          end

          remote_model.xbox360games[:titles].each do |title|
            gamer.games_360 << get_game(title)
          end unless remote_model.xbox360games[:titles].blank?

          gamer
        rescue => exception
          puts "Exception: #{exception.to_s}"
          puts exception.message
          puts exception.backtrace
          raise # always reraise
        end

      rescue StandardError => e
        puts "Failed to fetch #{tag}: #{e.inspect}"
        return nil
      end
    end
  end

  def update
    Rails.cache.write("gamer_tag:#{self.tag}".to_s, self)
  end

  def self.get_game(remote_model)
    XboxGame.find :id => remote_model[:titleId]
  end

end