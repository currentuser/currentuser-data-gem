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
      end
    end
  end
end
