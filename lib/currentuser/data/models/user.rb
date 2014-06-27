module Currentuser
  module Data
    class User < BaseResource

      class << self

        # @return [User]
        def authenticate(email, password)
          return with_authentication(email, password) do
            begin
              next find(:me)
            rescue ActiveResource::UnauthorizedAccess
              # Authentication has failed. Let's return nil
              next nil
            end
          end
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
