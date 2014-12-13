require 'active_resource'
module Currentuser
  module Data
    class BaseResource < ActiveResource::Base
      # Note that this website does not exist for now.
      self.site = 'http://data.currentuser.io'

      class << self

        delegate :project_id=, to: ProjectIdRepository

        # Used by ActiveResource
        def headers
          headers = {}
          if ProjectIdRepository.resolve_project_id
            headers['CURRENTUSER_PROJECT_ID'] = ProjectIdRepository.resolve_project_id
          end
          return headers
        end

        # Part of private API because it happens that no action of the public API needs an external call of this method
        # for now. Could be part of public API in the future.
        # @api private
        def with_authentication(user, password)
          # We have to set 'user' and 'password' just for this call. In order to do that we use a Mutex.
          # We could do a non-blocking implementation but that would be slightly more complicated as it would require
          # overriding #user and #password methods.
          return mutex.synchronize do
            next begin
              self.user = user
              self.password = password
              yield

            ensure
              # Avoid the given credential to persist in memory.
              self.user = nil
              self.password = nil
            end
          end
        end

        private
        def mutex
          return @mutex ||= Mutex.new
        end
      end
    end
  end
end
