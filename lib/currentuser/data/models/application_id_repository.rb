module Currentuser
  module Data
    class ApplicationIdRepository
      class << self
        attr_writer :application_id

        # Convenient method to use given application_id for a block only, and a threadsafe way.
        def with_application_id(application_id)
          raise  if get_application_id_for_request
          return begin
            set_application_id_for_request(application_id)
            yield
          ensure
            set_application_id_for_request(nil)
          end
        end

        # Set application_id for the current request only. Useful if your application connects to multiple Currentuser
        # applications.
        def set_application_id_for_request(application_id)
          raise "You need to require 'request_store' gem to use this method"  unless request_store_available?
          RequestStore.store['currentuser-data-application_id'] = application_id
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
