$: << File.expand_path('../lib', File.dirname(__FILE__))

require 'message_handler'
require 'sinatra/base'
require 'slack-ruby-client'

class EventController < Sinatra::Base
  attr_reader :message_handler

  def initialize()
    @message_handler = MessageHandler.new
  end

  post '/events' do
    request_data = JSON.parse(request.body.read)
    puts request_data

    verify_token(request_data)
    verify_url(request_data)
    handle_event(request_data)

    status 200
  end

  private

  def verify_token(data)
    if invalid_token?(data['token'])
      halt 403, "Invalid Slack verification token received: #{data['token']}"
    end
  end

  def invalid_token?(token)
    !SLACK_CONFIG[:slack_verification_token] == token
  end

  def verify_url(data)
    if data['type'] == 'url_verification'
      data['challenge']
    end
  end

  def handle_event(data)
    if data['type'] == 'event_callback'
      team_id = data['team_id']
      event_data = data['event']

      if message?(event_data) && !from_robot?(event_data, team_id)
        @message_handler.handle(team_id, event_data)
      end
    end
  end

  def message?(event_data)
    event_data['type'] == 'message'
  end

  def from_robot?(event_data, team_id)
    event_data['user'] == $teams[team_id][:bot_user_id]
  end
end
