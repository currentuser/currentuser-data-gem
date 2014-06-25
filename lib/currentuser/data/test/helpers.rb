module Currentuser
  module Data
    module Test

      module UseReadApi
        def setup
          super

          Data::BaseResource.application_id = @@currentuser_application_id_for_tests
          # Ensure we request the right application, before test are run.
          unless UseReadApi.check_test_application_id && UseReadApi.check_test_application
            skip 'UseReadApi.currentuser_application_id_for_tests should correspond to a test application'
          end
        end

        def teardown
          Data::BaseResource.application_id = nil
          super
        end

        def self.check_test_application_id
          return @@currentuser_application_id_for_tests == Data::ApplicationIdRepository.send(:resolve_application_id)
        end

        # Check that test application is really a test one
        def self.check_test_application
          @@result = Data::Application.current.test?  if @@result.nil?
          return @@result
        end
        @@result = nil

        def self.currentuser_application_id_for_tests=(value)
          @@currentuser_application_id_for_tests = value
        end
      end

      module UseWriteApi
        def teardown
          # Check the :clear command below will be done on the right application.
          if UseReadApi.check_test_application_id && UseReadApi.check_test_application
            Data::User.delete(:clear)
          end

          super # Will reset application_id
        end

        include UseReadApi
      end

    end
  end
end
