require 'helper'

module Currentuser
  module Data

    describe User do

      if ENV['CURRENTUSER_APPLICATION_ID_FOR_TESTS']

        before do
          BaseResource.application_id = ENV['CURRENTUSER_APPLICATION_ID_FOR_TESTS']
        end

        after do
          User.delete(:clear)
          BaseResource.application_id = nil
        end

        describe 'user creation' do

          it 'can be saved' do
            user = User.new(email: 'email@test.com', password: 'pass')
            user.save.must_equal true
            user.id.wont_be_nil
            user.email.must_equal 'email@test.com'
            user.application_id.must_equal ENV['CURRENTUSER_APPLICATION_ID_FOR_TESTS']
          end

          it 'can retrieve validation errors' do
            User.create(email: 'email@test.com', password: 'pass1')

            user = User.new(email: 'email@test.com', password: 'pass2')
            user.save.must_equal false
            expected = {:email=>['has already been taken']}
            user.errors.to_hash.must_equal expected
          end
        end

        describe '#authenticate' do

          it 'returns the expected user' do
            original_user = User.create(email: 'email@test.com', password: 'my password')

            authenticated_user = User.authenticate 'email@test.com', 'my password'

            authenticated_user.must_equal original_user
            User.user.must_be_nil
            User.password.must_be_nil
          end

          it 'returns nil if wrong credential' do
            user = User.authenticate 'email@test.com', 'wrong password'

            user.must_be_nil
            User.user.must_be_nil
            User.password.must_be_nil
          end
        end

      end
    end
  end
end
