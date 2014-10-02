require 'helper'

module Currentuser
  module Data

    # In these test we take 'User' as an example of class inheriting from BaseResource.
    # We could have taken BaseResource, but we prefer to check that the behavior is correct in inheriting classes.
    describe BaseResource do

      before do
        ApplicationIdRepository.class.instance_variable_get(:@application_id).must_be_nil
        RequestStore.exist?('currentuser-data-application_id').must_equal false
      end

      after do
        ApplicationIdRepository.class.instance_variable_set(:@application_id, nil)
        RequestStore.delete('currentuser-data-application_id')
      end

      describe '#headers' do
        it 'contains application id' do
          User.application_id = 'my_application_id'
          User.headers['CURRENTUSER_APPLICATION_ID'].must_equal 'my_application_id'
        end
        it 'uses application from request store if set' do
          ApplicationIdRepository.with_application_id 'my_application_id' do
            User.headers['CURRENTUSER_APPLICATION_ID'].must_equal 'my_application_id'
          end
        end
        it 'raises if no application id' do
          ApplicationIdRepository.with_application_id nil do
            -> {User.headers}.must_raise RuntimeError
          end
        end
      end

      it 'is threadsafe' do
        # Set a global value for application id
        User.application_id = 'my_application_id'

        before_in_threads =[]
        after_in_threads =[]

        # Setting different values in other threads
        threads = 3.times.map do |i|
          next Thread.new do
            before_in_threads[i] = User.headers['CURRENTUSER_APPLICATION_ID']
            ApplicationIdRepository.with_application_id "my_application_id#{i}" do
              after_in_threads[i] = User.headers['CURRENTUSER_APPLICATION_ID']
            end
          end
        end
        threads.each(&:join)

        before_in_threads.each do |value|
          value.must_equal 'my_application_id'
        end
        after_in_threads.each_with_index do |value, index|
          value.must_equal "my_application_id#{index}"
        end

        # Other threads should not impact value in current thread
        User.headers['CURRENTUSER_APPLICATION_ID'].must_equal 'my_application_id'
      end
    end
  end
end
