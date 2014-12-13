module Currentuser
  module Data
    module Test

      module UseReadApi
        def setup
          super

          Data::BaseResource.project_id = @@currentuser_project_id_for_tests
          # Ensure we request the right project, before test are run.
          unless UseReadApi.check_test_project_id && UseReadApi.check_test_project
            skip 'UseReadApi.currentuser_project_id_for_tests should correspond to a test project'
          end
        end

        def teardown
          Data::BaseResource.project_id = nil
          super
        end

        def self.check_test_project_id
          return @@currentuser_project_id_for_tests == Data::ProjectIdRepository.send(:resolve_project_id)
        end

        # Check that test project is really a test one
        def self.check_test_project
          @@result = Data::Project.current.test?  if @@result.nil?
          return @@result
        end
        @@result = nil

        def self.currentuser_project_id_for_tests=(value)
          @@currentuser_project_id_for_tests = value
        end
      end

      module UseWriteApi
        def teardown
          # Check the :clear command below will be done on the right project.
          if UseReadApi.check_test_project_id && UseReadApi.check_test_project
            Data::User.delete(:clear)
          end

          super # Will reset project_id
        end

        include UseReadApi
      end

    end
  end
end
