require 'xbox-api'
require 'active_model'
require 'json'
require 'concerns/xbox_client'

class XboxGame
  extend ActiveModel::Callbacks
  include ActiveModel::Dirty

  attr_accessor :name,
                :id,
                :cover_url,
                :store_link,
                :max_local,
                :max_online,
                :min_online,
                :online_coop,
                :local_coop,
                :description

  def initialize(id, name)
    self.name = name
    self.id = id
    self.max_local = 0
    self.max_online = 0
    self.min_online = 0
    self.online_coop = false
    self.local_coop = false
  end

  # @return [XboxGame]
  def self.find(params)
    id = params[:id]

    puts "Attempting to fetch game info for #{id}"
    Rails.cache.fetch("xbox_game:#{id}".to_s) do
      puts 'Not found in cache.  Fetching...'

      begin
        hex_id = id.to_i.to_s(16)
        remote_model = XboxClient::client.game(hex_id).details
        remote_model = remote_model[:Items].first
        puts "Remote Model: #{remote_model.to_json}"

        game = XboxGame.new(id, remote_model[:Name])
        remote_model[:Capabilities].each do |capability|
          name = capability[:NonLocalizedName]
          value = capability[:Value]
          case
            when (%w(OnlineMultiplayerWithGoldMax onlineMultiplayerMax).include?(name))
              game.max_online = value
            when (['LocalMultiplayerMax'].include?(name))
              game.max_local = value
              game.local_coop = true
            when (%w(OnlineMultiplayerWithGoldMin onlineMultiplayerMin).include? name)
              game.min_online = value
            when (['CoopSupportOnline'].include? name)
              game.online_coop = value == 'Online'
            when (['onlineCoopPlayersMin'].include? name)
              game.online_coop = value > 1
            when (['CoopSupportLocal'].include? name)
              game.local_coop = value == 'Local'
            when (['offlineCoopPlayersMax'].include? name)
              game.local_coop = value > 1
            else
              # do nothing
          end
        end unless remote_model[:Capabilities].nil?
        game.description = remote_model[:Description].to_s
        unless remote_model[:Images].nil?
          art = remote_model[:Images].find { |x| x[:Purpose] == 'FeaturePromotionalSquareArt' }
          game.cover_url = art[:Url] unless art.nil?
        end

        game
      rescue StandardError => e
        puts "Could not find at url: https://xboxapi.com/v2/game-details-hex/#{hex_id}"
        puts "#{e.message}"
        puts "#{e.inspect}"
        return nil
      end
    end
  end

  def update
    Rails.cache.write(get_key(self.id), self)
  end

end