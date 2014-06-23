module Currentuser
  module Data
    class User < BaseResource

      class << self

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

      end
    end
  end
end
