module Currentuser
  module Data
    class Application < BaseResource

      def users(application_secret_key)
        return User.with_authentication(id, application_secret_key) do
          next User.all
        end
      end

      class << self
        def current
          return find(:me)
        end
      end
    end
  end
end
