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
    end

    Lita.register_adapter(:gitter, Gitter)
  end
end
