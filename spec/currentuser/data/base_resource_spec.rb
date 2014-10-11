require 'helper'

module Currentuser
  module Data

    # In these test we take 'User' as an example of class inheriting from BaseResource.
    # We could have taken BaseResource, but we prefer to check that the behavior is correct in inheriting classes.
    describe BaseResource do

      describe '#headers' do

        before do
          ApplicationIdRepository.class.instance_variable_get(:@application_id).must_be_nil
          RequestStore.exist?('currentuser-data-application_id').must_equal false
        end

        after do
          ApplicationIdRepository.class.instance_variable_set(:@application_id, nil)
          RequestStore.delete('currentuser-data-application_id')
        end

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
                sleep (2 - i) * 0.1
                after_in_threads[i] = User.headers['CURRENTUSER_APPLICATION_ID']
                sleep i * 0.1
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

      describe '#with_authentication' do
        before do
          User.user.must_be_nil
          User.password.must_be_nil
        end
        after do
          User.user = nil
          User.password = nil
        end

        it 'sets user and password in the block only' do
          User.with_authentication('user_1', 'password_1') do
            User.user.must_equal 'user_1'
            User.password.must_equal 'password_1'
          end
          User.user.must_be_nil
          User.password.must_be_nil
        end

        it 'removes user and password if exception in the block' do
          begin
            User.with_authentication('user_1', 'password_1') do
              User.user.wont_be_nil
              User.password.wont_be_nil
              raise
            end
          rescue RuntimeError
          end
          User.user.must_be_nil
          User.password.must_be_nil
        end

        it 'is threadsafe' do
          value_in_threads =[]

          # Setting different values in various threads
          threads = 3.times.map do |i|
            next Thread.new do
              User.with_authentication "user_#{i}", 'password' do
                sleep (2 - i) * 0.1
                value_in_threads[i] = User.user
                sleep i * 0.1
              end
            end
          end
          threads.each(&:join)

          value_in_threads.each_with_index do |value, index|
            value.must_equal "user_#{index}"
          end
        end
      end
    end
  end
end
