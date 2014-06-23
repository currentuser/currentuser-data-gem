require 'active_resource'
module Currentuser
  module Data
    class User < ActiveResource::Base
      # currentuser-data is in development. We use a fixed local endpoint for now.
      self.site = 'http://localhost:3002'

      class << self
        attr_writer :application_id

        # @return [User]
        def authenticate(email, password)
          # We have to set 'password' and 'user' just for this call. In order to do that we use a Mutex.
          # We could do a non-blocking implementation but that would be slightly more complicated as it would require
          # overriding #user and #password methods.
          return Mutex.new.synchronize do
            begin
              self.user = email
              self.password = password
              me = find(:me)

            rescue ActiveResource::UnauthorizedAccess
              # Authentication has failed. Let 'me' remain nil.

            ensure
              # Avoid the given email and password to persist in memory.
              self.user = nil
              self.password = nil
            end
            next me
          end
        end

        # Used by ActiveResource
        def headers
          return {'CURRENTUSER_APPLICATION_ID' => resolve_application_id}
        end

        # Set application_id for the current request only. Useful if your application connects to multiple Currentuser
        # applications.
        def set_application_id_for_request(value)
          raise "You need to require 'request_store' gem to use this method"  unless request_store_available?
          RequestStore.store['currentuser-data-application_id'] = value
        end

        private

          def resolve_application_id
            return get_application_id_for_request || @application_id
          end

          def get_application_id_for_request
            return nil unless request_store_available?
            return RequestStore.store['currentuser-data-application_id']
          end

          def request_store_available?
            return defined?(RequestStore) == 'constant'
          end
      end
    end
  end
end
