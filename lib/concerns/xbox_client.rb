module XboxClient
  # @return [XboxApi::Client]
  def self.client
    key = RequestStore.fetch 'xbox_client_key' do
      ENV['DEFAULT_XBOX_API']
    end
    RequestStore.fetch "xbox_client_#{key}" do
      puts "Using xbox client with key #{key}"
      XboxApi::Client.new(key)
    end
  end

  def set_key(key)
    RequestStore.write 'xbox_client_key', key unless key.nil?
  end
end