require 'json'
require 'dotenv/load'
require 'chatwork'

CHATWORK_ROOM_ID = ENV.fetch('CHATWORK_ROOM_ID')

messages = ChatWork::Message.get(room_id: CHATWORK_ROOM_ID, force: true)

File.open("#{CHATWORK_ROOM_ID}_messages.json", 'w') do |f|
  f.print(JSON.pretty_generate(messages))
end
