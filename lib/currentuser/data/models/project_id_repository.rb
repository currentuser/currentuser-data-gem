module Currentuser
  module Data
    # @api private
    class ProjectIdRepository
      class << self
        attr_writer :project_id

        # Force given block to use only request safe project_id values.
        def request_safe!
          ensure_request_store_available!
          begin
            reset_project_id_for_request
            yield
          ensure
            remove_project_id_for_request
          end
        end

        # Convenient method to use given project_id for a block only, and a threadsafe way.
        def with_project_id(project_id)
          ensure_request_store_available!
          old_exist = RequestStore.exist?('currentuser-data-project_id')
          old_value = RequestStore.store['currentuser-data-project_id']
          return begin
            set_project_id_for_request project_id
            yield
          ensure
            # Restore initial state
            old_exist ? set_project_id_for_request(old_value) : remove_project_id_for_request
          end
        end

        # Return request safe value if available, return static value otherwise.
        def resolve_project_id
          return RequestStore.store['currentuser-data-project_id']  if request_safe?
          return @project_id
        end

        private

          def request_safe?
            return request_store_available? && RequestStore.exist?('currentuser-data-project_id')
          end

          def set_project_id_for_request(project_id)
            RequestStore.store['currentuser-data-project_id'] = project_id
          end

          def reset_project_id_for_request
            set_project_id_for_request nil
          end

          def remove_project_id_for_request
            RequestStore.delete('currentuser-data-project_id')
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
