require 'helper'

module Currentuser
  module Data

    # In these test we take 'User' as an example of class inheriting from BaseResource.
    # We could have token BaseResource, but we prefer to check that the behavior is correct in inheriting classes.
    describe BaseResource do

      before do
        User.class.instance_variable_get(:@application_id).must_be_nil
        RequestStore.store['currentuser-data-application_id'].must_be_nil
      end

      after do
        User.class.instance_variable_set(:@application_id, nil)
        RequestStore.store['currentuser-data-application_id'] = nil
      end

      describe '#request_store_available?' do
        it 'is true during gem tests' do
          User.send(:request_store_available?).must_equal true
        end
      end

      describe '#set_application_id_for_request' do
        it 'raises if RequestStore is not available' do
          User.stub :request_store_available?, false do
            -> {User.set_application_id_for_request 'my_application_id'}
              .must_raise RuntimeError
          end
        end
        it 'stores in request store (if available)' do
          User.set_application_id_for_request 'my_application_id'
          RequestStore.store['currentuser-data-application_id'].must_equal 'my_application_id'
        end
      end

      describe '#get_application_id_for_request' do
        it 'returns nil if RequestStore is not available' do
          User.set_application_id_for_request 'my_application_id'
          User.stub :request_store_available?, false do
            User.send(:get_application_id_for_request).must_be_nil
          end
        end
        it 'returns stored application id (if RequestStore available)' do
          User.set_application_id_for_request 'my_application_id'
          User.send(:get_application_id_for_request).must_equal 'my_application_id'
        end
      end

      describe '#resolve_application_id' do
        it 'returns request store content if set' do
          User.set_application_id_for_request 'my_application_id'
          User.application_id = 'other_application_id'
          User.send(:resolve_application_id).must_equal 'my_application_id'
        end
        it 'returns class value if no content in request store' do
          User.application_id = 'other_application_id'
          User.send(:resolve_application_id).must_equal 'other_application_id'
        end
      end

      describe '#headers' do
        it 'contains application id' do
          User.application_id = 'my_application_id'
          User.headers['CURRENTUSER_APPLICATION_ID'].must_equal 'my_application_id'
        end
        it 'uses application if form request store if set' do
          User.set_application_id_for_request 'my_application_id'
          User.headers['CURRENTUSER_APPLICATION_ID'].must_equal 'my_application_id'
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
            User.set_application_id_for_request "my_application_id#{i}"
            after_in_threads[i] = User.headers['CURRENTUSER_APPLICATION_ID']
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