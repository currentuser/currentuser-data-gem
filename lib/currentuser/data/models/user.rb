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

      end
    end
  end
end
