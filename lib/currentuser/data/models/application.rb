module Currentuser
  module Data
    class Application < BaseResource
      class << self
        def current
          return find(:me)
        end
      end
    end
  end
end
