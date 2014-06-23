module Currentuser
  module Data
    class ApplicationIdRepository
      class << self
        attr_writer :application_id

        # Set application_id for the current request only. Useful if your application connects to multiple Currentuser
        # applications.
        def set_application_id_for_request(value)
          raise "You need to require 'request_store' gem to use this method"  unless request_store_available?
          RequestStore.store['currentuser-data-application_id'] = value
        end

        def resolve_application_id
          return get_application_id_for_request || @application_id
        end

        private
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
