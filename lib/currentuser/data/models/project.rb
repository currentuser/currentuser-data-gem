module Currentuser
  module Data
    class Project < BaseResource
      include ActiveResource::Singleton

      def users(project_secret_key)
        return User.with_authentication(id, project_secret_key) do
          next User.all
        end
      end

      class << self
        alias :current :find
      end
    end
  end
end
