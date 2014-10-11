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

        # Use only if you use request safe application id (and have to call #with_application_id), otherwise you can
        # simply call #with_authentication.
        # @api private
        def with_authentication_and_application_id(application_id, application_secret_key)
          return with_authentication(application_id, application_secret_key) do
            next ApplicationIdRepository.with_application_id(application_id) do
              next yield
            end
          end
        end
      end
    end
  end
end
