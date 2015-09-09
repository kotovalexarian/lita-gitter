require 'em-http'
require 'net/http'

module Lita
  module Adapters
    class Gitter < Adapter
      ##
      # Connection adapter to RestAPI and Stream API
      #
      class Connection
        attr_reader :robot
        attr_reader :config

        def initialize(robot, config)
          @robot = robot
          @config = config
        end

        # The main loop. Listens for incoming messages,
        # creates {Lita::Message} objects from them,
        # and dispatches them to the robot.
        #
        def run
          EventMachine.run do
            log.debug("Connecting to Gitter Stream API (room: #{config.room_id}).")

            buffer = ''
            start_request.stream do |chunk|
              body = buffer + chunk

              # Keep alive packet, ignore!
              next if body.strip.empty?

              if body.end_with?("}\n")
                # End of chunk, let's process it!
                received = body.dup
                buffer = ''

                EM.defer { parse(received) }
              else
                # Chunk too big, buffering!
                buffer = body
              end
            end
          end
        end

        # Sends one message to a user or room.
        #
        # @param target [Lita::Source] The user or room to send message to.
        # @param text [String] Messages to send.
        #
        def send_message(_target, text) # rubocop:disable Metrics/AbcSize
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

            @user_id = MultiJson.load(response.body)['fromUser']['id']
          end
        end

        # Shutdown connection
        #
        def shut_down
          log.debug('Closing connection to Gitter Stream API.') if http

          EM.stop if EM.reactor_running?
        end

        private

        # Parse received message
        #
        # @param text [String] Received body content.
        #
        def parse(body)
          response = MultiJson.load(body)

          text = response['text']
          from_id = response['fromUser']['id']
          room_id = config.room_id

          get_message(text, from_id, room_id)

        rescue MultiJson::ParseError => e
          log.error "Failed to decode: #{body.inspect} - #{e}"
        end

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

        # Helper method to access Lita logger
        #
        def log
          Lita.logger
        end

        # HTTP Request initializer
        #
        def http
          @http ||= EventMachine::HttpRequest.new(
            stream_url,
            keepalive: true,
            connect_timeout: 0,
            inactivity_timeout: 0,
          )
        end

        def start_request
          http.get(
            head: {
              'Accept' => 'application/json',
              'Authorization' => "Bearer #{config.token}",
            }
          )
        end

        # Stream URL for configured Room
        #
        # @return [String] stream url
        #
        def stream_url
          "https://stream.gitter.im/v1/rooms/#{@config.room_id}/chatMessages"
        end
      end
    end
  end
end
