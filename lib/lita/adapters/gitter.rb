require 'em-http'
require 'net/http'

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
        stream_url = "https://stream.gitter.im/v1/rooms/#{config.room_id}/chatMessages"

        http = EventMachine::HttpRequest.new(
          stream_url,
          keepalive: true,
          connect_timeout: 0,
          inactivity_timeout: 0,
        )

        EventMachine.run do
          log.debug("Connecting to Gitter Stream API (room: #{config.room_id}).")
          request = http.get(
            head: {
              'Accept' => 'application/json',
              'Authorization' => "Bearer #{config.token}",
            }
          )

          buffer = ''

          request.stream do |chunk|
            body = buffer + chunk

            if body.strip.empty?
              # Keep alive packet, ignore!
              next
            end

            if body.end_with?("}\n")
              # End of chunk, let's process it!
              begin
                response = MultiJson.load(body)
                buffer = ''
                body = ''

                text = response['text']
                from_id = response['fromUser']['id']
                room_id = config.room_id

                get_message(text, from_id, room_id)

              rescue MultiJson::ParseError => e
                log.error "Failed to decode JSON: #{e}"
              end
            else
              # Chunk too big, buffering!
              buffer = body
            end
          end
        end
      end

      # Sends one or more messages to a user or room.
      #
      # @param target [Lita::Source] The user or room to send messages to.
      # @param messages [Array<String>] An array of messages to send.
      #
      def send_messages(target, messages)
        messages.reject(&:empty?).each do |message|
          send_message(target, message)
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

        return if from_id == @user_id

        message.command!
        robot.receive(message)
      end

      # Sends one message to a user or room.
      #
      # @param target [Lita::Source] The user or room to send message to.
      # @param text [String] Messages to send.
      #
      def send_message(_target, text) # rubocop:disable AbcSize, MethodLength
        url = "https://api.gitter.im/v1/rooms/#{config.room_id}/chatMessages"
        uri = URI.parse(url)

        Net::HTTP.start(
          uri.host,
          uri.port,
          use_ssl: true,
          verify_mode: OpenSSL::SSL::VERIFY_NONE,
        ) do |http|
          request = Net::HTTP::Post.new(uri.path)
          request.add_field('Content-Type', 'application/json')
          request.add_field('Accept', 'application/json')
          request.add_field('Authorization', "Bearer #{config.token}")
          request.body = { 'text' => text }.to_json
          response = http.request(request)

          @user_id = JSON.parse(response.body)['fromUser']['id']
        end
      end
    end

    Lita.register_adapter(:gitter, Gitter)
  end
end
