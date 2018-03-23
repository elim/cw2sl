require 'chatwork'
require 'hashie'
require 'slack/post'

CHATWORK_LINK_FORMAT = 'https://www.chatwork.com/#!rid%s-%s'.freeze

config = Hashie::Mash.load('config.yml')

config.each do |_name, props|
  cw = props.chatwork
  sl = props.slack

  ChatWork.api_key = cw.api_key
  cw_room_name = ChatWork::Room.find(room_id: cw.room_id).name
  Slack::Post.configure(webhook_url: sl.webhook_url, icon_emoji: sl.icon_emoji)

  messages = if cw.use_dump
               YAML.load_file("#{cw.room_id}_messages.yml").map! { |m| Hashie::Mash.new(m) }
             else
               ChatWork::Message.get(room_id: cw.room_id, force: cw.force_get)
             end

  messages&.each do |message|
    text = CHATWORK_LINK_FORMAT % [cw.room_id, message.message_id]
    attachments = [
      {
        thumb_url: message.account.avatar_image_url,
        text: message.body,
        ts: message.send_time,
        footer: "#{message.account.name}@#{cw_room_name}"
      }
    ]

    Slack::Post.configure(username: message.account.name)
    Slack::Post.post_with_attachments(text, attachments)

    sleep 1
  end
end
