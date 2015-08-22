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

      attr_reader :connection

      # The main loop. Listens for incoming messages,
      # creates {Lita::Message} objects from them,
      # and dispatches them to the robot.
      #
      def run
        return if connection

        @connection = Connection.new(robot, config)
        connection.run
      end

      # Sends one or more messages to a user or room.
      #
      # @param target [Lita::Source] The user or room to send messages to.
      # @param messages [Array<String>] An array of messages to send.
      #
      def send_messages(target, messages)
        messages.reject(&:empty?).each do |message|
          connection.send_message(target, message)
        end
      end

      def shut_down
        return unless connection

        connection.shut_down
        robot.trigger(:disconnected)
      end
    end

    Lita.register_adapter(:gitter, Gitter)
  end
end
