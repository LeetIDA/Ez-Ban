require 'httparty'
require 'rspec'
require 'nokogiri'
require 'json'

RSpec.describe 'TikTok API' do
  let(:base_url) { 'https://www.tiktok.com/@' }

  def fetch_user_data(username)
    headers = {
      'User-Agent' => 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/110.0.0.0 IDA'
    }
    response = HTTParty.get("#{base_url}#{username}", headers: headers)
    return nil if response.code != 200

    script_tag = Nokogiri::HTML(response.body).at('script#__UNIVERSAL_DATA_FOR_REHYDRATION__')
    script_text = script_tag.text.strip
    JSON.parse(script_text)['__DEFAULT_SCOPE__']['webapp.user-detail']['userInfo']
  rescue StandardError
    nil
  end

  context 'when the username exists' do
    it 'returns the user details' do
      username = '9dmx'
      user_data = fetch_user_data(username)
      expect(user_data).not_to be_nil
      expect(user_data['user']['uniqueId']).to eq(username)
      puts "User ID: #{user_data['user']['id']}"
      puts "secUid: #{user_data['user']['secUid']}"
    end
  end

  context 'when the username does not exist' do
    it 'returns nil or default response' do
      username = 'non_existing_user'
      user_data = fetch_user_data(username)
      expect(user_data).to be_nil.or include("user" => include("uniqueId" => username, "id" => nil, "secUid" => nil))
    end
  end
end