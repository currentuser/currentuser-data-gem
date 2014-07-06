require 'active_resource'
module Currentuser
  module Data
    class BaseResource < ActiveResource::Base
      # currentuser-data is in development. We use a fixed local endpoint for now.
      self.site = 'http://localhost:3002'

      class << self

        delegate :application_id=, to: ApplicationIdRepository

        # Used by ActiveResource
        def headers
          return {'CURRENTUSER_APPLICATION_ID' => ApplicationIdRepository.resolve_application_id}
        end

        def with_authentication(user, password)
          # We have to set 'user' and 'password' just for this call. In order to do that we use a Mutex.
          # We could do a non-blocking implementation but that would be slightly more complicated as it would require
          # overriding #user and #password methods.
          return Mutex.new.synchronize do
            begin
              self.user = user
              self.password = password
              result = yield

            ensure
              # Avoid the given credential to persist in memory.
              self.user = nil
              self.password = nil
            end

            next result
          end
        end

      end
    end
  end
end
