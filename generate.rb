# frozen_string_literal: true

require 'json'
require 'net/http'
require 'uri'

uri = URI('https://api.unsplash.com/photos/random?orientation=landscape&count=10')
req = Net::HTTP::Get.new(uri)
req['Authorization'] = "Client-ID #{ENV.fetch('UNSPLASH_CLIENT_ID')}"

res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(req) }
res.value

json_res = JSON.parse(res.body)
db_json_images = json_res.map do |photo|
  photo.slice('id', 'created_at', 'description', 'color').tap do |h|
    h['urls'] = photo['urls'].slice('full', 'regular', 'thumb')
    h['user'] = photo['user'].slice('id', 'name')
  end
end

db_json = {
  'images' => db_json_images
}

puts JSON.pretty_generate(db_json)
