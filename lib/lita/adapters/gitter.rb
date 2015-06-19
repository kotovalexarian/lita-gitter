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
      def run # rubocop:disable Metrics/MethodLength
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
              text = JSON.parse(chunk)['text']
            end
          end
        end
      end
    end

    Lita.register_adapter(:gitter, Gitter)
  end
end
