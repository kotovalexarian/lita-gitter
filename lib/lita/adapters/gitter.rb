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
    end

    Lita.register_adapter(:gitter, Gitter)
  end
end
