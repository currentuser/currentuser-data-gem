module Currentuser
  module Data
    class Application < BaseResource
      include ActiveResource::Singleton

      def users(application_secret_key)
        return User.with_authentication(id, application_secret_key) do
          next User.all
        end
      end

      class << self
        alias :current :find
      end
    end
  end
end
