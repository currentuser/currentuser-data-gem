module Currentuser
  module Data
    # @api private
    class ApplicationIdRepository
      class << self
        attr_writer :application_id

        # Force given block to use only request safe application_id values.
        def request_safe!
          ensure_request_store_available!
          begin
            reset_application_id_for_request
            yield
          ensure
            remove_application_id_for_request
          end
        end

        # Convenient method to use given application_id for a block only, and a threadsafe way.
        def with_application_id(application_id)
          ensure_request_store_available!
          old_exist = RequestStore.exist?('currentuser-data-application_id')
          old_value = RequestStore.store['currentuser-data-application_id']
          return begin
            set_application_id_for_request application_id
            yield
          ensure
            # Restore initial state
            old_exist ? set_application_id_for_request(old_value) : remove_application_id_for_request
          end
        end

        # Return request safe value if available, return static value otherwise.
        def resolve_application_id
          return RequestStore.store['currentuser-data-application_id']  if request_safe?
          return @application_id
        end

        private

          def request_safe?
            return request_store_available? && RequestStore.exist?('currentuser-data-application_id')
          end

          def set_application_id_for_request(application_id)
            RequestStore.store['currentuser-data-application_id'] = application_id
          end

          def reset_application_id_for_request
            set_application_id_for_request nil
          end

          def remove_application_id_for_request
            RequestStore.delete('currentuser-data-application_id')
          end

          def ensure_request_store_available!
            raise "You need to require 'request_store' gem to use this method"  unless request_store_available?
          end

          def request_store_available?
            return defined?(RequestStore) == 'constant'
          end
      end
    end
  end
end
