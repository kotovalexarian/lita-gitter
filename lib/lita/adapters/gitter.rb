module Lita
  module Adapters
    class Gitter < Adapter
    end

    Lita.register_adapter(:gitter, Gitter)
  end
end
