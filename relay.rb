require 'chatwork'
require 'dotenv/load'
require 'slack/post'

CHATWORK_ROOM_ID = ENV.fetch('CHATWORK_ROOM_ID')
CHATWORK_ROOM_NAME = ChatWork::Room.find(room_id: CHATWORK_ROOM_ID).name

CHATWORK_FORCE_GET = !!ENV['CHATWORK_FORCE_GET']
CHATWORK_USE_DUMP = !!ENV['CHATWORK_USE_DUMP']

SLACK_WEBHOOK_URL = ENV.fetch('SLACK_WEBHOOK_URL')
SLACK_ICON_EMOJI = ENV.fetch('SLACK_ICON_EMOJI')
SLACK_TEXT_FORMAT = 'https://www.chatwork.com/#!rid%s-%s'.freeze

Slack::Post.configure(webhook_url: SLACK_WEBHOOK_URL, icon_emoji: SLACK_ICON_EMOJI)

messages = if CHATWORK_USE_DUMP
             require 'json'
             require 'hashie'

             json = File.open("#{CHATWORK_ROOM_ID}_messages.json", 'r').read
             JSON.parse(json).map! { |m| Hashie::Mash.new(m) }
           else
             ChatWork::Message.get(room_id: CHATWORK_ROOM_ID, force: CHATWORK_FORCE_GET)
           end

messages&.each do |message|
  text = SLACK_TEXT_FORMAT % [CHATWORK_ROOM_ID, message.message_id]
  attachments = [
    {
      thumb_url: message.account.avatar_image_url,
      text: message.body,
      ts: message.send_time,
      footer: "#{message.account.name}@#{CHATWORK_ROOM_NAME}"
    }
  ]

  Slack::Post.configure(username: message.account.name)
  Slack::Post.post_with_attachments(text, attachments)

  sleep 1
end
