require 'yaml'
require 'chatwork'

config = Hashie::Mash.load('config.yml')

config.each do |_name, props|
  ChatWork.api_key = props.chatwork.api_key
  messages = ChatWork::Message.get(room_id: props.chatwork.room_id, force: true)

  YAML.dump(
    messages.map(&:to_hash),
    File.open("#{props.chatwork.room_id}_messages.yml", 'w'),
  )
end
