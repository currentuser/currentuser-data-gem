require 'helper'

module Currentuser
  module Data

    describe Application do

      if ENV['CURRENTUSER_APPLICATION_ID_FOR_TESTS']

        before do
          BaseResource.application_id = ENV['CURRENTUSER_APPLICATION_ID_FOR_TESTS']
        end

        after do
          BaseResource.application_id = nil
        end

        describe '#current' do

          it 'retrieves data' do
            application = Application.current

            application.id.must_equal ENV['CURRENTUSER_APPLICATION_ID_FOR_TESTS']
            application.name.wont_be_nil
            application.url.wont_be_nil
            application.test.must_equal true
          end
        end

        describe '#users' do

          it 'raises UnauthorizedAccess if no secret key' do
            application = Application.current
            assert_raises ActiveResource::UnauthorizedAccess do
              application.users(nil)
            end
          end

          it 'raises UnauthorizedAccess if wrong secret key' do
            application = Application.current
            assert_raises ActiveResource::UnauthorizedAccess do
              application.users('wrong secret key')
            end
          end

          if ENV['CURRENTUSER_SECRET_KEY_FOR_TESTS']

            it 'returns an empty collection if no user' do
              application = Application.current
              assert_equal [], application.users(ENV['CURRENTUSER_SECRET_KEY_FOR_TESTS']).to_a
            end

            describe 'with users' do

              after do
                User.delete(:clear)
              end

              it 'returns a collection of users' do
                user_1 = User.create(email: 'email1@test.com', password: 'pass1')
                user_2 = User.create(email: 'email2@test.com', password: 'pass1')

                users = Application.current.users(ENV['CURRENTUSER_SECRET_KEY_FOR_TESTS'])

                assert_equal %w(email1@test.com email2@test.com), users.map(&:email)
                assert_equal [user_1.id, user_2.id], users.map(&:id)
              end
            end
          end
        end

        describe '#with_authentication_and_application_id' do

          it 'sets application id, user and password in the block only, and returns block value' do
            Application.with_authentication_and_application_id('app_1', 'password_1') do
              ApplicationIdRepository.resolve_application_id.must_equal 'app_1'
              Application.user.must_equal 'app_1'
              Application.password.must_equal 'password_1'
              next 'value'
            end.must_equal 'value'
            ApplicationIdRepository.resolve_application_id.wont_equal 'app_1'
            Application.user.must_be_nil
            Application.password.must_be_nil
          end

        end
      end
    end
  end
end
