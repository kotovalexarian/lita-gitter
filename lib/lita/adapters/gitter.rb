require 'em-http'
require 'json'

##
# Lita module.
#
module Lita
  ##
  # Lita adapters module.
  #
  module Adapters
    ##
    # Gitter adapter for the Lita chat bot.
    #
    class Gitter < Adapter
      config :token,   type: String, required: true
      config :room_id, type: String, required: true

      # The main loop. Listens for incoming messages,
      # creates {Lita::Message} objects from them,
      # and dispatches them to the robot.
      #
      def run # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        stream_url =
          "https://stream.gitter.im/v1/rooms/#{config.room_id}/chatMessages"

        http = EventMachine::HttpRequest.new(
          stream_url,
          keepalive: true,
          connect_timeout: 0,
          inactivity_timeout: 0,
        )

        EventMachine.run do
          request = http.get(
            head: {
              'Accept' => 'application/json',
              'Authorization' => "Bearer #{config.token}",
            }
          )

          request.stream do |chunk|
            unless chunk.strip.empty?
              response = JSON.parse(chunk)

              text = response['text']
              from_id = response['fromUser']['id']
              room_id = config.room_id

              get_message(text, from_id, room_id)
            end
          end
        end
      end

      protected

      # Handle new message
      #
      # @param text [String] Message text.
      # @param from_id [String] ID of user who sent this message.
      # @param room_id [String] Room ID.
      #
      def get_message(text, from_id, room_id)
        user = User.new(from_id)
        source = Source.new(user: user, room: room_id)
        message = Message.new(robot, text, source)

        message.command!
        robot.receive(message)
      end
    end

    Lita.register_adapter(:gitter, Gitter)
  end
end
